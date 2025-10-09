# -------------------------------------------------------------------------------------
# Opsero Electronic Design Inc. Copyright 2025
# -------------------------------------------------------------------------------------

# Description
# -----------
# This Tcl script will create Vitis workspace and add a software application for the specified
# target design. If a target design is not specified, the user will be shown a list of target
# designs and asked to make a selection.

# Load functions from the workspace script
source tcl/workspace.tcl

# ----------------------------------------------------------------------------------------------
# Custom parameters
# ----------------------------------------------------------------------------------------------
# The following variables specify how the application should be created (from what 
# template if any), how things should be named and the dictionary of target designs.

# Set the Vivado directory containing the Vivado projects
set vivado_dir_rel "../Vivado"
set d_abs [file join [pwd] $vivado_dir_rel]
set vivado_dir [file normalize $d_abs]

# Set the application name
set app_name "hdmi_passthrough"

# Specify the postfix on the Vivado projects (if one is used)
set vivado_postfix ""

# Set the app template used to create the application
set support_app "empty_application"
set template_app "Empty Application"

# Microblaze designs: Generate combined .bit and .elf file
set mb_combine_bit_elf 1

# Possible targets (board name in lower case for the board.h file)
# UPDATER START
dict set target_dict auboard { auboard_15p }
# UPDATER END

# ----------------------------------------------------------------------------------------------
# Custom modifications functions
# ----------------------------------------------------------------------------------------------
# These functions make custom changes to the platform or standard application template 
# such as modifying files or copying sources into the platform/application.
# These functions are called after creating the platform/application and before build.

# Modifies the linker script such that all sections are relocated to local mem.
# This allows us to store the test application in the bitstream and provide a boot
# file for all the Microblaze designs.
proc linker_script_to_local_mem {linker_filename} {
  set fd [open "${linker_filename}" "r"]
  set file_data [read $fd]
  close $fd

  set local_mem ""
  set mig_mem ""
  
  # Find the local memory name
  set data [split $file_data "\n"]
  foreach line $data {
    if {[str_contains $line "local_memory"]} {
      set words [regexp -all -inline {\S+} $line]
      set local_mem [lindex $words 0]
      break
    }
  }
  
  # Find the MIG memory name
  foreach line $data {
    if {[str_contains $line "ORIGIN"]} {
      if {[str_contains $line "mig"] || [str_contains $line "ddr"]} {
        set words [regexp -all -inline {\S+} $line]
        set mig_mem [lindex $words 0]
        break
      }
    }
  }

  # Write to new linker script and replace MIG references with local mem
  set new_filename "${linker_filename}.txt"
  set fd [open "$new_filename" "w"]
  foreach line $data {
    if {[str_contains $line ">"]} {
      puts $fd [string map "$mig_mem $local_mem" $line]
    } else {
      puts $fd $line
    }
  }
  close $fd

  # Delete the old linker script
  file delete $linker_filename
  
  # Rename new linker script to the old filename
  file rename $new_filename $linker_filename
  
  return 0
}

proc custom_platform_mods {platform_name} {
  # No platform mods required
}

proc custom_app_mods {platform_name app_name workspace_dir} {
  set proc_instance [get_processor_from_platform $platform_name]
  # Copy the application from common/src
  copy-r "common/src" ${workspace_dir}/${app_name}/src
  # For Microblaze designs, modify the linker script to put
  # all sections in local mem
  # For Zynq designs, modify linker script to put all sections in DDR
  if {[str_contains $proc_instance "microblaze"]} {
    linker_script_to_local_mem ${workspace_dir}/${app_name}/src/lscript.ld
  }
}

# ----------------------------------------------------------------------------------------------
# End of custom sections
# ----------------------------------------------------------------------------------------------

# Target can be specified by creating the target variable before sourcing, or in the command line arguments
if { [info exists target] } {
  if { ![dict exists $target_dict $target] } {
    puts "Invalid target specified: $target"
    exit 1
  }
} elseif { $argc == 0 } {
  set target [select_target $target_dict]
} else {
  set target [lindex $argv 0]
  if { ![dict exists $target_dict $target] } {
    puts "Invalid target specified: $target"
    exit 1
  }
}

# At this point of the script, we are guaranteed to have a valid target
# The Vitis workspace directory name
set current_dir [pwd]
set workspace_dir [file join $current_dir "${target}_workspace"]

# Create the Vitis workspace
puts "Creating the Vitis workspace: $workspace_dir"
create_vitis_ws $workspace_dir $target $target_dict $vivado_dir $app_name $support_app $template_app


