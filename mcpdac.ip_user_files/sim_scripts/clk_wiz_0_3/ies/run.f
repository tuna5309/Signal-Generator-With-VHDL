-makelib ies_lib/xil_defaultlib -sv \
  "C:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \
-endlib
-makelib ies_lib/xpm \
  "C:/Xilinx/Vivado/2019.1/data/ip/xpm/xpm_VCOMP.vhd" \
-endlib
-makelib ies_lib/xil_defaultlib \
  "../../../../mcpdac.srcs/sources_1/ip/clk_wiz_0_3/clk_wiz_0_sim_netlist.vhdl" \
-endlib
-makelib ies_lib/xil_defaultlib \
  glbl.v
-endlib

