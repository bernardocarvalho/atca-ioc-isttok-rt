//
//      Project:  Aurora Module Generator version 3.0
//
//         Date:  $Date: 2008/07/21 10:19:46 $
//          Tag:  $Name: i+IP+144966 $
//         File:  $RCSfile: frame_gen.ejava,v $
//          Rev:  $Revision: 1.1.2.2 $
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

//
//  FRAME GEN
//
//
//
//  Description: This module is a pattern generator to test the Aurora
//               designs in hardware. It generates data and passes it 
//               through the Aurora channel. If connected to a framing 
//               interface, it generates frames of varying size and 
//               separation. The data it generates on each cycle is 
//               a word of all zeros, except for one high bit which 
//               is shifted right each cycle. REM is always set to 
//               the maximum value.

`timescale 1 ns / 10 ps
`define DLY #1


module aurora_TX_engine
(
    // User Interface
    TX_D,  
    TX_REM,     
    TX_SOF_N,       
    TX_EOF_N,
    TX_SRC_RDY_N,
    TX_DST_RDY_N,

    // System Interface
    USER_CLK,       
    RESET,
	 
	 TX_CLK_EN,
    TX_CLOCK,
    TX_DATA
); 

//***********************************Port Declarations*******************************

   // User Interface
    output  [0:31]     TX_D;
    output  [0:1]      TX_REM;
    output             TX_SOF_N;
    output             TX_EOF_N;
    output             TX_SRC_RDY_N;
    input              TX_DST_RDY_N;
    
      // System Interface
    input              USER_CLK;
    input              RESET; 


    input TX_CLK_EN;
    input TX_CLOCK;
    input [31:0] TX_DATA;

//***************************External Register Declarations***************************

    reg                TX_SRC_RDY_N;
    reg                TX_SOF_N;
    reg                TX_EOF_N;    


//***************************Internal Register Declarations*************************** 

    //reg     [0:31]     tx_d_r;    
    reg     [0:7]      frame_size_r;
    reg     [0:7]      bytes_sent_r;
    //reg     [0:3]      ifg_size_r;
    
    //State registers for one-hot state machine
    reg                idle_r;
    reg                single_cycle_frame_r;
    reg                sof_r;
    reg                data_cycle_r;
    reg                eof_r;    

    
 
//*********************************Wire Declarations**********************************
   
    wire               ifg_done_c;
    
    //Next state signals for one-hot state machine
    wire               next_idle_c;
    wire               next_single_cycle_frame_c;
    wire               next_sof_c;
    wire               next_data_cycle_c;
    wire               next_eof_c;
    
    
//*********************************Main Body of Code**********************************

wire empty;
aurora_FIFO TX (
.dout(TX_D),
.rd_clk(USER_CLK),
.rd_en(!TX_DST_RDY_N & idle_r & !empty),
.empty(empty),
.rst(RESET),
.wr_clk(TX_CLOCK),
.wr_en(TX_CLK_EN),
.din(TX_DATA),
.full()
);

reg new_data;
always @(posedge USER_CLK)
 if(!TX_DST_RDY_N & idle_r & !empty)
  new_data <= 1;			
 else if(!TX_DST_RDY_N & single_cycle_frame_r & empty)
  new_data <= 0;

    //______________________________ Transmit Data  __________________________________    
    //Transmit data when TX_DST_RDY_N is asserted and not in an IFG
  /*  always @(posedge USER_CLK)
        if(RESET)
         tx_d_r          <=  `DLY    32'd1;			
        else if(!TX_DST_RDY_N && !idle_r)
         tx_d_r          <=  `DLY    {tx_d_r[31],tx_d_r[0:30]};
    
    //Connect TX_D to the internal tx_d_r register
    assign  TX_D    =   tx_d_r;*/
    

    //Tie REM to indicate all words valid
    assign  TX_REM  =   2'd3;
    

    //Use a counter to determine the size of the next frame to send
    /*always @(posedge USER_CLK)
        if(RESET)   
            frame_size_r    <=  `DLY    8'h00;
        else if(single_cycle_frame_r || eof_r)
            frame_size_r    <=  `DLY    frame_size_r + 1;
            
    
    //Use a second counter to determine how many bytes of the frame have already been sent
    always @(posedge USER_CLK)
        if(RESET)
            bytes_sent_r    <=  `DLY    8'h00;
        else if(sof_r)
            bytes_sent_r    <=  `DLY    8'h01;
        else if(!TX_DST_RDY_N && !idle_r)
            bytes_sent_r    <=  `DLY    bytes_sent_r + 1;
    
    
    //Use a freerunning counter to determine the IFG
    always @(posedge USER_CLK)
        if(RESET)
            ifg_size_r      <=  `DLY    4'h0;
        else
            ifg_size_r      <=  `DLY    ifg_size_r + 1;
            
    
    //IFG is done when ifg_size register is 0
    assign  ifg_done_c  =  (ifg_size_r == 4'h0);*/
    
    
    
    //_____________________________ Framing State machine______________________________ 
    //Use a state machine to determine whether to start a frame, end a frame, send
    //data or send nothing
    
    //State registers for 1-hot state machine
    always @(posedge USER_CLK)
        if(RESET)
        begin
            idle_r                  <=  `DLY    1'b1;
            single_cycle_frame_r    <=  `DLY    1'b0;
            sof_r                   <=  `DLY    1'b0;
            data_cycle_r            <=  `DLY    1'b0;
            eof_r                   <=  `DLY    1'b0;
        end
        else if(!TX_DST_RDY_N)
        begin
            idle_r                  <=  `DLY    next_idle_c;
            single_cycle_frame_r    <=  `DLY    next_single_cycle_frame_c;
            sof_r                   <=  `DLY    next_sof_c;
            data_cycle_r            <=  `DLY    next_data_cycle_c;
            eof_r                   <=  `DLY    next_eof_c;
        end
        
        
    //Nextstate logic for 1-hot state machine
    assign  next_idle_c                 =   !new_data && //!ifg_done_c &&
                                            (single_cycle_frame_r || eof_r || idle_r);
    
    assign  next_single_cycle_frame_c   =   new_data && //(ifg_done_c && (frame_size_r == 0)) &&
                                            (idle_r || single_cycle_frame_r || eof_r);
                                            
    assign  next_sof_c                  =   0;//(ifg_done_c && (frame_size_r != 0)) &&
                                            //(idle_r || single_cycle_frame_r || eof_r);
                                            
    assign  next_data_cycle_c           =   0;//(frame_size_r != bytes_sent_r) &&
                                            //(sof_r || data_cycle_r);
                                            
    assign  next_eof_c                  =   0;//(frame_size_r == bytes_sent_r) &&
                                            //(sof_r || data_cycle_r);
    
    
    //Output logic for 1-hot state machine
    always @(posedge USER_CLK)
        if(RESET)
        begin
            TX_SOF_N        <=  `DLY    1'b1;
            TX_EOF_N        <=  `DLY    1'b1;
            TX_SRC_RDY_N    <=  `DLY    1'b1;    
        end
        else if(!TX_DST_RDY_N)
        begin
            TX_SOF_N        <=  `DLY    !(sof_r || single_cycle_frame_r);
            TX_EOF_N        <=  `DLY    !(eof_r || single_cycle_frame_r);
            TX_SRC_RDY_N    <=  `DLY    idle_r;
        end            

                

    
endmodule 
