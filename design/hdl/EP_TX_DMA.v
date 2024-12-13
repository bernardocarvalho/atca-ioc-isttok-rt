`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IPFN
// Engineer: Ana Fernandes
// 
// Create Date:  16:49:27 04/07/2007 
// Design Name:  ML405
// Module Name:  EP_TX_DMA 
// Project Name: ML405
// Target Devices: XC4VFX20-FF672-10; XC4VFX60-FF1152;
// Tool versions: ISE9.2
// Description: Send packets in DMA mode with  max. payload 
//
// Dependencies: 
//
// Revision: 
// Revision 0.03 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/1ns

`define PIO_32_TX_CPLD_FMT_TYPE 7'b10_01010
`define PIO_32_TX_MWR_FMT_TYPE 7'b10_00000

`define PIO_32_TX_RST_STATE    5'b00000
`define PIO_32_TX_MWR_DW1      5'b00001
`define PIO_32_TX_MWR_DW2      5'b00010
`define PIO_32_TX_MWR_DW3      5'b00100
//`define new_payload				 5'b01000	

`define PIO_32_TX_CPLD_DW1      5'b01001
`define PIO_32_TX_CPLD_DW2      5'b01010
`define PIO_32_TX_CPLD_DW3      5'b01100


module EP_TX_DMA(

								clk,
                        rst_n,

                        trn_td,
                        trn_tsof_n,
                        trn_teof_n,
                        trn_tsrc_rdy_n,
                        trn_tsrc_dsc_n,
                        trn_tdst_rdy_n,
                        trn_tdst_dsc_n,

                        requester_id_i,
                        cfg_bus_mstr_enable_i, 
								
								compl_done_o,  

								req_tc_i,     
                        req_td_i,    
                        req_ep_i,   
                        req_attr_i,
                        req_len_i,         
                        req_rid_i,        
                        req_tag_i,       
                        req_be_i,
                        req_addr_i,  
								
                        start_wr, // when memory is half full						

                        data_i,
								addr_i, 
																                     
                        start_compl,

								data_payload


                        );

    input               clk;
    input               rst_n;
 
    output [31:0]       trn_td;
    output              trn_tsof_n;
    output              trn_teof_n;
    output              trn_tsrc_rdy_n;
    output              trn_tsrc_dsc_n;
    input               trn_tdst_rdy_n;
    input               trn_tdst_dsc_n;

    input               start_wr; 	
					 
    output              compl_done_o;

    input [31:0]        data_i;
    input [31:0]        addr_i;

    input [15:0]        requester_id_i;

	 input [2:0]         req_tc_i;
    input               req_td_i;
    input               req_ep_i;
    input [1:0]         req_attr_i;
    input [9:0]         req_len_i;
    input [15:0]        req_rid_i;
    input [7:0]         req_tag_i;
    input [7:0]         req_be_i;
    input [6:0]        req_addr_i;
	 	 
	 input 					start_compl; 
    
	 input               cfg_bus_mstr_enable_i;
	 
	 input [5:0]         data_payload; 
    
	 wire [15:0]        completer_id_i;
    assign completer_id_i = requester_id_i; 
	 
	 // Local registers
	 wire [2:0]         	req_tc_wr;
    wire               	req_td_wr;
    wire               	req_ep_wr;
    wire [1:0]         	req_attr_wr;
    wire [9:0]          req_len_wr;
	 wire [7:0]         	req_tag_wr;
    wire [3:0]				last_DW_wr; 
    wire [3:0]	         first_DW_wr; 
	 
	 assign 	 req_tc_wr 	 = 	3'b0;
	 assign 	 req_td_wr 	 = 	1'b0; 
	 assign 	 req_ep_wr 	 = 	1'b0; 
	 assign 	 req_attr_wr  = 	2'b00; 
	 assign 	 req_len_wr   = 	data_payload[5:0];     //data payload max in DW: 32DW (6 bits)
	 assign 	 req_tag_wr   =    8'b00001111; 
    assign 	 last_DW_wr	 =    4'b1111; 
    assign 	 first_DW_wr  = 	4'b1111; 

	  
    reg [31:0]          trn_td;
    reg                 trn_tsof_n;
    reg                 trn_teof_n;
    reg                 trn_tsrc_rdy_n;
    reg                 trn_tsrc_dsc_n;
 
    reg                 compl_done_o;
    reg [4:0]           state;
	 
	 reg [9:0]           rd_len;  
   
       reg [11:0]          byte_count;
    reg [06:0]          lower_addr;
    wire  [7:0]         rd_be_o;

     // Present address and byte enable to memory module
    assign rd_be_o =   req_be_i[7:0]; 

    //Calculate byte count based on byte enable and req_len (data payload) 
    // page 91 - PCI express base specification rev 1.1
  
	 // according to last bit and first bit
	 always @ (rd_be_o ) begin
      casex (rd_be_o[7:0])
			8'b00001xx1 : byte_count = 12'h004;   
			8'b000001x1 : byte_count = 12'h003; 
			8'b00001x10 : byte_count = 12'h003; 
			8'b00000011 : byte_count = 12'h002;
			8'b00000110 : byte_count = 12'h002;
			8'b00001100 : byte_count = 12'h002; 
			8'b00000001 : byte_count = 12'h001;
			8'b00000010 : byte_count = 12'h001;
			8'b00000100 : byte_count = 12'h001;
			8'b00001000 : byte_count = 12'h001;
			8'b00000000 : byte_count = 12'h001;
			8'b1xxxxxx1 : byte_count = req_len_i*3'b100;        
			8'b01xxxxx1 : byte_count = req_len_i*3'b100 - 1'b1;
			8'b001xxxx1 : byte_count = req_len_i*3'b100 - 2'b10;
			8'b0001xxx1 : byte_count = req_len_i*3'b100 - 2'b11;
			8'b1xxxxx10 : byte_count = req_len_i*3'b100 - 1'b1;
			8'b01xxxx10 : byte_count = req_len_i*3'b100 - 2'b10;
			8'b001xxx10 : byte_count = req_len_i*3'b100 - 2'b11;        
			8'b0001xx10 : byte_count = req_len_i*3'b100 - 3'b100;
			8'b1xxxx100 : byte_count = req_len_i*3'b100 - 2'b10;
			8'b01xxx100 : byte_count = req_len_i*3'b100 - 2'b11;		  
			8'b001xx100 : byte_count = req_len_i*3'b100 - 3'b100;		        
			8'b0001x100 : byte_count = req_len_i*3'b100 - 3'b101;       
			8'b1xxx1000 : byte_count = req_len_i*3'b100 - 2'b11;		  
			8'b01xx1000 : byte_count = req_len_i*3'b100 - 3'b100;        
			8'b001x1000 : byte_count = req_len_i*3'b100 - 3'b101;		  
			8'b00011000 : byte_count = req_len_i*3'b100 - 3'b110;	  	
      endcase  
    end

     // Calculate lower address based on  byte enable
     // page 91 - PCI express base specification rev 1.1

    always @ (rd_be_o ) begin

      casex (rd_be_o[3:0])    
        4'b0000 : lower_addr = {req_addr_i[6:2], 2'b00}; //offset = o 
        4'bxxx1 : lower_addr = {req_addr_i[6:2], 2'b00};  
        4'bxx10 : lower_addr = {req_addr_i[6:2], 2'b01}; //offset = 1
		  4'bx100 : lower_addr = {req_addr_i[6:2], 2'b10}; //offset = 2
        4'b1000 : lower_addr = {req_addr_i[6:2], 2'b11}; //offset = 3

      endcase

    end

	 
	 //reg  [7:0]          count_payload; 


   // * State Machine to generate Completion with DW Payload
    always @ ( posedge clk or negedge rst_n ) begin

        if (!rst_n ) begin

          trn_tsof_n        <= 1'b1;
          trn_teof_n        <= 1'b1;
          trn_tsrc_rdy_n    <= 1'b1;
          trn_tsrc_dsc_n    <= 1'b1;
          trn_td            <= 32'b0;
			 rd_len	          <= 10'b0;
          compl_done_o      <= 1'b0;
			 //count_payload		 <= 8'h80; 
          state             <= `PIO_32_TX_RST_STATE;

        end else begin 

          compl_done_o      <= 1'b0;

          case ( state )

            `PIO_32_TX_RST_STATE : begin

              trn_tsrc_dsc_n   <= 1'b1;
				 // count_payload	 <= 8'h80; 
				  

               if (!trn_tdst_rdy_n && start_wr && trn_tdst_dsc_n) begin  //DMA

                trn_tsof_n       <= 1'b0;
                trn_teof_n       <= 1'b1;
                trn_tsrc_rdy_n   <= 1'b0;
                trn_td           <= { 
                                    {1'b0}, 
                                    `PIO_32_TX_MWR_FMT_TYPE, 
                                    {1'b0}, 
                                    req_tc_wr, 
                                    {4'b0}, 
                                    req_td_wr, 
                                    req_ep_wr, 
                                    req_attr_wr, 
                                    {2'b0}, 
                                    req_len_wr 
                                    };							
                state            <= `PIO_32_TX_MWR_DW1;

              end else if (!trn_tdst_rdy_n && start_compl && trn_tdst_dsc_n) begin //Completion

                trn_tsof_n       <= 1'b0;
                trn_teof_n       <= 1'b1;
                trn_tsrc_rdy_n   <= 1'b0;
                trn_td           <= { 
                                    {1'b0}, 
                                    `PIO_32_TX_CPLD_FMT_TYPE, 
                                    {1'b0}, 
                                    req_tc_i, 
                                    {4'b0}, 
                                    req_td_i, 
                                    req_ep_i, 
                                    req_attr_i, 
                                    {2'b0}, 
                                    req_len_i 
                                    };							
                state            <= `PIO_32_TX_CPLD_DW1;

					 


              end else begin 

                trn_tsof_n       <= 1'b1;
                trn_teof_n       <= 1'b1;
                trn_tsrc_rdy_n   <= 1'b1;
                trn_td           <= 32'b0;
                state            <= `PIO_32_TX_RST_STATE;

              end

            end

            `PIO_32_TX_MWR_DW1 : begin

              if (!trn_tdst_dsc_n) begin

                trn_tsrc_dsc_n   <= 1'b0;
                state            <= `PIO_32_TX_RST_STATE;
              
              end else if (!trn_tdst_rdy_n) begin

                trn_tsof_n       <= 1'b1;
                trn_teof_n       <= 1'b1;
                trn_tsrc_rdy_n   <= 1'b0;
                trn_td           <= { 
                                    requester_id_i, 
                                    req_tag_wr, 
                                    last_DW_wr, 
                                    first_DW_wr

                                    };
                state            <= `PIO_32_TX_MWR_DW2;

              end else
                state            <= `PIO_32_TX_MWR_DW1;

            end

            `PIO_32_TX_MWR_DW2 : begin

              if (!trn_tdst_dsc_n) begin

                trn_tsrc_dsc_n   <= 1'b0;
                state            <= `PIO_32_TX_RST_STATE;
              
              end else if (!trn_tdst_rdy_n) begin

                trn_tsof_n       <= 1'b1;
                trn_teof_n       <= 1'b1;
                trn_tsrc_rdy_n   <= 1'b0;
                trn_td           <= {addr_i[31:2],
												{2'b0}
                                    };
                state            <= `PIO_32_TX_MWR_DW3;
					 rd_len	         <= req_len_wr;

              end else
                state            <= `PIO_32_TX_MWR_DW2;

            end

            `PIO_32_TX_MWR_DW3 : begin

              if (!trn_tdst_dsc_n) begin

                trn_tsrc_dsc_n   <= 1'b1;
					 
                state            <= `PIO_32_TX_RST_STATE;
              
              end else if (!trn_tdst_rdy_n) begin 
				  		   			
					 trn_tsof_n       <= 1'b1;
					 trn_tsrc_rdy_n   <= 1'b0;
                trn_td           <= {data_i[07:00],data_i[15:08],data_i[23:16],data_i[31:24]}; 
				
				    if ((rd_len == 1'b1) || (rd_len == 1'b0)) begin 
							trn_teof_n       <= 1'b0;              
							compl_done_o     <= 1'b1;
							state            <= `PIO_32_TX_RST_STATE;
							rd_len 			  <= 10'b0;
					 
					/* end else if (count_payload == 7'b0) begin 
					 		trn_teof_n       <= 1'b0;              
							compl_done_o     <= 1'b0;
							state            <= `new_payload ;
							rd_len 			  <= rd_len - 1'b1;
							count_payload    <= 8'h80; */
					 				 
					 end else begin 
							trn_teof_n       <= 1'b1;              
							compl_done_o     <= 1'b0;
							state            <= `PIO_32_TX_MWR_DW3;
							rd_len 			  <= rd_len - 1'b1;
						//	count_payload    <= count_payload - 1'b1; 
							
					end 
				
              end else
                state            <= `PIO_32_TX_MWR_DW3;

            end
				
		/*	`new_payload : begin


              if (!trn_tdst_dsc_n) begin

                trn_tsrc_dsc_n   <= 1'b1;
					 
                state            <= `PIO_32_TX_RST_STATE;
					 
             end else if (!trn_tdst_rdy_n) begin

                count_payload    <= 8'h80;  
					 trn_tsof_n       <= 1'b0;
                trn_teof_n       <= 1'b1;
                trn_tsrc_rdy_n   <= 1'b0;
                trn_td           <= { 
                                    {1'b0}, 
                                    `PIO_32_TX_MWR_FMT_TYPE, 
                                    {1'b0}, 
                                    req_tc_i, 
                                    {4'b0}, 
                                    req_td_i, 
                                    req_ep_i, 
                                    req_attr_i, 
                                    {2'b0}, 
                                    req_len_i 
                                    };							
                state            <= `PIO_32_TX_MWR_DW1;

              end else begin 

                trn_tsof_n       <= 1'b1;
                trn_teof_n       <= 1'b1;
                trn_tsrc_rdy_n   <= 1'b1;
                trn_td           <= 32'b0;
                state            <= `PIO_32_TX_RST_STATE;

              end

            end	*/
				
`PIO_32_TX_CPLD_DW1 : begin

              if (!trn_tdst_dsc_n) begin

                trn_tsrc_dsc_n   <= 1'b0;
                state            <= `PIO_32_TX_RST_STATE;
              
              end else if (!trn_tdst_rdy_n) begin

                trn_tsof_n       <= 1'b1;
                trn_teof_n       <= 1'b1;
                trn_tsrc_rdy_n   <= 1'b0;
                trn_td           <= { 
                                    completer_id_i, 
                                    {3'b0}, 
                                    {1'b0}, 
                                    byte_count 
                                    };
                state            <= `PIO_32_TX_CPLD_DW2;

              end else
                state            <= `PIO_32_TX_CPLD_DW1;

            end

 `PIO_32_TX_CPLD_DW2 : begin

              if (!trn_tdst_dsc_n) begin

                trn_tsrc_dsc_n   <= 1'b0;
                state            <= `PIO_32_TX_RST_STATE;
              
              end else if (!trn_tdst_rdy_n) begin

                trn_tsof_n       <= 1'b1;
                trn_teof_n       <= 1'b1;
                trn_tsrc_rdy_n   <= 1'b0;
                trn_td           <= { 
                                    req_rid_i, 
                                    req_tag_i, 
                                    {1'b0}, 
                                    lower_addr
                                    };
                state            <= `PIO_32_TX_CPLD_DW3;
					// rd_len	         <= req_len_i;
              end else
                state            <= `PIO_32_TX_CPLD_DW2;

            end

  `PIO_32_TX_CPLD_DW3 : begin

              if (!trn_tdst_dsc_n) begin

                trn_tsrc_dsc_n   <= 1'b1;
                state            <= `PIO_32_TX_RST_STATE;
              
              end else if (!trn_tdst_rdy_n) begin 
				  		   			
					 trn_tsof_n       <= 1'b1;
					 trn_tsrc_rdy_n   <= 1'b0;
                trn_td           <= {data_i[07:00],data_i[15:08],data_i[23:16],data_i[31:24]}; 
                                  
				
				   // if ((rd_len == 1'b1) || (rd_len == 1'b0)) begin 
							trn_teof_n       <= 1'b0;              
							compl_done_o     <= 1'b1;
							state            <= `PIO_32_TX_RST_STATE;
						//	rd_len 			  <= 10'b0;
					/* end else begin 
							trn_teof_n       <= 1'b1;              
							compl_done_o     <= 1'b0;
							state            <= `PIO_32_TX_CPLD_DW3;
							rd_len 			  <= rd_len - 1'b1; 
							
						end */
				
              end else
                state            <= `PIO_32_TX_CPLD_DW3;

            end

				default : begin
					 state            <= `PIO_32_TX_RST_STATE;
		
				end
				
          endcase

        end

    end

endmodule
