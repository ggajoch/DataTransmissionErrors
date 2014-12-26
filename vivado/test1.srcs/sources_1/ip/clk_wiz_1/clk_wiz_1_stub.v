// Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2014.4 (win64) Build 1071353 Tue Nov 18 18:29:27 MST 2014
// Date        : Thu Dec 25 21:51:47 2014
// Host        : RAMEND running 64-bit Service Pack 1  (build 7601)
// Command     : write_verilog -force -mode synth_stub
//               g:/repos/DataTransmissionErrors/DataTransmissionErrors/vivado/test1.srcs/sources_1/ip/clk_wiz_1/clk_wiz_1_stub.v
// Design      : clk_wiz_1
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tcsg324-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module clk_wiz_1(clk_in1, clk_out1, clk_out2, clk_out3)
/* synthesis syn_black_box black_box_pad_pin="clk_in1,clk_out1,clk_out2,clk_out3" */;
  input clk_in1;
  output clk_out1;
  output clk_out2;
  output clk_out3;
endmodule
