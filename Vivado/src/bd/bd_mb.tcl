################################################################
# Block diagram build script for MicroBlaze designs
################################################################

# CHECKING IF PROJECT EXISTS
if { [get_projects -quiet] eq "" } {
   puts "ERROR: Please open or create a project!"
   return 1
}

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

create_bd_design $block_name

current_bd_design $block_name

set parentCell [get_bd_cells /]

# Get object for parentCell
set parentObj [get_bd_cells $parentCell]
if { $parentObj == "" } {
   puts "ERROR: Unable to find parent cell <$parentCell>!"
   return
}

# Make sure parentObj is hier blk
set parentType [get_property TYPE $parentObj]
if { $parentType ne "hier" } {
   puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
   return
}

# Save current instance; Restore later
set oldCurInst [current_bd_instance .]

# Set parent object as current
current_bd_instance $parentObj

# Hierarchical cell: audio_ss_0
proc create_hier_cell_audio_ss_0 { } {

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier audio_ss_0]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 axis_audio_in

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 axis_audio_out


  # Create pins
  create_bd_pin -dir I -type clk ACLK
  create_bd_pin -dir I -type rst ARESETN
  create_bd_pin -dir I -type clk hdmi_clk
  create_bd_pin -dir I -from 19 -to 0 aud_acr_cts_in
  create_bd_pin -dir I -from 19 -to 0 aud_acr_n_in
  create_bd_pin -dir I aud_acr_valid_in
  create_bd_pin -dir O -from 19 -to 0 aud_acr_cts_out
  create_bd_pin -dir O -from 19 -to 0 aud_acr_n_out
  create_bd_pin -dir O aud_acr_valid_out
  create_bd_pin -dir O -type rst aud_rstn
  create_bd_pin -dir O -type clk audio_clk

  # Create instance: aud_pat_gen, and set properties
  set aud_pat_gen [ create_bd_cell -type ip -vlnv xilinx.com:ip:aud_pat_gen:1.0 aud_pat_gen ]

  # Create instance: axi_interconnect, and set properties
  set axi_interconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect ]
  set_property CONFIG.NUM_MI {3} $axi_interconnect


  # Create instance: clk_wiz, and set properties
  set clk_wiz [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz ]
  set_property -dict [list \
    CONFIG.AUTO_PRIMITIVE {PLL} \
    CONFIG.CLKOUT1_DRIVES {Buffer} \
    CONFIG.CLKOUT1_JITTER {144.719} \
    CONFIG.CLKOUT1_PHASE_ERROR {114.212} \
    CONFIG.CLKOUT2_DRIVES {Buffer} \
    CONFIG.CLKOUT3_DRIVES {Buffer} \
    CONFIG.CLKOUT4_DRIVES {Buffer} \
    CONFIG.CLKOUT5_DRIVES {Buffer} \
    CONFIG.CLKOUT6_DRIVES {Buffer} \
    CONFIG.CLKOUT7_DRIVES {Buffer} \
    CONFIG.FEEDBACK_SOURCE {FDBK_AUTO} \
    CONFIG.MMCM_BANDWIDTH {OPTIMIZED} \
    CONFIG.MMCM_CLKFBOUT_MULT_F {8} \
    CONFIG.MMCM_CLKOUT0_DIVIDE_F {8} \
    CONFIG.MMCM_COMPENSATION {AUTO} \
    CONFIG.OPTIMIZE_CLOCKING_STRUCTURE_EN {false} \
    CONFIG.PRIMITIVE {Auto} \
    CONFIG.PRIM_SOURCE {No_buffer} \
    CONFIG.USE_DYN_RECONFIG {true} \
    CONFIG.USE_LOCKED {true} \
    CONFIG.USE_RESET {true} \
  ] $clk_wiz


  # Create instance: hdmi_acr_ctrl, and set properties
  set hdmi_acr_ctrl [ create_bd_cell -type ip -vlnv xilinx.com:ip:hdmi_acr_ctrl:1.0 hdmi_acr_ctrl ]
  set_property -dict [list \
    CONFIG.C_EXDES_TOPOLOGY {0} \
    CONFIG.C_HDMI_VERSION {0} \
  ] $hdmi_acr_ctrl


  # Create interface connections
  connect_bd_intf_net -intf_net intf_net_aud_pat_gen_axis_audio_out [get_bd_intf_pins aud_pat_gen/axis_audio_out] [get_bd_intf_pins axis_audio_out]
  connect_bd_intf_net -intf_net intf_net_axi_interconnect_M00_AXI [get_bd_intf_pins axi_interconnect/M00_AXI] [get_bd_intf_pins aud_pat_gen/axi]
  connect_bd_intf_net -intf_net intf_net_axi_interconnect_M01_AXI [get_bd_intf_pins axi_interconnect/M01_AXI] [get_bd_intf_pins hdmi_acr_ctrl/axi]
  connect_bd_intf_net -intf_net intf_net_axi_interconnect_M02_AXI [get_bd_intf_pins axi_interconnect/M02_AXI] [get_bd_intf_pins clk_wiz/s_axi_lite]
  connect_bd_intf_net -intf_net intf_net_bdry_in_S00_AXI [get_bd_intf_pins S00_AXI] [get_bd_intf_pins axi_interconnect/S00_AXI]
  connect_bd_intf_net -intf_net intf_net_bdry_in_axis_audio_in [get_bd_intf_pins axis_audio_in] [get_bd_intf_pins aud_pat_gen/axis_audio_in]

  # Create port connections
  connect_bd_net -net net_bdry_in_ACLK [get_bd_pins ACLK] [get_bd_pins aud_pat_gen/axi_aclk] [get_bd_pins axi_interconnect/ACLK] [get_bd_pins axi_interconnect/S00_ACLK] [get_bd_pins axi_interconnect/M00_ACLK] [get_bd_pins axi_interconnect/M01_ACLK] [get_bd_pins axi_interconnect/M02_ACLK] [get_bd_pins clk_wiz/s_axi_aclk] [get_bd_pins clk_wiz/clk_in1] [get_bd_pins hdmi_acr_ctrl/axi_aclk]
  connect_bd_net -net net_bdry_in_ARESETN [get_bd_pins ARESETN] [get_bd_pins aud_pat_gen/axi_aresetn] [get_bd_pins axi_interconnect/ARESETN] [get_bd_pins axi_interconnect/S00_ARESETN] [get_bd_pins axi_interconnect/M00_ARESETN] [get_bd_pins axi_interconnect/M01_ARESETN] [get_bd_pins axi_interconnect/M02_ARESETN] [get_bd_pins clk_wiz/s_axi_aresetn] [get_bd_pins hdmi_acr_ctrl/axi_aresetn]
  connect_bd_net -net net_bdry_in_aud_acr_cts_in [get_bd_pins aud_acr_cts_in] [get_bd_pins hdmi_acr_ctrl/aud_acr_cts_in]
  connect_bd_net -net net_bdry_in_aud_acr_n_in [get_bd_pins aud_acr_n_in] [get_bd_pins hdmi_acr_ctrl/aud_acr_n_in]
  connect_bd_net -net net_bdry_in_aud_acr_valid_in [get_bd_pins aud_acr_valid_in] [get_bd_pins hdmi_acr_ctrl/aud_acr_valid_in]
  connect_bd_net -net net_bdry_in_hdmi_clk [get_bd_pins hdmi_clk] [get_bd_pins hdmi_acr_ctrl/hdmi_clk]
  connect_bd_net -net net_clk_wiz_clk_out1 [get_bd_pins clk_wiz/clk_out1] [get_bd_pins audio_clk] [get_bd_pins aud_pat_gen/aud_clk] [get_bd_pins aud_pat_gen/axis_clk] [get_bd_pins hdmi_acr_ctrl/aud_clk]
  connect_bd_net -net net_hdmi_acr_ctrl_aud_acr_cts_out [get_bd_pins hdmi_acr_ctrl/aud_acr_cts_out] [get_bd_pins aud_acr_cts_out]
  connect_bd_net -net net_hdmi_acr_ctrl_aud_acr_n_out [get_bd_pins hdmi_acr_ctrl/aud_acr_n_out] [get_bd_pins aud_acr_n_out]
  connect_bd_net -net net_hdmi_acr_ctrl_aud_acr_valid_out [get_bd_pins hdmi_acr_ctrl/aud_acr_valid_out] [get_bd_pins aud_acr_valid_out]
  connect_bd_net -net net_hdmi_acr_ctrl_aud_resetn_out [get_bd_pins hdmi_acr_ctrl/aud_resetn_out] [get_bd_pins aud_rstn] [get_bd_pins aud_pat_gen/axis_resetn]

  # Restore current instance
  current_bd_instance \
}

# Hierarchical cell: v_tpg_ss_0
proc create_hier_cell_v_tpg_ss_0 { } {

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier v_tpg_ss_0]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_TPG

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_GPIO

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 m_axis_video

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 s_axis_video


  # Create pins
  create_bd_pin -dir I -type clk ap_clk
  create_bd_pin -dir I -type rst m_axi_aresetn

  # Create instance: axi_gpio, and set properties
  set axi_gpio [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_GPIO_WIDTH {1} \
  ] $axi_gpio


  # Create instance: v_tpg, and set properties
  set v_tpg [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_tpg:8.2 v_tpg ]
  set_property -dict [list \
    CONFIG.COLOR_SWEEP {0} \
    CONFIG.DISPLAY_PORT {0} \
    CONFIG.FOREGROUND {0} \
    CONFIG.HAS_AXI4S_SLAVE {1} \
    CONFIG.MAX_DATA_WIDTH {8} \
    CONFIG.RAMP {0} \
    CONFIG.SAMPLES_PER_CLOCK {2} \
    CONFIG.SOLID_COLOR {0} \
    CONFIG.ZONE_PLATE {0} \
  ] $v_tpg


  # Create interface connections
  connect_bd_intf_net -intf_net intf_net_bdry_in_S_AXI_GPIO [get_bd_intf_pins S_AXI_GPIO] [get_bd_intf_pins axi_gpio/S_AXI]
  connect_bd_intf_net -intf_net intf_net_bdry_in_S_AXI_TPG [get_bd_intf_pins S_AXI_TPG] [get_bd_intf_pins v_tpg/s_axi_CTRL]
  connect_bd_intf_net -intf_net intf_net_bdry_in_s_axis_video [get_bd_intf_pins s_axis_video] [get_bd_intf_pins v_tpg/s_axis_video]
  connect_bd_intf_net -intf_net intf_net_v_tpg_m_axis_video [get_bd_intf_pins v_tpg/m_axis_video] [get_bd_intf_pins m_axis_video]

  # Create port connections
  connect_bd_net -net net_axi_gpio_gpio_io_o [get_bd_pins axi_gpio/gpio_io_o] [get_bd_pins v_tpg/ap_rst_n]
  connect_bd_net -net net_bdry_in_ap_clk [get_bd_pins ap_clk] [get_bd_pins axi_gpio/s_axi_aclk] [get_bd_pins v_tpg/ap_clk]
  connect_bd_net -net net_bdry_in_m_axi_aresetn [get_bd_pins m_axi_aresetn] [get_bd_pins axi_gpio/s_axi_aresetn]

  # Restore current instance
  current_bd_instance \
}


# Create interface ports
set HDMI_CLK_IIC [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 HDMI_CLK_IIC ]

set TX_DDC_OUT [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 TX_DDC_OUT ]

set RX_DDC_OUT [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 RX_DDC_OUT ]

set sys_diff_clock [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 sys_diff_clock ]
set_property -dict [ list \
 CONFIG.FREQ_HZ {300000000} \
 ] $sys_diff_clock

set RS232_UART [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 RS232_UART ]

set GTH_CLK_IIC [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:iic_rtl:1.0 GTH_CLK_IIC ]


# Create ports
set TX_HPD_IN [ create_bd_port -dir I TX_HPD_IN ]
set RX_DET_IN [ create_bd_port -dir I RX_DET_IN ]
set HDMI_TX_CLK_P_OUT [ create_bd_port -dir O HDMI_TX_CLK_P_OUT ]
set HDMI_TX_CLK_N_OUT [ create_bd_port -dir O HDMI_TX_CLK_N_OUT ]
set HDMI_TX_DAT_P_OUT [ create_bd_port -dir O -from 2 -to 0 HDMI_TX_DAT_P_OUT ]
set HDMI_TX_DAT_N_OUT [ create_bd_port -dir O -from 2 -to 0 HDMI_TX_DAT_N_OUT ]
set HDMI_RX_DAT_P_IN [ create_bd_port -dir I -from 2 -to 0 HDMI_RX_DAT_P_IN ]
set HDMI_RX_DAT_N_IN [ create_bd_port -dir I -from 2 -to 0 HDMI_RX_DAT_N_IN ]
set RX_REFCLK_P_OUT [ create_bd_port -dir O RX_REFCLK_P_OUT ]
set RX_REFCLK_N_OUT [ create_bd_port -dir O RX_REFCLK_N_OUT ]
set reset [ create_bd_port -dir I -type rst reset ]
set_property -dict [ list \
 CONFIG.POLARITY {ACTIVE_HIGH} \
] $reset
set IDT_8T49N241_LOL_IN [ create_bd_port -dir I IDT_8T49N241_LOL_IN ]
set TX_CLKSEL_OUT [ create_bd_port -dir O -from 0 -to 0 TX_CLKSEL_OUT ]
set LED0 [ create_bd_port -dir O LED0 ]
set TX_EN_OUT [ create_bd_port -dir O -from 0 -to 0 TX_EN_OUT ]
set TX_REFCLK_P_IN [ create_bd_port -dir I -type clk TX_REFCLK_P_IN ]
set TX_REFCLK_N_IN [ create_bd_port -dir I -type clk TX_REFCLK_N_IN ]
set HDMI_RX_CLK_P_IN [ create_bd_port -dir I -type clk HDMI_RX_CLK_P_IN ]
set HDMI_RX_CLK_N_IN [ create_bd_port -dir I -type clk HDMI_RX_CLK_N_IN ]
set RX_HPD_OUT [ create_bd_port -dir O -from 0 -to 0 RX_HPD_OUT ]
set LED1 [ create_bd_port -dir O -from 0 -to 0 LED1 ]
set LED2 [ create_bd_port -dir O LED2 ]
set IDT_8T49N241_RST_OUT [ create_bd_port -dir O -from 0 -to 0 -type rst IDT_8T49N241_RST_OUT ]

# Create instance: v_tpg_ss_0
create_hier_cell_v_tpg_ss_0

# Create instance: audio_ss_0
create_hier_cell_audio_ss_0

# Create instance: rx_video_axis_reg_slice, and set properties
set rx_video_axis_reg_slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_register_slice:1.1 rx_video_axis_reg_slice ]

# Create instance: tx_video_axis_reg_slice, and set properties
set tx_video_axis_reg_slice [ create_bd_cell -type ip -vlnv xilinx.com:ip:axis_register_slice:1.1 tx_video_axis_reg_slice ]

# Create instance: v_hdmi_rx_ss, and set properties
set v_hdmi_rx_ss [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_hdmi_rx_ss:3.2 v_hdmi_rx_ss ]
set_property -dict [list \
  CONFIG.C_ADDR_WIDTH {10} \
  CONFIG.C_ADD_MARK_DBG {0} \
  CONFIG.C_CD_INVERT {true} \
  CONFIG.C_EDID_RAM_SIZE {256} \
  CONFIG.C_EXDES_AXILITE_FREQ {100} \
  CONFIG.C_EXDES_NIDRU {false} \
  CONFIG.C_EXDES_RX_PLL_SELECTION {0} \
  CONFIG.C_EXDES_TOPOLOGY {0} \
  CONFIG.C_HDMI_FAST_SWITCH {true} \
  CONFIG.C_HPD_INVERT {false} \
  CONFIG.C_INCLUDE_HDCP_1_4 {false} \
  CONFIG.C_INCLUDE_HDCP_2_2 {false} \
  CONFIG.C_INCLUDE_LOW_RESO_VID {true} \
  CONFIG.C_INCLUDE_YUV420_SUP {true} \
  CONFIG.C_INPUT_PIXELS_PER_CLOCK {2} \
  CONFIG.C_MAX_BITS_PER_COMPONENT {8} \
  CONFIG.C_VALIDATION_ENABLE {false} \
  CONFIG.C_VID_INTERFACE {0} \
] $v_hdmi_rx_ss


# Create instance: v_hdmi_tx_ss, and set properties
set v_hdmi_tx_ss [ create_bd_cell -type ip -vlnv xilinx.com:ip:v_hdmi_tx_ss:3.2 v_hdmi_tx_ss ]
set_property -dict [list \
  CONFIG.C_ADDR_WIDTH {10} \
  CONFIG.C_ADD_MARK_DBG {0} \
  CONFIG.C_EXDES_NIDRU {false} \
  CONFIG.C_EXDES_RX_PLL_SELECTION {0} \
  CONFIG.C_HDMI_FAST_SWITCH {true} \
  CONFIG.C_HPD_INVERT {false} \
  CONFIG.C_HYSTERESIS_LEVEL {12} \
  CONFIG.C_INCLUDE_HDCP_1_4 {false} \
  CONFIG.C_INCLUDE_HDCP_2_2 {false} \
  CONFIG.C_INCLUDE_LOW_RESO_VID {true} \
  CONFIG.C_INCLUDE_YUV420_SUP {true} \
  CONFIG.C_INPUT_PIXELS_PER_CLOCK {2} \
  CONFIG.C_MAX_BITS_PER_COMPONENT {8} \
  CONFIG.C_VALIDATION_ENABLE {false} \
  CONFIG.C_VID_INTERFACE {0} \
] $v_hdmi_tx_ss


# Create instance: vcc_const, and set properties
set vcc_const [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 vcc_const ]
set_property CONFIG.CONST_VAL {1} $vcc_const


# Create instance: vid_phy_controller, and set properties
set vid_phy_controller [ create_bd_cell -type ip -vlnv xilinx.com:ip:vid_phy_controller:2.2 vid_phy_controller ]
set_property -dict [list \
  CONFIG.Adv_Clk_Mode {false} \
  CONFIG.CHANNEL_ENABLE {X0Y8 X0Y9 X0Y10} \
  CONFIG.CHANNEL_SITE {X0Y8} \
  CONFIG.C_FOR_UPGRADE_ARCHITECTURE {virtexuplus} \
  CONFIG.C_FOR_UPGRADE_DEVICE {xcvu9p} \
  CONFIG.C_FOR_UPGRADE_PACKAGE {flga2104} \
  CONFIG.C_FOR_UPGRADE_PART {xcvu9p-flga2104-2L-e} \
  CONFIG.C_FOR_UPGRADE_SPEEDGRADE {-2L} \
  CONFIG.C_INPUT_PIXELS_PER_CLOCK {2} \
  CONFIG.C_INT_HDMI_VER_CMPTBLE {3} \
  CONFIG.C_NIDRU {false} \
  CONFIG.C_RX_PLL_SELECTION {0} \
  CONFIG.C_RX_REFCLK_SEL {1} \
  CONFIG.C_Rx_Clk_Primitive {1} \
  CONFIG.C_Rx_Protocol {HDMI} \
  CONFIG.C_TX_PLL_SELECTION {6} \
  CONFIG.C_TX_REFCLK_SEL {0} \
  CONFIG.C_Tx_Clk_Primitive {1} \
  CONFIG.C_Tx_Protocol {HDMI} \
  CONFIG.C_Txrefclk_Rdy_Invert {true} \
  CONFIG.C_Use_Oddr_for_Tmds_Clkout {true} \
  CONFIG.C_vid_phy_rx_axi4s_ch_INT_TDATA_WIDTH {20} \
  CONFIG.C_vid_phy_rx_axi4s_ch_TDATA_WIDTH {20} \
  CONFIG.C_vid_phy_rx_axi4s_ch_TUSER_WIDTH {1} \
  CONFIG.C_vid_phy_tx_axi4s_ch_INT_TDATA_WIDTH {20} \
  CONFIG.C_vid_phy_tx_axi4s_ch_TDATA_WIDTH {20} \
  CONFIG.C_vid_phy_tx_axi4s_ch_TUSER_WIDTH {1} \
  CONFIG.Rx_GT_Line_Rate {5.94} \
  CONFIG.Rx_GT_Ref_Clock_Freq {297} \
  CONFIG.Transceiver {GTHE4} \
  CONFIG.Tx_GT_Line_Rate {5.94} \
  CONFIG.Tx_GT_Ref_Clock_Freq {297} \
] $vid_phy_controller


# Create instance: axi_intc, and set properties
set axi_intc [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_intc:4.1 axi_intc ]

# Create instance: axi_interconnect, and set properties
set axi_interconnect [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect ]
set_property CONFIG.NUM_MI {10} $axi_interconnect


# Create instance: axi_uartlite, and set properties
set axi_uartlite [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uartlite:2.0 axi_uartlite ]
set_property -dict [list \
  CONFIG.C_BAUDRATE {115200} \
  CONFIG.UARTLITE_BOARD_INTERFACE {Custom} \
  CONFIG.USE_BOARD_FLOW {true} \
] $axi_uartlite


# Create instance: clk_wiz, and set properties
set clk_wiz [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz ]
set_property -dict [list \
  CONFIG.CLKIN1_JITTER_PS {33.330000000000005} \
  CONFIG.CLKOUT1_JITTER {81.814} \
  CONFIG.CLKOUT1_PHASE_ERROR {77.836} \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {300} \
  CONFIG.CLKOUT2_JITTER {101.475} \
  CONFIG.CLKOUT2_PHASE_ERROR {77.836} \
  CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {100} \
  CONFIG.CLKOUT2_USED {true} \
  CONFIG.CLKOUT3_JITTER {198.524} \
  CONFIG.CLKOUT3_PHASE_ERROR {313.647} \
  CONFIG.CLKOUT3_REQUESTED_OUT_FREQ {100.000} \
  CONFIG.CLKOUT3_USED {false} \
  CONFIG.CLK_IN1_BOARD_INTERFACE {Custom} \
  CONFIG.MMCM_CLKFBOUT_MULT_F {4.000} \
  CONFIG.MMCM_CLKIN1_PERIOD {3.333} \
  CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
  CONFIG.MMCM_CLKOUT0_DIVIDE_F {4.000} \
  CONFIG.MMCM_CLKOUT1_DIVIDE {12} \
  CONFIG.MMCM_CLKOUT2_DIVIDE {1} \
  CONFIG.MMCM_DIVCLK_DIVIDE {1} \
  CONFIG.NUM_OUT_CLKS {2} \
  CONFIG.PRIM_IN_FREQ {300} \
  CONFIG.PRIM_SOURCE {Differential_clock_capable_pin} \
  CONFIG.RESET_BOARD_INTERFACE {Custom} \
] $clk_wiz


# Create instance: dlmb_bram_if_cntlr, and set properties
set dlmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 dlmb_bram_if_cntlr ]
set_property CONFIG.C_ECC {0} $dlmb_bram_if_cntlr


# Create instance: dlmb_v10, and set properties
set dlmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 dlmb_v10 ]
set_property CONFIG.C_LMB_NUM_SLAVES {1} $dlmb_v10


# Create instance: axi_iic_0, and set properties
set axi_iic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic:2.1 axi_iic_0 ]
set_property -dict [list \
  CONFIG.IIC_BOARD_INTERFACE {Custom} \
  CONFIG.USE_BOARD_FLOW {true} \
] $axi_iic_0


# Create instance: ilmb_bram_if_cntlr, and set properties
set ilmb_bram_if_cntlr [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_bram_if_cntlr:4.0 ilmb_bram_if_cntlr ]
set_property CONFIG.C_ECC {0} $ilmb_bram_if_cntlr


# Create instance: ilmb_v10, and set properties
set ilmb_v10 [ create_bd_cell -type ip -vlnv xilinx.com:ip:lmb_v10:3.0 ilmb_v10 ]
set_property CONFIG.C_LMB_NUM_SLAVES {1} $ilmb_v10


# Create instance: lmb_bram, and set properties
set lmb_bram [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 lmb_bram ]
set_property -dict [list \
  CONFIG.Enable_B {Use_ENB_Pin} \
  CONFIG.Memory_Type {True_Dual_Port_RAM} \
  CONFIG.Port_B_Clock {100} \
  CONFIG.Port_B_Enable_Rate {100} \
  CONFIG.Port_B_Write_Rate {50} \
  CONFIG.Use_RSTB_Pin {true} \
  CONFIG.use_bram_block {BRAM_Controller} \
] $lmb_bram


# Create instance: mblaze, and set properties
set mblaze [ create_bd_cell -type ip -vlnv xilinx.com:ip:microblaze:11.0 mblaze ]
set_property -dict [list \
  CONFIG.C_DEBUG_ENABLED {1} \
  CONFIG.C_D_AXI {1} \
  CONFIG.C_D_LMB {1} \
  CONFIG.C_I_AXI {0} \
  CONFIG.C_I_LMB {1} \
] $mblaze


# Create instance: mdm, and set properties
set mdm [ create_bd_cell -type ip -vlnv xilinx.com:ip:mdm:3.2 mdm ]

# Create instance: rst_processor_1_100M, and set properties
set rst_processor_1_100M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_processor_1_100M ]
set_property -dict [list \
  CONFIG.RESET_BOARD_INTERFACE {Custom} \
  CONFIG.USE_BOARD_FLOW {false} \
] $rst_processor_1_100M


# Create instance: rst_processor_1_300M, and set properties
set rst_processor_1_300M [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 rst_processor_1_300M ]
set_property -dict [list \
  CONFIG.RESET_BOARD_INTERFACE {Custom} \
  CONFIG.USE_BOARD_FLOW {false} \
] $rst_processor_1_300M


# Create instance: xlconcat, and set properties
set xlconcat [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat ]
set_property CONFIG.NUM_PORTS {3} $xlconcat


# Create instance: axi_iic_1, and set properties
set axi_iic_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic:2.1 axi_iic_1 ]
set_property -dict [list \
  CONFIG.IIC_BOARD_INTERFACE {Custom} \
  CONFIG.USE_BOARD_FLOW {true} \
] $axi_iic_1


# Create interface connections
connect_bd_intf_net -intf_net axi_interconnect_M09_AXI [get_bd_intf_pins axi_interconnect/M09_AXI] [get_bd_intf_pins axi_iic_1/S_AXI]
connect_bd_intf_net -intf_net intf_net_audio_ss_0_axis_audio_out [get_bd_intf_pins audio_ss_0/axis_audio_out] [get_bd_intf_pins v_hdmi_tx_ss/AUDIO_IN]
connect_bd_intf_net -intf_net intf_net_axi_intc_interrupt [get_bd_intf_pins axi_intc/interrupt] [get_bd_intf_pins mblaze/INTERRUPT]
connect_bd_intf_net -intf_net intf_net_axi_interconnect_M03_AXI [get_bd_intf_pins axi_interconnect/M03_AXI] [get_bd_intf_pins axi_uartlite/S_AXI]
connect_bd_intf_net -intf_net intf_net_axi_interconnect_M04_AXI [get_bd_intf_pins axi_interconnect/M04_AXI] [get_bd_intf_pins axi_iic_0/S_AXI]
connect_bd_intf_net -intf_net intf_net_axi_interconnect_M07_AXI [get_bd_intf_pins axi_interconnect/M07_AXI] [get_bd_intf_pins axi_intc/s_axi]
connect_bd_intf_net -intf_net intf_net_bdry_in_sys_diff_clock [get_bd_intf_ports sys_diff_clock] [get_bd_intf_pins clk_wiz/CLK_IN1_D]
connect_bd_intf_net -intf_net intf_net_dlmb_bram_if_cntlr_BRAM_PORT [get_bd_intf_pins dlmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTA]
connect_bd_intf_net -intf_net intf_net_dlmb_v10_LMB_Sl_0 [get_bd_intf_pins dlmb_v10/LMB_Sl_0] [get_bd_intf_pins dlmb_bram_if_cntlr/SLMB]
connect_bd_intf_net -intf_net intf_net_ilmb_bram_if_cntlr_BRAM_PORT [get_bd_intf_pins ilmb_bram_if_cntlr/BRAM_PORT] [get_bd_intf_pins lmb_bram/BRAM_PORTB]
connect_bd_intf_net -intf_net intf_net_ilmb_v10_LMB_Sl_0 [get_bd_intf_pins ilmb_v10/LMB_Sl_0] [get_bd_intf_pins ilmb_bram_if_cntlr/SLMB]
connect_bd_intf_net -intf_net intf_net_mb_ss_0_IIC [get_bd_intf_pins axi_iic_0/IIC] [get_bd_intf_ports HDMI_CLK_IIC]
connect_bd_intf_net -intf_net intf_net_mb_ss_0_M00_AXI [get_bd_intf_pins axi_interconnect/M00_AXI] [get_bd_intf_pins vid_phy_controller/vid_phy_axi4lite]
connect_bd_intf_net -intf_net intf_net_mb_ss_0_M01_AXI [get_bd_intf_pins axi_interconnect/M01_AXI] [get_bd_intf_pins v_hdmi_rx_ss/S_AXI_CPU_IN]
connect_bd_intf_net -intf_net intf_net_mb_ss_0_M02_AXI [get_bd_intf_pins axi_interconnect/M02_AXI] [get_bd_intf_pins v_hdmi_tx_ss/S_AXI_CPU_IN]
connect_bd_intf_net -intf_net intf_net_mb_ss_0_M05_AXI [get_bd_intf_pins axi_interconnect/M05_AXI] [get_bd_intf_pins v_tpg_ss_0/S_AXI_TPG]
connect_bd_intf_net -intf_net intf_net_mb_ss_0_M06_AXI [get_bd_intf_pins axi_interconnect/M06_AXI] [get_bd_intf_pins audio_ss_0/S00_AXI]
connect_bd_intf_net -intf_net intf_net_mb_ss_0_M08_AXI [get_bd_intf_pins axi_interconnect/M08_AXI] [get_bd_intf_pins v_tpg_ss_0/S_AXI_GPIO]
connect_bd_intf_net -intf_net intf_net_mb_ss_0_UART [get_bd_intf_pins axi_uartlite/UART] [get_bd_intf_ports RS232_UART]
connect_bd_intf_net -intf_net intf_net_mblaze_DLMB [get_bd_intf_pins mblaze/DLMB] [get_bd_intf_pins dlmb_v10/LMB_M]
connect_bd_intf_net -intf_net intf_net_mblaze_ILMB [get_bd_intf_pins mblaze/ILMB] [get_bd_intf_pins ilmb_v10/LMB_M]
connect_bd_intf_net -intf_net intf_net_mblaze_M_AXI_DP [get_bd_intf_pins mblaze/M_AXI_DP] [get_bd_intf_pins axi_interconnect/S00_AXI]
connect_bd_intf_net -intf_net intf_net_mdm_MBDEBUG_0 [get_bd_intf_pins mdm/MBDEBUG_0] [get_bd_intf_pins mblaze/DEBUG]
connect_bd_intf_net -intf_net intf_net_rx_video_axis_reg_slice_M_AXIS [get_bd_intf_pins rx_video_axis_reg_slice/M_AXIS] [get_bd_intf_pins v_tpg_ss_0/s_axis_video]
connect_bd_intf_net -intf_net intf_net_tx_video_axis_reg_slice_M_AXIS [get_bd_intf_pins tx_video_axis_reg_slice/M_AXIS] [get_bd_intf_pins v_hdmi_tx_ss/VIDEO_IN]
connect_bd_intf_net -intf_net intf_net_v_hdmi_rx_ss_AUDIO_OUT [get_bd_intf_pins v_hdmi_rx_ss/AUDIO_OUT] [get_bd_intf_pins audio_ss_0/axis_audio_in]
connect_bd_intf_net -intf_net intf_net_v_hdmi_rx_ss_DDC_OUT [get_bd_intf_pins v_hdmi_rx_ss/DDC_OUT] [get_bd_intf_ports RX_DDC_OUT]
connect_bd_intf_net -intf_net intf_net_v_hdmi_rx_ss_VIDEO_OUT [get_bd_intf_pins v_hdmi_rx_ss/VIDEO_OUT] [get_bd_intf_pins rx_video_axis_reg_slice/S_AXIS]
connect_bd_intf_net -intf_net intf_net_v_hdmi_tx_ss_DDC_OUT [get_bd_intf_pins v_hdmi_tx_ss/DDC_OUT] [get_bd_intf_ports TX_DDC_OUT]
connect_bd_intf_net -intf_net intf_net_v_hdmi_tx_ss_LINK_DATA0_OUT [get_bd_intf_pins v_hdmi_tx_ss/LINK_DATA0_OUT] [get_bd_intf_pins vid_phy_controller/vid_phy_tx_axi4s_ch0]
connect_bd_intf_net -intf_net intf_net_v_tpg_ss_0_m_axis_video [get_bd_intf_pins v_tpg_ss_0/m_axis_video] [get_bd_intf_pins tx_video_axis_reg_slice/S_AXIS]
connect_bd_intf_net -intf_net intf_net_vid_phy_controller_vid_phy_rx_axi4s_ch0 [get_bd_intf_pins vid_phy_controller/vid_phy_rx_axi4s_ch0] [get_bd_intf_pins v_hdmi_rx_ss/LINK_DATA0_IN]
connect_bd_intf_net -intf_net intf_net_vid_phy_controller_vid_phy_status_sb_rx [get_bd_intf_pins vid_phy_controller/vid_phy_status_sb_rx] [get_bd_intf_pins v_hdmi_rx_ss/SB_STATUS_IN]
connect_bd_intf_net -intf_net intf_net_vid_phy_controller_vid_phy_status_sb_tx [get_bd_intf_pins vid_phy_controller/vid_phy_status_sb_tx] [get_bd_intf_pins v_hdmi_tx_ss/SB_STATUS_IN]
connect_bd_intf_net -intf_net mb_ss_0_iic_rtl_0 [get_bd_intf_ports GTH_CLK_IIC] [get_bd_intf_pins axi_iic_1/IIC]
connect_bd_intf_net -intf_net v_hdmi_tx_ss_LINK_DATA1_OUT [get_bd_intf_pins v_hdmi_tx_ss/LINK_DATA1_OUT] [get_bd_intf_pins vid_phy_controller/vid_phy_tx_axi4s_ch1]
connect_bd_intf_net -intf_net v_hdmi_tx_ss_LINK_DATA2_OUT [get_bd_intf_pins vid_phy_controller/vid_phy_tx_axi4s_ch2] [get_bd_intf_pins v_hdmi_tx_ss/LINK_DATA2_OUT]
connect_bd_intf_net -intf_net vid_phy_controller_vid_phy_rx_axi4s_ch1 [get_bd_intf_pins vid_phy_controller/vid_phy_rx_axi4s_ch1] [get_bd_intf_pins v_hdmi_rx_ss/LINK_DATA1_IN]
connect_bd_intf_net -intf_net vid_phy_controller_vid_phy_rx_axi4s_ch2 [get_bd_intf_pins vid_phy_controller/vid_phy_rx_axi4s_ch2] [get_bd_intf_pins v_hdmi_rx_ss/LINK_DATA2_IN]

# Create port connections
connect_bd_net -net mgtrefclk0_pad_n_in_0_1 [get_bd_ports TX_REFCLK_N_IN] [get_bd_pins vid_phy_controller/mgtrefclk0_pad_n_in]
connect_bd_net -net mgtrefclk0_pad_p_in_0_1 [get_bd_ports TX_REFCLK_P_IN] [get_bd_pins vid_phy_controller/mgtrefclk0_pad_p_in]
connect_bd_net -net mgtrefclk1_pad_n_in_0_1 [get_bd_ports HDMI_RX_CLK_N_IN] [get_bd_pins vid_phy_controller/mgtrefclk1_pad_n_in]
connect_bd_net -net mgtrefclk1_pad_p_in_0_1 [get_bd_ports HDMI_RX_CLK_P_IN] [get_bd_pins vid_phy_controller/mgtrefclk1_pad_p_in]
connect_bd_net -net net_audio_ss_0_aud_acr_cts_out [get_bd_pins audio_ss_0/aud_acr_cts_out] [get_bd_pins v_hdmi_tx_ss/acr_cts]
connect_bd_net -net net_audio_ss_0_aud_acr_n_out [get_bd_pins audio_ss_0/aud_acr_n_out] [get_bd_pins v_hdmi_tx_ss/acr_n]
connect_bd_net -net net_audio_ss_0_aud_acr_valid_out [get_bd_pins audio_ss_0/aud_acr_valid_out] [get_bd_pins v_hdmi_tx_ss/acr_valid]
connect_bd_net -net net_audio_ss_0_aud_rstn [get_bd_pins audio_ss_0/aud_rstn] [get_bd_pins v_hdmi_rx_ss/s_axis_audio_aresetn] [get_bd_pins v_hdmi_tx_ss/s_axis_audio_aresetn]
connect_bd_net -net net_audio_ss_0_audio_clk [get_bd_pins audio_ss_0/audio_clk] [get_bd_pins v_hdmi_rx_ss/s_axis_audio_aclk] [get_bd_pins v_hdmi_tx_ss/s_axis_audio_aclk]
connect_bd_net -net net_bdry_in_HDMI_RX_DAT_N_IN [get_bd_ports HDMI_RX_DAT_N_IN] [get_bd_pins vid_phy_controller/phy_rxn_in]
connect_bd_net -net net_bdry_in_HDMI_RX_DAT_P_IN [get_bd_ports HDMI_RX_DAT_P_IN] [get_bd_pins vid_phy_controller/phy_rxp_in]
connect_bd_net -net net_bdry_in_RX_DET_IN [get_bd_ports RX_DET_IN] [get_bd_pins v_hdmi_rx_ss/cable_detect]
connect_bd_net -net net_bdry_in_SI5324_LOL_IN [get_bd_ports IDT_8T49N241_LOL_IN] [get_bd_ports LED2] [get_bd_pins vid_phy_controller/tx_refclk_rdy]
connect_bd_net -net net_bdry_in_TX_HPD_IN [get_bd_ports TX_HPD_IN] [get_bd_pins v_hdmi_tx_ss/hpd]
connect_bd_net -net net_bdry_in_reset [get_bd_ports reset] [get_bd_pins clk_wiz/reset] [get_bd_pins rst_processor_1_100M/ext_reset_in] [get_bd_pins rst_processor_1_300M/ext_reset_in]
connect_bd_net -net net_clk_wiz_locked [get_bd_pins clk_wiz/locked] [get_bd_pins rst_processor_1_100M/aux_reset_in] [get_bd_pins rst_processor_1_100M/dcm_locked] [get_bd_pins rst_processor_1_300M/aux_reset_in] [get_bd_pins rst_processor_1_300M/dcm_locked]
connect_bd_net -net net_mb_ss_0_clk_out2 [get_bd_pins clk_wiz/clk_out1] [get_bd_pins v_tpg_ss_0/ap_clk] [get_bd_pins rx_video_axis_reg_slice/aclk] [get_bd_pins tx_video_axis_reg_slice/aclk] [get_bd_pins v_hdmi_rx_ss/s_axis_video_aclk] [get_bd_pins v_hdmi_tx_ss/s_axis_video_aclk] [get_bd_pins axi_interconnect/M05_ACLK] [get_bd_pins axi_interconnect/M08_ACLK] [get_bd_pins rst_processor_1_300M/slowest_sync_clk]
connect_bd_net -net net_mb_ss_0_dcm_locked [get_bd_pins rst_processor_1_300M/peripheral_aresetn] [get_bd_pins v_tpg_ss_0/m_axi_aresetn] [get_bd_pins rx_video_axis_reg_slice/aresetn] [get_bd_pins tx_video_axis_reg_slice/aresetn] [get_bd_pins v_hdmi_rx_ss/s_axis_video_aresetn] [get_bd_pins v_hdmi_tx_ss/s_axis_video_aresetn]
connect_bd_net -net net_mb_ss_0_peripheral_aresetn [get_bd_pins rst_processor_1_100M/peripheral_aresetn] [get_bd_pins audio_ss_0/ARESETN] [get_bd_ports LED1] [get_bd_ports IDT_8T49N241_RST_OUT] [get_bd_pins v_hdmi_rx_ss/s_axi_cpu_aresetn] [get_bd_pins v_hdmi_tx_ss/s_axi_cpu_aresetn] [get_bd_pins vid_phy_controller/vid_phy_sb_aresetn] [get_bd_pins vid_phy_controller/vid_phy_axi4lite_aresetn] [get_bd_pins axi_intc/s_axi_aresetn] [get_bd_pins axi_interconnect/S00_ARESETN] [get_bd_pins axi_interconnect/M00_ARESETN] [get_bd_pins axi_interconnect/M01_ARESETN] [get_bd_pins axi_interconnect/M02_ARESETN] [get_bd_pins axi_interconnect/M03_ARESETN] [get_bd_pins axi_interconnect/M04_ARESETN] [get_bd_pins axi_interconnect/M06_ARESETN] [get_bd_pins axi_interconnect/M07_ARESETN] [get_bd_pins axi_interconnect/M09_ARESETN] [get_bd_pins axi_uartlite/s_axi_aresetn] [get_bd_pins axi_iic_0/s_axi_aresetn] [get_bd_pins axi_iic_1/s_axi_aresetn]
connect_bd_net -net net_mb_ss_0_s_axi_aclk [get_bd_pins clk_wiz/clk_out2] [get_bd_pins audio_ss_0/ACLK] [get_bd_pins v_hdmi_rx_ss/s_axi_cpu_aclk] [get_bd_pins v_hdmi_tx_ss/s_axi_cpu_aclk] [get_bd_pins vid_phy_controller/vid_phy_sb_aclk] [get_bd_pins vid_phy_controller/vid_phy_axi4lite_aclk] [get_bd_pins vid_phy_controller/drpclk] [get_bd_pins axi_intc/s_axi_aclk] [get_bd_pins axi_interconnect/ACLK] [get_bd_pins axi_interconnect/S00_ACLK] [get_bd_pins axi_interconnect/M00_ACLK] [get_bd_pins axi_interconnect/M01_ACLK] [get_bd_pins axi_interconnect/M02_ACLK] [get_bd_pins axi_interconnect/M03_ACLK] [get_bd_pins axi_interconnect/M04_ACLK] [get_bd_pins axi_interconnect/M06_ACLK] [get_bd_pins axi_interconnect/M07_ACLK] [get_bd_pins axi_interconnect/M09_ACLK] [get_bd_pins axi_uartlite/s_axi_aclk] [get_bd_pins dlmb_bram_if_cntlr/LMB_Clk] [get_bd_pins dlmb_v10/LMB_Clk] [get_bd_pins axi_iic_0/s_axi_aclk] [get_bd_pins axi_iic_1/s_axi_aclk] [get_bd_pins ilmb_bram_if_cntlr/LMB_Clk] [get_bd_pins ilmb_v10/LMB_Clk] [get_bd_pins mblaze/Clk] [get_bd_pins rst_processor_1_100M/slowest_sync_clk]
connect_bd_net -net net_mdm_Debug_SYS_Rst [get_bd_pins mdm/Debug_SYS_Rst] [get_bd_pins rst_processor_1_100M/mb_debug_sys_rst]
connect_bd_net -net net_rst_processor_1_100M_bus_struct_reset [get_bd_pins rst_processor_1_100M/bus_struct_reset] [get_bd_pins dlmb_bram_if_cntlr/LMB_Rst] [get_bd_pins dlmb_v10/SYS_Rst] [get_bd_pins ilmb_bram_if_cntlr/LMB_Rst] [get_bd_pins ilmb_v10/SYS_Rst]
connect_bd_net -net net_rst_processor_1_100M_interconnect_aresetn [get_bd_pins rst_processor_1_100M/interconnect_aresetn] [get_bd_pins axi_interconnect/ARESETN]
connect_bd_net -net net_rst_processor_1_100M_mb_reset [get_bd_pins rst_processor_1_100M/mb_reset] [get_bd_pins mblaze/Reset]
connect_bd_net -net net_rst_processor_1_300M_interconnect_aresetn [get_bd_pins rst_processor_1_300M/interconnect_aresetn] [get_bd_pins axi_interconnect/M05_ARESETN] [get_bd_pins axi_interconnect/M08_ARESETN]
connect_bd_net -net net_v_hdmi_rx_ss_acr_cts [get_bd_pins v_hdmi_rx_ss/acr_cts] [get_bd_pins audio_ss_0/aud_acr_cts_in]
connect_bd_net -net net_v_hdmi_rx_ss_acr_n [get_bd_pins v_hdmi_rx_ss/acr_n] [get_bd_pins audio_ss_0/aud_acr_n_in]
connect_bd_net -net net_v_hdmi_rx_ss_acr_valid [get_bd_pins v_hdmi_rx_ss/acr_valid] [get_bd_pins audio_ss_0/aud_acr_valid_in]
connect_bd_net -net net_v_hdmi_rx_ss_fid [get_bd_pins v_hdmi_rx_ss/fid] [get_bd_pins v_hdmi_tx_ss/fid]
connect_bd_net -net net_v_hdmi_rx_ss_irq [get_bd_pins v_hdmi_rx_ss/irq] [get_bd_pins xlconcat/In1]
connect_bd_net -net net_v_hdmi_tx_ss_irq [get_bd_pins v_hdmi_tx_ss/irq] [get_bd_pins xlconcat/In2]
connect_bd_net -net net_v_hdmi_tx_ss_locked [get_bd_pins v_hdmi_tx_ss/locked] [get_bd_ports LED0]
connect_bd_net -net net_vcc_const_dout [get_bd_pins vcc_const/dout] [get_bd_ports TX_CLKSEL_OUT] [get_bd_ports TX_EN_OUT] [get_bd_pins vid_phy_controller/vid_phy_tx_axi4s_aresetn] [get_bd_pins vid_phy_controller/vid_phy_rx_axi4s_aresetn]
connect_bd_net -net net_vid_phy_controller_irq [get_bd_pins vid_phy_controller/irq] [get_bd_pins xlconcat/In0]
connect_bd_net -net net_vid_phy_controller_phy_txn_out [get_bd_pins vid_phy_controller/phy_txn_out] [get_bd_ports HDMI_TX_DAT_N_OUT]
connect_bd_net -net net_vid_phy_controller_phy_txp_out [get_bd_pins vid_phy_controller/phy_txp_out] [get_bd_ports HDMI_TX_DAT_P_OUT]
connect_bd_net -net net_vid_phy_controller_rx_tmds_clk_n [get_bd_pins vid_phy_controller/rx_tmds_clk_n] [get_bd_ports RX_REFCLK_N_OUT]
connect_bd_net -net net_vid_phy_controller_rx_tmds_clk_p [get_bd_pins vid_phy_controller/rx_tmds_clk_p] [get_bd_ports RX_REFCLK_P_OUT]
connect_bd_net -net net_vid_phy_controller_rxoutclk [get_bd_pins vid_phy_controller/rxoutclk] [get_bd_pins v_hdmi_rx_ss/link_clk] [get_bd_pins vid_phy_controller/vid_phy_rx_axi4s_aclk]
connect_bd_net -net net_vid_phy_controller_tx_tmds_clk [get_bd_pins vid_phy_controller/tx_tmds_clk] [get_bd_pins audio_ss_0/hdmi_clk]
connect_bd_net -net net_vid_phy_controller_tx_tmds_clk_n [get_bd_pins vid_phy_controller/tx_tmds_clk_n] [get_bd_ports HDMI_TX_CLK_N_OUT]
connect_bd_net -net net_vid_phy_controller_tx_tmds_clk_p [get_bd_pins vid_phy_controller/tx_tmds_clk_p] [get_bd_ports HDMI_TX_CLK_P_OUT]
connect_bd_net -net net_vid_phy_controller_txoutclk [get_bd_pins vid_phy_controller/txoutclk] [get_bd_pins v_hdmi_tx_ss/link_clk] [get_bd_pins vid_phy_controller/vid_phy_tx_axi4s_aclk]
connect_bd_net -net net_xlconcat_dout [get_bd_pins xlconcat/dout] [get_bd_pins axi_intc/intr]
connect_bd_net -net v_hdmi_rx_ss_hpd [get_bd_pins v_hdmi_rx_ss/hpd] [get_bd_ports RX_HPD_OUT]
connect_bd_net -net vid_phy_controller_rx_video_clk [get_bd_pins vid_phy_controller/rx_video_clk] [get_bd_pins v_hdmi_rx_ss/video_clk]
connect_bd_net -net vid_phy_controller_tx_video_clk [get_bd_pins vid_phy_controller/tx_video_clk] [get_bd_pins v_hdmi_tx_ss/video_clk]

assign_bd_address -offset 0x00000000 -range 0x00080000 -target_address_space [get_bd_addr_spaces mblaze/Data] [get_bd_addr_segs dlmb_bram_if_cntlr/SLMB/Mem] -force
assign_bd_address -offset 0x00000000 -range 0x00080000 -target_address_space [get_bd_addr_spaces mblaze/Instruction] [get_bd_addr_segs ilmb_bram_if_cntlr/SLMB/Mem] -force

# Assign addresses
assign_bd_address

# Assign 512K memory for the MicroBlaze
set_property range 512K [get_bd_addr_segs {mblaze/Data/SEG_dlmb_bram_if_cntlr_Mem}]
set_property range 512K [get_bd_addr_segs {mblaze/Instruction/SEG_ilmb_bram_if_cntlr_Mem}]

# Restore current instance
current_bd_instance $oldCurInst

save_bd_design
