///////////////////////////////////////////////////////////////////////////////
//
//      Project:  Aurora Module Generator version 3.0
//
//         Date:  $Date: 2008/07/21 10:19:45 $
//          Tag:  $Name: i+IP+144966 $
//         File:  $RCSfile: aurora_example_v4.ejava,v $
//          Rev:  $Revision: 1.1.2.9 $
//
//      Company:  Xilinx
//
//   Disclaimer:  XILINX IS PROVIDING THIS DESIGN, CODE, OR
//                INFORMATION "AS IS" SOLELY FOR USE IN DEVELOPING
//                PROGRAMS AND SOLUTIONS FOR XILINX DEVICES.  BY
//                PROVIDING THIS DESIGN, CODE, OR INFORMATION AS
//                ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,
//                APPLICATION OR STANDARD, XILINX IS MAKING NO
//                REPRESENTATION THAT THIS IMPLEMENTATION IS FREE
//                FROM ANY CLAIMS OF INFRINGEMENT, AND YOU ARE
//                RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY
//                REQUIRE FOR YOUR IMPLEMENTATION.  XILINX
//                EXPRESSLY DISCLAIMS ANY WARRANTY WHATSOEVER WITH
//                RESPECT TO THE ADEQUACY OF THE IMPLEMENTATION,
//                INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR
//                REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE
//                FROM CLAIMS OF INFRINGEMENT, IMPLIED WARRANTIES
//                OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
//                PURPOSE.
//
//                (c) Copyright 2008 Xilinx, Inc.
//                All rights reserved.
//
///////////////////////////////////////////////////////////////////////////////
//
//  AURORA_SAMPLE
//
//  Aurora Generator
//
//
//  Description: Sample Instantiation of a 1 4-byte lane module.
//               Only tests initialization in hardware.
//
//  Note:  This example design is intended for use on a Xilinx ML421
//         prototyping Board which contains an XC4VFX60 part.  Aurora
//         configurations that are too large to fit within this part
//         cannot use this example design as is.  If you wish to use
//         this design with larger configurations of Aurora or with
//         a custom board, you must modify this source file and the
//         aurora_example.ucf file as needed.
//         

`timescale 1 ns / 10 ps

module AURORA_32_BITS #
(
    parameter USE_CHIPSCOPE         = 0,
    parameter       SIMULATION_P = 0,         // Set to 1 for simulation
    parameter       EXTEND_WATCHDOGS = 0,
 
    parameter       LANE0_GT11_MODE_P = "B",        // Based on MGT Location
    parameter       LANE0_MGT_ID_P = 1,
    parameter       TXPOST_TAP_PD_P     = "FALSE"    // Default is false, set to FALSE for serial loopback or tuned preemphasis
)
(
    // User IO
    RESET,
    HARD_ERROR,
    SOFT_ERROR,
    FRAME_ERROR,
    ERROR_COUNT,
    LANE_UP,
    CHANNEL_UP,
    //INIT_CLK,
init_clk_i,
    PMA_INIT,
    TX_LOCK,
    RX_LOCK,
    RX_SIGNAL_DETECT,
    RESET_CALBLOCKS,

ref_clk2_left_i,
    /*REF_CLK2_LEFT_P,
    REF_CLK2_LEFT_N,
    REF_CLK2_RIGHT_P,
    REF_CLK2_RIGHT_N,*/


    // MGT I/O
    RXP,
    RXN,
    TXP,
    TXN,
	 
	 
	 TX_CLK_EN,
    TX_CLOCK,
    TX_DATA,
	 
	 RX_DATA_VALID,
    RX_CLK_EN,
    RX_CLOCK,
    RX_DATA

);

// synthesis attribute X_CORE_INFO of aurora_aurora_example is "aurora_v3_0, Coregen v10.1_ip3";

//********************************Parameter Declarations*****************************
    
//***********************************Port Declarations*******************************

    // User I/O
    input              RESET;
    //input              INIT_CLK;
	 input init_clk_i;
    input              PMA_INIT;
    input              RESET_CALBLOCKS;
    input              RX_SIGNAL_DETECT;

    output             HARD_ERROR;
    output             SOFT_ERROR;

    output             TX_LOCK;
    output             RX_LOCK;

    output             FRAME_ERROR;
    output  [0:7]      ERROR_COUNT;
    output             LANE_UP;
    output             CHANNEL_UP;
    

input ref_clk2_left_i;
    // Clocks
    /*input              REF_CLK2_LEFT_P;
    input              REF_CLK2_LEFT_N;

    input              REF_CLK2_RIGHT_P;
    input              REF_CLK2_RIGHT_N;*/



    // MGT I/O
    input              RXP;
    input              RXN;

    output             TXP;
    output             TXN;
	 
	 
	 
	 input TX_CLK_EN;
    input TX_CLOCK;
    input [31:0] TX_DATA;
	 
	 
	 output RX_DATA_VALID;
    input RX_CLK_EN;
    input RX_CLOCK;
    output [31:0] RX_DATA;

//**************************External Register Declarations****************************

    reg                HARD_ERROR;
    reg                SOFT_ERROR;
    reg                FRAME_ERROR;
    reg     [0:7]      ERROR_COUNT;    
    reg                LANE_UP;
    reg                CHANNEL_UP;
    reg                TX_LOCK;
    reg                RX_LOCK;


//**************************Internal Register Declarations****************************

    reg     [0:3]      reset_debounce_r;
    reg     [0:3]      debounce_pma_init_r;
    reg                reset_calblocks_r;
    reg                rx_signal_detect_r;


//********************************Wire Declarations**********************************
    wire               lane_up_i_i;
    wire    [41:0]     ila_data_i;
    wire    [35:0]     icon_ila_i;
    // LocalLink TX Interface
    wire    [0:31]     tx_d_i;
    wire    [0:1]      tx_rem_i;
    wire               tx_src_rdy_n_i;
    wire               tx_sof_n_i;
    wire               tx_eof_n_i;

    wire               tx_dst_rdy_n_i;


    // LocalLink RX Interface
    wire    [0:31]     rx_d_i;
    wire    [0:1]      rx_rem_i;
    wire               rx_src_rdy_n_i;
    wire               rx_sof_n_i;
    wire               rx_eof_n_i;






    // MGT Reference Clock Interface
    
    //wire               ref_clk1_left_i;
    //wire               ref_clk2_left_i;
    //wire               ref_clk1_right_i;
    //wire               ref_clk2_right_i;
    



    // Error Detection Interface
    wire               hard_error_i;
    wire               soft_error_i;
    wire               frame_error_i;


    // Status
    wire               channel_up_i;
    wire               lane_up_i;


    // Clock Compensation Control Interface
    wire               warn_cc_i;
    wire               do_cc_i;


    // System Interface
    wire               dcm_not_locked_i;
    wire               user_clk_i;
    wire               reset_i;
    wire               power_down_i;
    wire    [0:1]      loopback_i;
    wire               tx_lock_i;
    wire               rx_lock_i;
	 //wire               rx_rec_clk;
    wire               tx_out_clk_i;
    //wire               init_clk_i;
    wire               pma_init_r; 


    //Frame check signals
    wire    [0:7]      error_count_i;
    wire               test_reset_i;

    
    //Ports for simulation
   
    wire    [15:0]     mgt0_combusout_i;
    

    
    //Tie offs
    wire               tied_to_ground_i;
    wire    [15:0]     tied_to_ground_vec_i;
    wire               tied_to_vcc_i;
    wire    [15:0]     tied_to_vcc_vec_i;
    
    


//*********************************Main Body of Code**********************************



    // Bufg used to drive user clk on global clock net.
    BUFG  user_clock_bufg_i
    (
        .I(/*rx_rec_clk*/tx_out_clk_i),
        .O(user_clk_i)
    );


    //_______________________________Clock Buffers_________________________________


/*    GT11CLK_MGT GT11CLK_MGT_LEFT 
    (
        .MGTCLKN(REF_CLK2_LEFT_N), 
        .MGTCLKP(REF_CLK2_LEFT_P), 
        .SYNCLK1OUT(ref_clk1_left_i), 
        .SYNCLK2OUT(ref_clk2_left_i)
    );
                                 
   
   defparam GT11CLK_MGT_LEFT.SYNCLK1OUTEN = "DISABLE";
   defparam GT11CLK_MGT_LEFT.SYNCLK2OUTEN = "ENABLE";


    GT11CLK_MGT GT11CLK_MGT_RIGHT 
    (
        .MGTCLKN(REF_CLK2_RIGHT_N), 
        .MGTCLKP(REF_CLK2_RIGHT_P), 
        .SYNCLK1OUT(ref_clk1_right_i), 
        .SYNCLK2OUT(ref_clk2_right_i)
    );
                                 
   
   defparam GT11CLK_MGT_RIGHT.SYNCLK1OUTEN = "DISABLE";
   defparam GT11CLK_MGT_RIGHT.SYNCLK2OUTEN = "ENABLE";*/

    

    //____________________________Register User I/O___________________________________

    // Register User Outputs from core.
    always @(posedge user_clk_i)
    begin
        HARD_ERROR      <=  hard_error_i;
        SOFT_ERROR      <=  soft_error_i;
        FRAME_ERROR     <=  frame_error_i;
        ERROR_COUNT     <=  error_count_i;
        LANE_UP         <=  lane_up_i;
        CHANNEL_UP      <=  channel_up_i;
        TX_LOCK		<= tx_lock_i;
        RX_LOCK		<= rx_lock_i;
    end



    //____________________________Tie off unused signals_______________________________







    // System Interface
    assign  dcm_not_locked_i    =   1'b0;
    assign  power_down_i        =   1'b0;
    assign  loopback_i          =   2'b00;


    //_______________________________ Tie Offs __________________________________
    
    assign  tied_to_ground_i        =    1'b0;
    assign  tied_to_ground_vec_i    =    16'h0000;
    assign  tied_to_vcc_i           =    1'b1;
    assign  tied_to_vcc_vec_i       =    16'hffff;
    
    //_____________________________Debounce the Reset and PMA init signal___________________________


    // Simple Debouncer for Reset button. The debouncer has an
    // asynchronous reset tied to PMA_INIT. This is primarily for simulation, to ensure
    // that unknown values are not driven into the reset line
    always @(posedge user_clk_i or posedge pma_init_r)
        if(pma_init_r)
            reset_debounce_r    <=  4'b1111;
        else
            reset_debounce_r    <=  {RESET,reset_debounce_r[0:2]};


    assign  reset_i =   &reset_debounce_r;

        
    // Assign an IBUFG to INIT_CLK
   /* IBUFG init_clk_ibufg_i
    (
        .I(INIT_CLK),
        .O(init_clk_i)
    );*/


    // Debounce the PMA_INIT signal using the INIT_CLK
    always @(posedge init_clk_i)
        debounce_pma_init_r <=  {PMA_INIT,debounce_pma_init_r[0:2]};
        
    assign  pma_init_r  =   &debounce_pma_init_r;
    
    
    
    //Register the calblock control signals
    always @(posedge init_clk_i)
    begin
        reset_calblocks_r   <=  RESET_CALBLOCKS;
        rx_signal_detect_r  <=  RX_SIGNAL_DETECT;
    end


    //___________________________Module Instantiations_________________________________



    defparam aurora_module.LANE0_GT11_MODE_P = LANE0_GT11_MODE_P;        // Based on MGT Location
    defparam aurora_module.LANE0_MGT_ID_P    = LANE0_MGT_ID_P;
    defparam aurora_module.EXTEND_WATCHDOGS  = EXTEND_WATCHDOGS;
    defparam aurora_module.SIMULATION_P      = SIMULATION_P;      // Set to 1 for simulation
    defparam aurora_module.TXPOST_TAP_PD_P   = TXPOST_TAP_PD_P;   // Default is false, set to FALSE for serial loopback or tuned preemphasis
    aurora aurora_module
    (
    
        //LocalLink TX Interface
        .TX_D(tx_d_i),
        .TX_REM(tx_rem_i),
        .TX_SRC_RDY_N(tx_src_rdy_n_i),
        .TX_SOF_N(tx_sof_n_i),
        .TX_EOF_N(tx_eof_n_i),
    
        .TX_DST_RDY_N(tx_dst_rdy_n_i),
    
	 
        //LocalLink RX Interface
        .RX_D(rx_d_i),
        .RX_REM(rx_rem_i),
        .RX_SRC_RDY_N(rx_src_rdy_n_i),
        .RX_SOF_N(rx_sof_n_i),
        .RX_EOF_N(rx_eof_n_i),
        
    
    
    
    
        //MGT Serial I/O
        .RXP(RXP),
        .RXN(RXN),
    
        .TXP(TXP),
        .TXN(TXN),
    
    
        //MGT Reference Clock Interface
        .REF_CLK2_LEFT(ref_clk2_left_i),
        .REF_CLK2_RIGHT(ref_clk2_right_i),
    
    
        //Error Detection Interface
        .HARD_ERROR(hard_error_i),
        .SOFT_ERROR(soft_error_i),
        
        .FRAME_ERROR(frame_error_i),
        
    
    
        //Status
        .CHANNEL_UP(channel_up_i),
        .LANE_UP(lane_up_i),
    
   
        //Clock Compensation Control Interface
        .WARN_CC(warn_cc_i),
        .DO_CC(do_cc_i),
        
        //Calibration Block Interface
        .CALBLOCK_ACTIVE(),       
        .RESET_CALBLOCKS(reset_calblocks_r),
        .RX_SIGNAL_DETECT(rx_signal_detect_r),
        .DCLK(init_clk_i),

        //Ports for simulation
        .MGT0_COMBUSIN(),
        .MGT0_COMBUSOUT(),
        
    
    
        //System Interface
        .DCM_NOT_LOCKED(dcm_not_locked_i),
        .USER_CLK(user_clk_i),
        
        .RESET(reset_i),
        .POWER_DOWN(power_down_i),    
        .LOOPBACK(loopback_i),
        .PMA_INIT(pma_init_r),
        
        .TX_OUT_CLK(tx_out_clk_i),
		  .RX_REC_CLK(/*rx_rec_clk*/)
    
    );



    aurora_STANDARD_CC_MODULE aurora_standard_cc_module_i
    (
        .RESET(reset_i),
        // Clock Compensation Control Interface
        .WARN_CC(warn_cc_i),
        .DO_CC(do_cc_i),

        // System Interface
        .DCM_NOT_LOCKED(dcm_not_locked_i),
        .USER_CLK(user_clk_i)

    );


    //Use one of the lane up signals to reset the test logic
    assign test_reset_i = !lane_up_i;


    //Connect a frame generator to the TX User interface
    aurora_TX_engine aurora_TX
    (
        // User Interface
		  .TX_CLK_EN(TX_CLK_EN),
        .TX_CLOCK(TX_CLOCK),
        .TX_DATA(TX_DATA),
		  
        .TX_D(tx_d_i),  
        .TX_REM(tx_rem_i),     
        .TX_SOF_N(tx_sof_n_i),       
        .TX_EOF_N(tx_eof_n_i),
        .TX_SRC_RDY_N(tx_src_rdy_n_i),
        .TX_DST_RDY_N(tx_dst_rdy_n_i),

        // System Interface
        .USER_CLK(user_clk_i),       
        .RESET(test_reset_i)
    );

    aurora_RX_engine aurora_RX
    (
        // User Interface
		  
		  .RX_DATA_VALID(RX_DATA_VALID),
        .RX_CLK_EN(RX_CLK_EN),
        .RX_CLOCK(RX_CLOCK),
        .RX_DATA(RX_DATA),

        .RX_D(rx_d_i),  
        .RX_REM(rx_rem_i),     
        .RX_SOF_N(rx_sof_n_i),       
        .RX_EOF_N(rx_eof_n_i),
        .RX_SRC_RDY_N(rx_src_rdy_n_i),  

        // System Interface
        .USER_CLK(user_clk_i),       
        .RESET(test_reset_i),
        .ERROR_COUNT(error_count_i)
    );    
/*
generate
if (USE_CHIPSCOPE==1)
begin : chipscope
assign lane_up_i_i = &lane_up_i;
assign ila_data_i = {tx_d_i[0:15],rx_d_i[0:15],error_count_i,lane_up_i_i,channel_up_i};

//-----------------------------------------------------------------
//  ILA core instance
//-----------------------------------------------------------------
  v4_ila i_ila
    (
      .control(icon_ila_i),
      .clk(user_clk_2x_n_i),
      .trig0(ila_data_i)
    );

//-----------------------------------------------------------------
//  ICON core instance
//-----------------------------------------------------------------
  v4_icon i_icon
    (
      .control0(icon_ila_i)
    );
end
endgenerate
*/
endmodule
/*
//-------------------------------------------------------------------
//  ILA core module declaration
//-------------------------------------------------------------------
module v4_ila
  (
    control,
    clk,
    trig0
  );
  input [35:0] control;
  input clk;
  input [41:0] trig0;
endmodule

//-------------------------------------------------------------------
//  ICON core module declaration
//-------------------------------------------------------------------
module v4_icon
  (
      control0
  );
  output [35:0] control0;
endmodule*/
