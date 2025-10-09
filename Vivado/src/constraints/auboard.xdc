##################################
# Constraints for the AUBoard 15P
##################################

# HDMI input (RX)

# HDMI_RCLKOUT_P/N - MGTREFCLK1P/N - M7/M6
set_property PACKAGE_PIN M7 [get_ports HDMI_RX_CLK_P_IN]
create_clock -period 3.367 -name rx_mgt_refclk [get_ports HDMI_RX_CLK_P_IN]

# HDMI_RX_HPD - BANK65 T24
set_property PACKAGE_PIN T24 [get_ports RX_HPD_OUT]
set_property IOSTANDARD LVCMOS12 [get_ports RX_HPD_OUT]

# HDMI_RX_SNK_SCL = BANK65 N26
set_property PACKAGE_PIN N26 [get_ports RX_DDC_OUT_scl_io]
set_property IOSTANDARD LVCMOS12 [get_ports RX_DDC_OUT_scl_io]
set_property DRIVE 8 [get_ports RX_DDC_OUT_scl_io]

# HDMI_CTL_SDA = BANK65 T19
set_property PACKAGE_PIN T19 [get_ports RX_DDC_OUT_sda_io]
set_property IOSTANDARD LVCMOS12 [get_ports RX_DDC_OUT_sda_io]
set_property DRIVE 8 [get_ports RX_DDC_OUT_sda_io]

# HDMI_REC_CLK_P/N - BANK65 P25/P6 (FWD TO CLK GEN)
set_property PACKAGE_PIN P25 [get_ports RX_REFCLK_P_OUT]
set_property IOSTANDARD DIFF_SSTL12 [get_ports RX_REFCLK_P_OUT]

# HDMI_RX_PWR_DET - BANK65 U24
set_property PACKAGE_PIN U24 [get_ports RX_DET_IN]
set_property IOSTANDARD LVCMOS12 [get_ports RX_DET_IN]

# HDMI output (TX)

# CLK_297M_P/N - MGTREFCLK0P/N - P7/P6 (FROM CLK GENERATOR)
set_property PACKAGE_PIN P7 [get_ports TX_REFCLK_P_IN]
create_clock -period 3.367 -name tx_mgt_refclk [get_ports TX_REFCLK_P_IN]

# HDMI_TX_CLK_P/N - BANK65 - T25/U25
set_property PACKAGE_PIN T25 [get_ports HDMI_TX_CLK_P_OUT]
set_property IOSTANDARD DIFF_HSUL_12 [get_ports HDMI_TX_CLK_P_OUT]
set_property OUTPUT_IMPEDANCE RDRV_40_40 [get_ports HDMI_TX_CLK_P_OUT]
set_property SLEW SLOW [get_ports HDMI_TX_CLK_P_OUT]
set_property SLEW SLOW [get_ports HDMI_TX_CLK_N_OUT]

# HDMI_TX_HPD - BANK65 - W21
set_property PACKAGE_PIN W21 [get_ports TX_HPD_IN]
set_property IOSTANDARD LVCMOS12 [get_ports TX_HPD_IN]

# HDMI_TX_SRC_SCL - BANK65 - R25
set_property PACKAGE_PIN R25 [get_ports TX_DDC_OUT_scl_io]
set_property IOSTANDARD LVCMOS12 [get_ports TX_DDC_OUT_scl_io]
set_property DRIVE 8 [get_ports TX_DDC_OUT_scl_io]

# HDMI_TX_SRC_SDA - BANK65 - R26
set_property PACKAGE_PIN R26 [get_ports TX_DDC_OUT_sda_io]
set_property IOSTANDARD LVCMOS12 [get_ports TX_DDC_OUT_sda_io]
set_property DRIVE 8 [get_ports TX_DDC_OUT_sda_io]

# UART

# UART_TX - BANK84 - AF15 (SWAPPED AT TRANSLATOR U23 - MAY NEED CROSSING)
set_property PACKAGE_PIN AF15 [get_ports RS232_UART_txd]
set_property IOSTANDARD LVCMOS18 [get_ports RS232_UART_txd]

# UART_RX - BANK84 - AF14 (SWAPPED AT TRANSLATOR U23 - MAY NEED CROSSING)
set_property PACKAGE_PIN AF14 [get_ports RS232_UART_rxd]
set_property IOSTANDARD LVCMOS18 [get_ports RS232_UART_rxd]

# Misc

# LED1 - BANK85 - A10
set_property PACKAGE_PIN A10 [get_ports LED0]
set_property IOSTANDARD LVCMOS33 [get_ports LED0]

# LED2 - BANK85 - B10 - CLKGEN RESET
set_property PACKAGE_PIN B10 [get_ports {LED1[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {LED1[0]}]

# LED3 - BANK85 - B11 - CLKGEN LOL
set_property PACKAGE_PIN B11 [get_ports LED2]
set_property IOSTANDARD LVCMOS33 [get_ports LED2]

# RST_CLOCK_N - BANK66 - G22 
set_property PACKAGE_PIN G22 [get_ports {IDT_8T49N241_RST_OUT[0]}]
set_property IOSTANDARD LVCMOS12 [get_ports {IDT_8T49N241_RST_OUT[0]}]

# PLL_LOCKED - BANK66 - F22
set_property PACKAGE_PIN F22 [get_ports IDT_8T49N241_LOL_IN]
set_property IOSTANDARD LVCMOS12 [get_ports IDT_8T49N241_LOL_IN]

# HDMI_TX_EN - BANK65 - Y23
set_property PACKAGE_PIN Y23 [get_ports {TX_EN_OUT[0]}]
set_property IOSTANDARD LVCMOS12 [get_ports {TX_EN_OUT[0]}]

# HDMI_TX_CEC - BANK65 - AA23
set_property PACKAGE_PIN AA23 [get_ports {TX_CLKSEL_OUT[0]}]
set_property IOSTANDARD LVCMOS12 [get_ports {TX_CLKSEL_OUT[0]}]

# sys_diff_clock_clk_p/n - SYSCLK_P/N - Bank64 - AD21 / AE21
set_property PACKAGE_PIN AD21 [get_ports sys_diff_clock_clk_p]
set_property IOSTANDARD DIFF_SSTL12 [get_ports sys_diff_clock_clk_p]

# I2C

# HDMI_CTL_SCL - BANK65 - R22
set_property PACKAGE_PIN R22 [get_ports HDMI_CLK_IIC_scl_io]
set_property IOSTANDARD LVCMOS12 [get_ports HDMI_CLK_IIC_scl_io]
set_property DRIVE 8 [get_ports HDMI_CLK_IIC_scl_io]

# HDMI_CTL_SDA - BANK65 -R23
set_property PACKAGE_PIN R23 [get_ports HDMI_CLK_IIC_sda_io]
set_property IOSTANDARD LVCMOS12 [get_ports HDMI_CLK_IIC_sda_io]
set_property DRIVE 8 [get_ports HDMI_CLK_IIC_sda_io]

# SCL_SCLK - BANK85 -B9
set_property PACKAGE_PIN B9 [get_ports GTH_CLK_IIC_scl_io]
set_property IOSTANDARD LVCMOS33 [get_ports GTH_CLK_IIC_scl_io]
set_property DRIVE 8 [get_ports GTH_CLK_IIC_scl_io]

# SDA_nCS - BANK85 - A9
set_property PACKAGE_PIN A9 [get_ports GTH_CLK_IIC_sda_io]
set_property IOSTANDARD LVCMOS33 [get_ports GTH_CLK_IIC_sda_io]
set_property DRIVE 8 [get_ports GTH_CLK_IIC_sda_io]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 31.9 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 4 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
