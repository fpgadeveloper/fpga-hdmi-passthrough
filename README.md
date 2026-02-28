# FPGA HDMI Passthrough Example Design

## Description

This is an FPGA based HDMI input to HDMI output example design.
It is derived from the AMD HDMI example design which is built into Vitis Unified IDE and the AUBoard 
[HDMI Pass-Through Bare Metal Reference Design – 2023.1](https://www.avnet.com/americas/products/avnet-boards/avnet-board-families/auboard-15p-fpga-development-kit/). Kudos to [Adam Taylor](https://www.hackster.io/adam-taylor/4k-at-60hz-not-a-problem-with-the-auboard-b232b6)
for his excellent write-up on porting the AMD design to the AUBoard.

Here it has been updated to version 2025.2 and converted to a scripted form to make it easier to reproduce,
and allow the design to be easily modified and ported to other platforms.

## Requirements

This project is designed for version 2025.2 of the Xilinx tools (Vivado/Vitis/PetaLinux). 
If you are using an older version of the Xilinx tools, then refer to the 
[release tags](https://github.com/fpgadeveloper/fpga-hdmi-passthrough/tags "releases")
to find the version of this repository that matches your version of the tools.

In order to test this design on hardware, you will need the following:

* Vivado 2025.2
* Vitis 2025.2
* 1x HDMI monitor
* 1x HDMI video source
* [AMD HDMI IP license](https://www.amd.com/en/products/adaptive-socs-and-fpgas/intellectual-property/hdmi.html) (eval license available)
* One of the supported target boards listed below

## Target designs

<!-- updater start -->
### FPGA designs

| Target board          | Target design   | Vivado<br> Edition |
|-----------------------|-----------------|--------------------|
| [AUBoard 15P]         | `auboard`       | Standard :free: |

[AUBoard 15P]: https://www.avnet.com/americas/products/avnet-boards/avnet-board-families/auboard-15p-fpga-development-kit/
<!-- updater end -->

### AUBoard board files

The board definition files for the AUBoard are not currently included in the AMD Xilinx Board Store.
To enable Vivado to recognize this board, the required board files have been included in this
repository as a Git submodule (`submodules/avnet-bdf`), which is a fork of
[Avnet's BDF repository](https://github.com/Avnet/bdf). When cloning this repo, use the `--recursive`
flag to ensure the board files are downloaded:

```
git clone --recursive <repo-url>
```

Notes:
1. The Vivado Edition column indicates which designs are supported by the Vivado *Standard* Edition, the
   FREE edition which can be used without a license. Vivado *Enterprise* Edition requires
   a license however a 30-day evaluation license is available from the AMD Xilinx Licensing site.

## Software

This design is driven by a standalone software application.

## Build instructions

This repo contains submodules. To clone this repo, run:
```
git clone --recursive https://github.com/fpgadeveloper/fpga-hdmi-passthrough.git
```

Source Vivado tool:

```
source <path-to-xilinx-tools>/2025.2/Vivado/settings64.sh
```

Build all (Vivado project and Vitis workspace):

```
cd fpga-hdmi-passthrough/Vitis
make workspace TARGET=auboard
```

## Usage instructions

In a UART terminal connected to the target board, a menu will appear with options for driving the design.

## Contribute

We strongly encourage community contribution to these projects. Please make a pull request if you
would like to share your work.

Thank you to everyone who supports us!

## About us

[Opsero Inc.](https://opsero.com "Opsero Inc.") is a team of FPGA developers delivering FPGA products and 
design services to start-ups and tech companies. Follow our blog, 
[FPGA Developer](https://www.fpgadeveloper.com "FPGA Developer"), for news, tutorials and
updates on the awesome projects we work on.


