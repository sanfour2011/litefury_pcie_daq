
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]

create_clock -period 5.000 -name sysclk_p -waveform {0.000 2.500} [get_ports sysclk_p]
create_clock -period 10.000 -name pcie_clkin_clk_p -waveform {0.000 5.000} [get_ports pcie_clkin_clk_p]

#set_max_delay -to   [get_clocks sysclk_p] -from [get_ports {pcie_reset}] -datapath_only  20.0
#set_min_delay -to   [get_clocks sysclk_p] -from [get_ports {pcie_reset}]  20.0
#set_max_delay -from [get_clocks sysclk_p] -to   [get_ports {ledn[*]}] -datapath_only  20.0
#set_max_delay -from [get_clocks userclk1] -to   [get_ports {qspi_*}] -datapath_only  20.0
#set_max_delay -to   [get_clocks userclk1] -from [get_ports {qspi_*}] -datapath_only  20.0
#set_min_delay -to   [get_clocks userclk1] -from [get_ports {qspi_*}]  20.0

#################

set_property IOSTANDARD LVDS_25 [get_ports sysclk_*]
set_property PACKAGE_PIN J19 [get_ports sysclk_p]
set_property PACKAGE_PIN H19 [get_ports sysclk_n]

set_property PACKAGE_PIN F6 [get_ports {pcie_clkin_clk_p[0]}]
set_property PACKAGE_PIN E6 [get_ports {pcie_clkin_clk_n[0]}]
set_property PACKAGE_PIN G1 [get_ports pcie_clkreq_l]
set_property IOSTANDARD LVCMOS33 [get_ports pcie_clkreq_l]
set_property PACKAGE_PIN J1 [get_ports pcie_reset]
set_property IOSTANDARD LVCMOS33 [get_ports pcie_reset]


set_property IOSTANDARD LVCMOS33 [get_ports {ledn[*]}]
set_property PACKAGE_PIN G3 [get_ports {ledn[0]}]
set_property PACKAGE_PIN H3 [get_ports {ledn[1]}]
set_property PACKAGE_PIN G4 [get_ports {ledn[2]}]
set_property PACKAGE_PIN H4 [get_ports {ledn[3]}]

#set_property IOSTANDARD LVCMOS33    [get_ports {qspi_io*_io}]
#set_property PACKAGE_PIN P22        [get_ports {qspi_io0_io}]
#set_property PACKAGE_PIN R22        [get_ports {qspi_io1_io}]
#set_property PACKAGE_PIN P21        [get_ports {qspi_io2_io}]
#set_property PACKAGE_PIN R21        [get_ports {qspi_io3_io}]
#set_property IOSTANDARD LVCMOS33    [get_ports {qspi_ss_io}]
#set_property PACKAGE_PIN T19        [get_ports {qspi_ss_io}]

set_property PACKAGE_PIN A10 [get_ports {pcie_mgt_rxn[0]}]
set_property PACKAGE_PIN B10 [get_ports {pcie_mgt_rxp[0]}]
set_property PACKAGE_PIN A6 [get_ports {pcie_mgt_txn[0]}]
set_property PACKAGE_PIN B6 [get_ports {pcie_mgt_txp[0]}]
set_property PACKAGE_PIN A8 [get_ports {pcie_mgt_rxn[1]}]
set_property PACKAGE_PIN B8 [get_ports {pcie_mgt_rxp[1]}]
set_property PACKAGE_PIN A4 [get_ports {pcie_mgt_txn[1]}]
set_property PACKAGE_PIN B4 [get_ports {pcie_mgt_txp[1]}]
set_property PACKAGE_PIN C9 [get_ports {pcie_mgt_rxn[3]}]
set_property PACKAGE_PIN D9 [get_ports {pcie_mgt_rxp[3]}]
set_property PACKAGE_PIN C7 [get_ports {pcie_mgt_txn[3]}]
set_property PACKAGE_PIN D7 [get_ports {pcie_mgt_txp[3]}]



create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 2048 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list sys_clk_BUFG]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 11 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {bram_addr_counter_sig[2]} {bram_addr_counter_sig[3]} {bram_addr_counter_sig[4]} {bram_addr_counter_sig[5]} {bram_addr_counter_sig[6]} {bram_addr_counter_sig[7]} {bram_addr_counter_sig[8]} {bram_addr_counter_sig[9]} {bram_addr_counter_sig[10]} {bram_addr_counter_sig[11]} {bram_addr_counter_sig[12]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 3 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {next_state_sig[0]} {next_state_sig[1]} {next_state_sig[2]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 1 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {usr_irq_req[0]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 1 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {usr_irq_ack_sig_sycend[0]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 1 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list acq_ctrl_rst_n_sig]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 1 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list buffer_full_sig]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 1 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list irq_pending_sig_synced]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list is_running_sig]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list sys_clk]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk]
