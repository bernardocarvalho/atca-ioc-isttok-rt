////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 1995-2008 Xilinx, Inc.  All rights reserved.
////////////////////////////////////////////////////////////////////////////////
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor: Xilinx
// \   \   \/     Version: K.39
//  \   \         Application: netgen
//  /   /         Filename: bits_counter.v
// /___/   /\     Timestamp: Fri Mar 20 11:58:33 2009
// \   \  /  \ 
//  \___\/\___\
//             
// Command	: -intstyle ise -w -sim -ofmt verilog S:\ATCA_RT_MIMO\tmp\_cg\bits_counter.ngc S:\ATCA_RT_MIMO\tmp\_cg\bits_counter.v 
// Device	: 4vfx60ff1152-11
// Input file	: S:/ATCA_RT_MIMO/tmp/_cg/bits_counter.ngc
// Output file	: S:/ATCA_RT_MIMO/tmp/_cg/bits_counter.v
// # of Modules	: 1
// Design Name	: bits_counter
// Xilinx        : C:\Xilinx\10.1\ISE
//             
// Purpose:    
//     This verilog netlist is a verification model and uses simulation 
//     primitives which may not represent the true implementation of the 
//     device, however the netlist is functionally correct and should not 
//     be modified. This file cannot be synthesized and should only be used 
//     with supported simulation tools.
//             
// Reference:  
//     Development System Reference Guide, Chapter 23 and Synthesis and Simulation Design Guide, Chapter 6
//             
////////////////////////////////////////////////////////////////////////////////

`timescale 1 ns/1 ps

module bits_counter (
  aclr, clk, q
);
  input aclr;
  input clk;
  output [3 : 0] q;
  
  // synthesis translate_off
  
  wire \BU2/U0/the_addsub/no_pipelining.the_addsub/i_simple_model.carryxortop_rt_17 ;
  wire \BU2/U0/the_addsub/no_pipelining.the_addsub/i_simple_model.carrychaingen[1].carrymux_rt_16 ;
  wire \BU2/U0/the_addsub/no_pipelining.the_addsub/i_simple_model.carrychaingen[2].carrymux_rt_13 ;
  wire \BU2/N0 ;
  wire \BU2/q_thresh1 ;
  wire NLW_VCC_P_UNCONNECTED;
  wire NLW_GND_G_UNCONNECTED;
  wire [3 : 0] NlwRenamedSig_OI_q;
  wire [0 : 0] \BU2/U0/the_addsub/no_pipelining.the_addsub/halfsum ;
  wire [2 : 0] \BU2/U0/the_addsub/no_pipelining.the_addsub/carry_simple ;
  wire [3 : 0] \BU2/U0/q_next ;
  assign
    q[3] = NlwRenamedSig_OI_q[3],
    q[2] = NlwRenamedSig_OI_q[2],
    q[1] = NlwRenamedSig_OI_q[1],
    q[0] = NlwRenamedSig_OI_q[0];
  VCC   VCC_0 (
    .P(NLW_VCC_P_UNCONNECTED)
  );
  GND   GND_1 (
    .G(NLW_GND_G_UNCONNECTED)
  );
  INV   \BU2/U0/the_addsub/no_pipelining.the_addsub/halfsum_not00001_INV_0  (
    .I(NlwRenamedSig_OI_q[0]),
    .O(\BU2/U0/the_addsub/no_pipelining.the_addsub/halfsum [0])
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \BU2/U0/the_addsub/no_pipelining.the_addsub/i_simple_model.carryxortop_rt  (
    .I0(NlwRenamedSig_OI_q[3]),
    .O(\BU2/U0/the_addsub/no_pipelining.the_addsub/i_simple_model.carryxortop_rt_17 )
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \BU2/U0/the_addsub/no_pipelining.the_addsub/i_simple_model.carrychaingen[1].carrymux_rt  (
    .I0(NlwRenamedSig_OI_q[1]),
    .O(\BU2/U0/the_addsub/no_pipelining.the_addsub/i_simple_model.carrychaingen[1].carrymux_rt_16 )
  );
  LUT1 #(
    .INIT ( 2'h2 ))
  \BU2/U0/the_addsub/no_pipelining.the_addsub/i_simple_model.carrychaingen[2].carrymux_rt  (
    .I0(NlwRenamedSig_OI_q[2]),
    .O(\BU2/U0/the_addsub/no_pipelining.the_addsub/i_simple_model.carrychaingen[2].carrymux_rt_13 )
  );
  MUXCY   \BU2/U0/the_addsub/no_pipelining.the_addsub/i_simple_model.carrymux0  (
    .CI(\BU2/N0 ),
    .DI(\BU2/q_thresh1 ),
    .S(\BU2/U0/the_addsub/no_pipelining.the_addsub/halfsum [0]),
    .O(\BU2/U0/the_addsub/no_pipelining.the_addsub/carry_simple [0])
  );
  XORCY   \BU2/U0/the_addsub/no_pipelining.the_addsub/i_simple_model.carryxor0  (
    .CI(\BU2/N0 ),
    .LI(\BU2/U0/the_addsub/no_pipelining.the_addsub/halfsum [0]),
    .O(\BU2/U0/q_next [0])
  );
  XORCY   \BU2/U0/the_addsub/no_pipelining.the_addsub/i_simple_model.carryxortop  (
    .CI(\BU2/U0/the_addsub/no_pipelining.the_addsub/carry_simple [2]),
    .LI(\BU2/U0/the_addsub/no_pipelining.the_addsub/i_simple_model.carryxortop_rt_17 ),
    .O(\BU2/U0/q_next [3])
  );
  MUXCY   \BU2/U0/the_addsub/no_pipelining.the_addsub/i_simple_model.carrychaingen[1].carrymux  (
    .CI(\BU2/U0/the_addsub/no_pipelining.the_addsub/carry_simple [0]),
    .DI(\BU2/N0 ),
    .S(\BU2/U0/the_addsub/no_pipelining.the_addsub/i_simple_model.carrychaingen[1].carrymux_rt_16 ),
    .O(\BU2/U0/the_addsub/no_pipelining.the_addsub/carry_simple [1])
  );
  XORCY   \BU2/U0/the_addsub/no_pipelining.the_addsub/i_simple_model.carrychaingen[1].carryxor  (
    .CI(\BU2/U0/the_addsub/no_pipelining.the_addsub/carry_simple [0]),
    .LI(\BU2/U0/the_addsub/no_pipelining.the_addsub/i_simple_model.carrychaingen[1].carrymux_rt_16 ),
    .O(\BU2/U0/q_next [1])
  );
  MUXCY   \BU2/U0/the_addsub/no_pipelining.the_addsub/i_simple_model.carrychaingen[2].carrymux  (
    .CI(\BU2/U0/the_addsub/no_pipelining.the_addsub/carry_simple [1]),
    .DI(\BU2/N0 ),
    .S(\BU2/U0/the_addsub/no_pipelining.the_addsub/i_simple_model.carrychaingen[2].carrymux_rt_13 ),
    .O(\BU2/U0/the_addsub/no_pipelining.the_addsub/carry_simple [2])
  );
  XORCY   \BU2/U0/the_addsub/no_pipelining.the_addsub/i_simple_model.carrychaingen[2].carryxor  (
    .CI(\BU2/U0/the_addsub/no_pipelining.the_addsub/carry_simple [1]),
    .LI(\BU2/U0/the_addsub/no_pipelining.the_addsub/i_simple_model.carrychaingen[2].carrymux_rt_13 ),
    .O(\BU2/U0/q_next [2])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \BU2/U0/q_i_0  (
    .C(clk),
    .CE(\BU2/q_thresh1 ),
    .CLR(aclr),
    .D(\BU2/U0/q_next [0]),
    .Q(NlwRenamedSig_OI_q[0])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \BU2/U0/q_i_1  (
    .C(clk),
    .CE(\BU2/q_thresh1 ),
    .CLR(aclr),
    .D(\BU2/U0/q_next [1]),
    .Q(NlwRenamedSig_OI_q[1])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \BU2/U0/q_i_2  (
    .C(clk),
    .CE(\BU2/q_thresh1 ),
    .CLR(aclr),
    .D(\BU2/U0/q_next [2]),
    .Q(NlwRenamedSig_OI_q[2])
  );
  FDCE #(
    .INIT ( 1'b0 ))
  \BU2/U0/q_i_3  (
    .C(clk),
    .CE(\BU2/q_thresh1 ),
    .CLR(aclr),
    .D(\BU2/U0/q_next [3]),
    .Q(NlwRenamedSig_OI_q[3])
  );
  VCC   \BU2/XST_VCC  (
    .P(\BU2/q_thresh1 )
  );
  GND   \BU2/XST_GND  (
    .G(\BU2/N0 )
  );

// synthesis translate_on

endmodule

// synthesis translate_off

`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

    wire GSR;
    wire GTS;
    wire PRLD;

    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (weak1, weak0) GSR = GSR_int;
    assign (weak1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

endmodule

// synthesis translate_on
