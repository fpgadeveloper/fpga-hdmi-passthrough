# FPGA HDMI Passthrough Example Design

## Description

This is an FPGA based HDMI input to HDMI output example design.
It is derived from the AUBoard 
[HDMI Pass-Through Bare Metal Reference Design – 2023.1](https://www.avnet.com/americas/products/avnet-boards/avnet-board-families/auboard-15p-fpga-development-kit/).
Here it has been updated to version 2024.1 and converted to a scripted form for improved reproducibility,
source control and support for other platforms.

## Requirements

This project is designed for version 2024.1 of the Xilinx tools (Vivado/Vitis/PetaLinux). 
If you are using an older version of the Xilinx tools, then refer to the 
[release tags](https://github.com/fpgadeveloper/rpi-camera-fmc/tags "releases")
to find the version of this repository that matches your version of the tools.

In order to test this design on hardware, you will need the following:

* Vivado 2024.1
* Vitis 2024.1
* Linux PC for build
* 1x HDMI monitor
* 1x HDMI video source
* One of the supported target boards listed below

## Target designs

<!-- updater start -->
### FPGA designs

| Target board          | Target design   | FMC Slot | Cameras | VCU   | Vivado<br> Edition |
|-----------------------|-----------------|----------|---------|-------|-------|
| [AUBoard 15P]         | `auboard`       | HPC      | 1     | :x:                | Standard :free: |

### Zynq UltraScale+ designs

| Target board          | Target design   | FMC Slot | Cameras | VCU   | Vivado<br> Edition |
|-----------------------|-----------------|----------|---------|-------|-------|
| [ZCU104]              | `zcu104`        | LPC      | 4     | :white_check_mark: | Standard :free: |
| [ZCU102]              | `zcu102_hpc0`   | HPC0     | 4     | :x:                | Standard :free: |
| [ZCU102]              | `zcu102_hpc1`   | HPC1     | 2     | :x:                | Standard :free: |
| [ZCU106]              | `zcu106_hpc0`   | HPC0     | 4     | :white_check_mark: | Standard :free: |
| [PYNQ-ZU]             | `pynqzu`        | LPC      | 2     | :x:                | Standard :free: |
| [UltraZed-EV Carrier] | `uzev`          | HPC      | 4     | :white_check_mark: | Standard :free: |

[AUBoard 15P]: https://www.avnet.com/americas/products/avnet-boards/avnet-board-families/auboard-15p-fpga-development-kit/
[ZCU104]: https://www.xilinx.com/zcu104
[ZCU102]: https://www.xilinx.com/zcu102
[ZCU106]: https://www.xilinx.com/zcu106
[PYNQ-ZU]: https://www.amd.com/en/corporate/university-program/aup-boards/pynq-zu.html
[UltraZed-EV Carrier]: https://www.xilinx.com/products/boards-and-kits/1-1s78dxb.html
<!-- updater end -->

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
source <path-to-vivado>/2024.1/settings64.sh
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


