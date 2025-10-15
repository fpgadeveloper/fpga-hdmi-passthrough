# Opsero Electronic Design Inc. (C) 2025

# Script to create Vitis workspace from XSA file and add an application.

# build-vitis.py — Vitis (Unified IDE) 2024.1+ batch script
# Usage:
#   vitis -source build-vitis.py <target> <bd_name> [<template>]
# Examples:
#   vitis -source build-vitis.py auboard design_1
#   vitis -source build-vitis.py auboard design_1 "Empty Application (C)"

import os, sys, shutil, glob, zipfile, xml.etree.ElementTree as ET

try:
    import vitis  # Provided by the Vitis Unified IDE CLI
except ImportError:
    raise SystemExit("ERROR: Run with Vitis CLI:  vitis -source build-vitis.py <target> <bd_name> [<template>]")

def die(msg):
    print(f"ERROR: {msg}")
    sys.exit(1)

# ---------------- CPU discovery by parsing the XSA's HWH ----------------
CPU_VLNV_HINTS = [
    "xilinx.com:ip:microblaze",
    "xilinx.com:ip:ps7",
    "xilinx.com:ip:zynq_ultra_ps_e",
    "xilinx.com:ip:versal_cips",
]

def find_cpus_in_hwh_xml(xml_bytes):
    out = []
    try:
        root = ET.fromstring(xml_bytes)
    except ET.ParseError:
        return out
    for mod in root.findall(".//MODULE"):
        vlnv = mod.get("VLNV", "") or mod.get("VLNV_NAME", "")
        inst = mod.get("INSTANCE", "") or mod.get("NAME", "")
        if not inst or not vlnv:
            continue
        if any(h in vlnv.lower() for h in CPU_VLNV_HINTS):
            out.append((inst, vlnv))
    return out

def pick_preferred_cpu(cpu_list):
    if not cpu_list:
        return None
    # Prefer MicroBlaze, then ZynqMP/Versal, then Zynq-7000
    for n, v in cpu_list:
        if "microblaze" in v.lower() or "microblaze" in n.lower():
            return n
    for n, v in cpu_list:
        if "zynq_ultra_ps_e" in v.lower() or "versal_cips" in v.lower():
            return n
    for n, v in cpu_list:
        if "ps7" in v.lower():
            return n
    return cpu_list[0][0]

def detect_cpu_from_xsa(xsa_path):
    if not zipfile.is_zipfile(xsa_path):
        return None
    with zipfile.ZipFile(xsa_path, "r") as z:
        hwh_members = [m for m in z.namelist() if m.lower().endswith(".hwh")]
        cpus = []
        for m in hwh_members:
            try:
                cpus.extend(find_cpus_in_hwh_xml(z.read(m)))
            except KeyError:
                pass
        return pick_preferred_cpu(cpus)

# ---------------- misc helpers ----------------
def copy_tree(src_dir, dst_dir):
    if not os.path.isdir(src_dir):
        print(f"NOTE: Source folder '{src_dir}' doesn't exist; skipping copy.")
        return 0
    count = 0
    for root, _, files in os.walk(src_dir):
        rel = os.path.relpath(root, src_dir)
        out_root = os.path.join(dst_dir, rel) if rel != "." else dst_dir
        os.makedirs(out_root, exist_ok=True)
        for f in files:
            shutil.copy2(os.path.join(root, f), os.path.join(out_root, f))
            count += 1
    return count

def parse_args(argv):
    # Accept optional stray leading "--" (not required)
    args = argv[1:]
    if args and args[0] == "--":
        args = args[1:]
    if len(args) < 2:
        die("Expected: <target> <bd_name> [<template>]")
    target   = args[0]
    bd_name  = args[1]
    template = args[2] if len(args) >= 3 else None
    if template is not None and template.strip() == "":
        template = None
    return target, bd_name, template

def main():
    # ----- args -----
    target, bd_name, requested_template = parse_args(sys.argv)

    # ----- paths -----
    cwd        = os.getcwd()
    ws_name    = f"{target}_workspace"
    ws_path    = os.path.normpath(os.path.join(cwd, ws_name))
    xsa_path   = os.path.normpath(os.path.join(cwd, "..", "Vivado", target, f"{bd_name}_wrapper.xsa"))
    common_src = os.path.normpath(os.path.join(cwd, "common", "src"))

    print("== Build Vitis workspace ==")
    print(f"target          : {target}")
    print(f"bd_name         : {bd_name}")
    print(f"workspace name  : {ws_name}")
    print(f"workspace path  : {ws_path}")
    print(f"xsa path        : {xsa_path}")
    print(f"common src path : {common_src}")
    print(f"template        : {requested_template if requested_template else 'None (minimal app)'}")

    if not os.path.isfile(xsa_path):
        die(f"XSA not found at: {xsa_path}")
    os.makedirs(ws_path, exist_ok=True)

    # Detect a CPU from the XSA so the platform can create a domain
    cpu_name = detect_cpu_from_xsa(xsa_path)
    if not cpu_name:
        die("Could not detect a processor in the XSA (no CPU-like IP found in HWH).")

    # ----- Vitis client/workspace -----
    client = vitis.create_client()
    try:
        client.set_workspace(ws_path)

        # ----- Platform (create WITH cpu+os so a domain is created) -----
        plat_name = f"{target}_platform"
        print(f"Creating platform '{plat_name}' (cpu={cpu_name}, os=standalone) ...")
        platform = client.create_platform_component(
            name=plat_name,
            hw_design=xsa_path,
            cpu=cpu_name,
            os="standalone"
        )

        # Choose a domain (prefer standalone on our CPU)
        doms = platform.list_domains()
        if not doms:
            die("Platform has no domains after creation (unexpected).")
        domain_name = None
        for d in doms:
            if d.get("processor") == cpu_name and d.get("os") == "standalone":
                domain_name = d["domain_name"]
                break
        if not domain_name:
            domain_name = doms[0]["domain_name"]
        print(f"Using domain: {domain_name}")

        # Build the platform (emits export/<plat>/<plat>.xpfm)
        print("Building platform...")
        platform.build()

        # Resolve .xpfm
        xpfm = os.path.join(ws_path, plat_name, "export", plat_name, f"{plat_name}.xpfm")
        if not os.path.isfile(xpfm):
            matches = glob.glob(os.path.join(ws_path, "**", f"{plat_name}.xpfm"), recursive=True)
            if matches:
                xpfm = matches[0]
        if not os.path.isfile(xpfm):
            die(f"Could not locate platform .xpfm after build (looked for {xpfm}).")

        # ----- App -----
        app_name = "test_app"
        print(f"Creating application '{app_name}' ...")

        try:
            if requested_template:
                print(f"  -> creating with template: {requested_template!r}")
                app = client.create_app_component(
                    name=app_name,
                    platform=xpfm,
                    domain=domain_name,
                    template=requested_template,
                )
            else:
                print("  -> creating with NO template (minimal app)")
                app = client.create_app_component(
                    name=app_name,
                    platform=xpfm,
                    domain=domain_name,
                )
        except Exception as e:
            if requested_template:
                die(f"Failed to create application using template {requested_template!r}.\n{e}")
            else:
                die(f"Failed to create minimal application (no template).\n{e}")

        # Copy sources into app/src (do NOT delete any existing files)
        app_root = os.path.join(ws_path, app_name)
        app_src  = os.path.join(app_root, "src")
        os.makedirs(app_src, exist_ok=True)
        copied = copy_tree(common_src, app_src)
        print(f"Copied {copied} file(s) into {app_src}")

        # Build the app
        print("Building application...")
        app.build()

        print("\n== DONE ==")
        print(f"Workspace : {ws_path}")
        print(f"Platform  : {plat_name}")
        print(f"Domain    : {domain_name}")
        print(f"App       : {app_name}")
        print(f"Open IDE  : vitis -w {ws_path}")

    finally:
        try:
            client.dispose()
        except Exception:
            pass

if __name__ == "__main__":
    main()
