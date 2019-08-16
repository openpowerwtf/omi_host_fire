###########################################################################
# Clocks
###########################################################################
#create_clock -period 5.000 -add -name ASYNC_SYSCLK [get_nets oc_host_cfg0_axis_aclk]
#create_clock -period 5.000 -add -name ASYNC_CCLK [get_nets cclk_a]

###########################################################################
# False Paths
###########################################################################
create_clock -period 8.333 -name RAW_RCLK_P [get_ports RAW_RCLK_P]
create_clock -period 7.500 -name DDIMMB_FPGA_REFCLK_P_1 [get_ports {DDIMMB_FPGA_REFCLK_P[1]}]
create_clock -period 7.500 -name DDIMMB_FPGA_REFCLK_P_0 [get_ports {DDIMMB_FPGA_REFCLK_P[0]}]
set_false_path -to [get_cells -hierarchical -filter {NAME =~ *bit_synchronizer*inst/i_in_meta_reg}]
set_false_path -to [get_cells -hierarchical -filter {NAME =~ *reset_synchronizer*inst/rst_in_*_reg}]
set_false_path -to [get_cells -hierarchical -filter {NAME =~ *gtwiz_userclk_tx_inst/*gtwiz_userclk_tx_active_*_reg}]
create_clock -period 3.000 -name {VIRTUAL_txoutclk_out[0]_1} -waveform {0.000 1.500}
set_input_delay -clock [get_clocks {VIRTUAL_txoutclk_out[0]_1}] -min -add_delay 0.200 [get_ports RAW_RESETN]
set_input_delay -clock [get_clocks {VIRTUAL_txoutclk_out[0]_1}] -max -add_delay 0.400 [get_ports RAW_RESETN]
set_input_delay -clock [get_clocks RAW_SYSCLK_P] -min -add_delay 0.200 [get_ports SCL_IO]
set_input_delay -clock [get_clocks RAW_SYSCLK_P] -max -add_delay 0.400 [get_ports SCL_IO]
set_input_delay -clock [get_clocks RAW_SYSCLK_P] -min -add_delay 0.200 [get_ports SDA_IO]
set_input_delay -clock [get_clocks RAW_SYSCLK_P] -max -add_delay 0.400 [get_ports SDA_IO]
set_output_delay -clock [get_clocks RAW_SYSCLK_P] -min -add_delay 0.000 [get_ports SCL_IO]
set_output_delay -clock [get_clocks RAW_SYSCLK_P] -max -add_delay 0.200 [get_ports SCL_IO]
set_output_delay -clock [get_clocks RAW_SYSCLK_P] -min -add_delay 0.000 [get_ports SDA_IO]
set_output_delay -clock [get_clocks RAW_SYSCLK_P] -max -add_delay 0.200 [get_ports SDA_IO]
set_output_delay -clock [get_clocks RAW_SYSCLK_P] -clock_fall -min -add_delay 0.000 [get_ports SYSCLK_PROBE0_N]
set_output_delay -clock [get_clocks RAW_SYSCLK_P] -clock_fall -max -add_delay 0.200 [get_ports SYSCLK_PROBE0_N]
set_output_delay -clock [get_clocks RAW_SYSCLK_P] -min -add_delay 0.000 [get_ports SYSCLK_PROBE0_N]
set_output_delay -clock [get_clocks RAW_SYSCLK_P] -max -add_delay 0.200 [get_ports SYSCLK_PROBE0_N]
set_output_delay -clock [get_clocks RAW_SYSCLK_P] -clock_fall -min -add_delay 0.000 [get_ports SYSCLK_PROBE0_P]
set_output_delay -clock [get_clocks RAW_SYSCLK_P] -clock_fall -max -add_delay 0.200 [get_ports SYSCLK_PROBE0_P]
set_output_delay -clock [get_clocks RAW_SYSCLK_P] -min -add_delay 0.000 [get_ports SYSCLK_PROBE0_P]
set_output_delay -clock [get_clocks RAW_SYSCLK_P] -max -add_delay 0.200 [get_ports SYSCLK_PROBE0_P]
set_output_delay -clock [get_clocks RAW_SYSCLK_P] -clock_fall -min -add_delay 0.000 [get_ports SYSCLK_PROBE1_N]
set_output_delay -clock [get_clocks RAW_SYSCLK_P] -clock_fall -max -add_delay 0.200 [get_ports SYSCLK_PROBE1_N]
set_output_delay -clock [get_clocks RAW_SYSCLK_P] -min -add_delay 0.000 [get_ports SYSCLK_PROBE1_N]
set_output_delay -clock [get_clocks RAW_SYSCLK_P] -max -add_delay 0.200 [get_ports SYSCLK_PROBE1_N]
set_output_delay -clock [get_clocks RAW_SYSCLK_P] -clock_fall -min -add_delay 0.000 [get_ports SYSCLK_PROBE1_P]
set_output_delay -clock [get_clocks RAW_SYSCLK_P] -clock_fall -max -add_delay 0.200 [get_ports SYSCLK_PROBE1_P]
set_output_delay -clock [get_clocks RAW_SYSCLK_P] -min -add_delay 0.000 [get_ports SYSCLK_PROBE1_P]
set_output_delay -clock [get_clocks RAW_SYSCLK_P] -max -add_delay 0.200 [get_ports SYSCLK_PROBE1_P]
create_clock -period 16.666 -name VIRTUAL_rclk -waveform {0.000 8.333}
set_input_delay -clock [get_clocks VIRTUAL_rclk] -min -add_delay 1.000 [get_ports OCDE]
set_input_delay -clock [get_clocks VIRTUAL_rclk] -max -add_delay 2.000 [get_ports OCDE]
set_output_delay -clock [get_clocks {VIRTUAL_txoutclk_out[0]_1}] -min -add_delay 0.000 [get_ports ICE_RESETN]
set_output_delay -clock [get_clocks {VIRTUAL_txoutclk_out[0]_1}] -max -add_delay 0.150 [get_ports ICE_RESETN]
#set_false_path -from [get_pins {vio/inst/PROBE_OUT_ALL_INST/G_PROBE_OUT[0].PROBE_OUT0_INST/Probe_out_reg[0]/C}] -to [get_pins fire_core/dl/dlx/xlx_if/ocde_q_reg/D]
set_false_path -from [get_pins {vio/inst/PROBE_OUT_ALL_INST/G_PROBE_OUT[0].PROBE_OUT0_INST/Probe_out_reg[0]/C}] -to [get_ports ICE_RESETN]
set_false_path -from [get_ports OCDE] -to [get_ports ICE_RESETN]
set_false_path -from [get_clocks -of_objects [get_pins {hss0/hss_phy/example_wrapper_inst/DLx_phy_inst/inst/gen_gtwizard_gtye4_top.gtwizard_ultrascale_0_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[6].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]] -to [get_clocks -of_objects [get_pins hss0/hss_phy/BUFGCE_DIV_inst/O]]

set_clock_groups -asynchronous -group [get_clocks RAW_SYSCLK_P]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins fire_pervasive/clk_wiz/inst/plle4_adv_inst/CLKOUT0]]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins {hss0/hss_phy/example_wrapper_inst/DLx_phy_inst/inst/gen_gtwizard_gtye4_top.gtwizard_ultrascale_0_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[6].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -asynchronous -group [get_clocks {VIRTUAL_txoutclk_out[0]_1}]
set_clock_groups -asynchronous -group [get_clocks -of_objects [get_pins hss0/hss_phy/BUFGCE_DIV_inst/O]]

set_input_delay -clock [get_clocks clk_out1_clk_wiz_sysclk] -min -add_delay 0.000 [get_ports RAW_RESETN]
set_input_delay -clock [get_clocks clk_out1_clk_wiz_sysclk] -max -add_delay 0.000 [get_ports RAW_RESETN]
set_output_delay -clock [get_clocks clk_out1_clk_wiz_sysclk] -min -add_delay 0.000 [get_ports PLL_LOCKED]
set_output_delay -clock [get_clocks clk_out1_clk_wiz_sysclk] -max -add_delay 0.000 [get_ports PLL_LOCKED]

set_property BITSTREAM.CONFIG.OVERTEMPSHUTDOWN ENABLE [current_design]

