//--------------------------------------------------------------------------------
//--
//-- This file is owned and controlled by Xilinx and must be used solely
//-- for design, simulation, implementation and creation of design files
//-- limited to Xilinx devices or technologies. Use with non-Xilinx
//-- devices or technologies is expressly prohibited and immediately
//-- terminates your license.
//--
//-- Xilinx products are not intended for use in life support
//-- appliances, devices, or systems. Use in such applications is
//-- expressly prohibited.
//--
//--            **************************************
//--            ** Copyright (C) 2005, Xilinx, Inc. **
//--            ** All Rights Reserved.             **
//--            **************************************
//--
//--------------------------------------------------------------------------------
//-- Filename: PIO_32_RX_ENGINE.v
//--
//-- Description: 32 bit Local-Link Receive Unit. 
//--
//--------------------------------------------------------------------------------

`timescale 1ns/1ns

`define PIO_32_RX_MEM_RD_FMT_TYPE 7'b00_00000
`define PIO_32_RX_MEM_WR_FMT_TYPE 7'b10_00000

`define PIO_32_RX_RST_STATE       8'b00000000
`define PIO_32_RX_MEM_RD_DW1      8'b00000001
`define PIO_32_RX_MEM_RD_DW2      8'b00000010
`define PIO_32_RX_MEM_WR_DW1      8'b00000100
`define PIO_32_RX_MEM_WR_DW2      8'b00001000
`define PIO_32_RX_MEM_WR_DW3      8'b00010000
`define PIO_32_RX_MEM_WR_DW4      8'b00100000
`define PIO_32_RX_WAIT_STATE      8'b10000000

module RX_ENGINE_32 (
                        clk,
                        rst_n,

                        /*
                         * Receive local link interface from PCIe core
                         */
                    
                        trn_rd,  
                        trn_rsof_n,
                        trn_reof_n,
                        trn_rsrc_rdy_n,
                        trn_rsrc_dsc_n,
                        trn_rdst_rdy_n,

                        /*
                         * Memory Read data handshake with Completion
                         * transmit unit. Transmit unit reponds to
                         * req_compl assertion and responds with compl_done
                         * assertion when a Completion w/ data is transmitted.
                         */

                        req_compl_o,
                        compl_done_i,

                        req_tc_o,                  // Memory Read TC
                        req_td_o,                  // Memory Read TD
                        req_ep_o,                  // Memory Read EP
                        req_attr_o,                // Memory Read Attribute
                        req_len_o,                 // Memory Read Length (1DW)
                        req_rid_o,                 // Memory Read Requestor ID
                        req_tag_o,                 // Memory Read Tag
                        req_be_o,                  // Memory Read Byte Enables
                        req_addr_o,                // Memory Read Address

                         /* 
                         * Memory interface used to save 1 DW data received
                         * on Memory Write 32 TLP. Data extracted from
                         * inbound TLP is presented to the Endpoint memory
                         * unit. Endpoint memory unit reacts to wr_en_o
                         * assertion and asserts wr_busy_i when it is
                         * processing written information.
                         */

                        addr_o,                 // Memory Write Address
                        wr_data_o,                 // Memory Write Data
                        wr_en_o,                   // Memory Write Enable
                        wr_busy_i,                  // Memory Write Busy
							   wr_rd_len_o
								
                       );

    input              clk;
    input              rst_n;

    input [31:0]       trn_rd;
    input              trn_rsof_n;
    input              trn_reof_n;
    input              trn_rsrc_rdy_n;
    input              trn_rsrc_dsc_n;
    output             trn_rdst_rdy_n;
 
    output             req_compl_o;
    input              compl_done_i;

    output [2:0]       req_tc_o;
    output             req_td_o;
    output             req_ep_o;
    output [1:0]       req_attr_o;
    output [9:0]       req_len_o;
    output [15:0]      req_rid_o;
    output [7:0]       req_tag_o;
    output [7:0]       req_be_o;
    output [6:0]       req_addr_o;

    output [31:0]      addr_o;      //64 bytes
    output [31:0]      wr_data_o;
    output             wr_en_o;
    input              wr_busy_i;
	 output [9:0]		  wr_rd_len_o; 
	 

    // Local Registers

    reg                trn_rdst_rdy_n;

    reg                req_compl_o;

    reg [2:0]          req_tc_o;
    reg                req_td_o;
    reg                req_ep_o;
    reg [1:0]          req_attr_o;
    reg [9:0]          req_len_o;
    reg [15:0]         req_rid_o;
    reg [7:0]          req_tag_o;
    reg [7:0]          req_be_o;
    reg [6:0]          req_addr_o;

    reg [31:0]         addr_o;

	 reg [31:0]         wr_data_o;
    reg                wr_en_o;

    reg [7:0]          state;
    reg [6:0]          tlp_type;
	 
	 reg [9:0]          wr_rd_len_o; 
	 

    always @ ( posedge clk or negedge rst_n ) begin
              
        if (!rst_n ) begin

          trn_rdst_rdy_n <= 1'b0;

          req_compl_o    <= 1'b0;
          req_tc_o       <= 2'b0;
          req_td_o       <= 1'b0;
          req_ep_o       <= 1'b0;
          req_attr_o     <= 2'b0;
          req_len_o      <= 10'b0;
          req_rid_o      <= 16'b0;
          req_tag_o      <= 8'b0;
          req_be_o       <= 8'b0;
          req_addr_o     <= 7'b0;

          addr_o      <= 32'b0;
          wr_data_o      <= 32'b0;
          wr_en_o        <= 1'b0;
          wr_rd_len_o    <= 10'b0;
          state          <= `PIO_32_RX_RST_STATE;
          tlp_type       <= 7'b0;

        end else begin

          wr_en_o        <= 1'b0;
          req_compl_o    <= 1'b0;

          case (state)

            `PIO_32_RX_RST_STATE : begin 

				     trn_rdst_rdy_n <= 1'b0;
      
					if ((!trn_rsof_n) && 
                  (!trn_rsrc_rdy_n) && 
                  (!trn_rdst_rdy_n)) begin

                case (trn_rd[30:24]) 

                  `PIO_32_RX_MEM_RD_FMT_TYPE : begin  

							 tlp_type     <= trn_rd[30:24];
                      req_tc_o     <= trn_rd[22:20];  
                      req_td_o     <= trn_rd[15];
                      req_ep_o     <= trn_rd[14]; 
                      req_attr_o   <= trn_rd[13:12]; 
                      req_len_o    <= trn_rd[09:00]; 
							 wr_rd_len_o  <= trn_rd[09:00]; 
                      state        <= `PIO_32_RX_MEM_RD_DW1; 
						 end 
						 
                  `PIO_32_RX_MEM_WR_FMT_TYPE : begin

							tlp_type     <= trn_rd[30:24];
							req_len_o    <= trn_rd[09:00]; 
							wr_rd_len_o  <= trn_rd[09:00]; 
							state        <= `PIO_32_RX_MEM_WR_DW1; 
						 end 
             
                   default : begin // other TLPs

                    state        <= `PIO_32_RX_RST_STATE; 

                   end
              
                endcase
         
              end else
                state <= `PIO_32_RX_RST_STATE;
				end

            `PIO_32_RX_MEM_RD_DW1 : begin

              if ((!trn_rsrc_rdy_n) && 
                  (!trn_rdst_rdy_n)) begin

                req_rid_o    <= trn_rd[31:16]; 
                req_tag_o    <= trn_rd[15:08]; 
                req_be_o     <= trn_rd[07:00];
                state        <= `PIO_32_RX_MEM_RD_DW2; 

              end else
                state        <= `PIO_32_RX_MEM_RD_DW1; 
         
            end

            `PIO_32_RX_MEM_RD_DW2 : begin

              if ((!trn_rsrc_rdy_n) && 
                  (!trn_rdst_rdy_n)) begin

                req_addr_o   		<= {trn_rd[6:02], 2'b00}; //DW
                req_compl_o  		<= 1'b1;
                trn_rdst_rdy_n 	<= 1'b1;
					 addr_o        <= {trn_rd[31:2],2'b0};  
                state        		<= `PIO_32_RX_WAIT_STATE; 

              end else
                 state        <= `PIO_32_RX_MEM_RD_DW2; 

            end

            `PIO_32_RX_MEM_WR_DW1 : begin

              if ((!trn_rsrc_rdy_n) && 
                  (!trn_rdst_rdy_n)) begin

                //wr_be_o      <= trn_rd[07:00];
                state        <= `PIO_32_RX_MEM_WR_DW2; 
              end else
                state        <= `PIO_32_RX_MEM_WR_DW1;       
            end

            `PIO_32_RX_MEM_WR_DW2 : begin

              if ((!trn_rsrc_rdy_n) && 
                  (!trn_rdst_rdy_n)) begin

                addr_o    <= {trn_rd[31:2],2'b0};
                state        <= `PIO_32_RX_MEM_WR_DW3; 

              end else 
                 state        <= `PIO_32_RX_MEM_WR_DW2; 
         
            end

            `PIO_32_RX_MEM_WR_DW3 : begin

              if ((!trn_rsrc_rdy_n) && 
                  (!trn_rdst_rdy_n) &&
						(!trn_reof_n)) begin

                wr_data_o  <= {trn_rd[07:00],trn_rd[15:08],trn_rd[23:16],trn_rd[31:24]};
                wr_en_o    <= 1'b1;
                trn_rdst_rdy_n <= 1'b1;

                state      <= `PIO_32_RX_WAIT_STATE;
					 
				  end else if ((!trn_rsrc_rdy_n) && 
								  (!trn_rdst_rdy_n) &&
								  (trn_reof_n)) begin
              
				    wr_data_o  <= {trn_rd[07:00],trn_rd[15:08],trn_rd[23:16],trn_rd[31:24]};
                wr_en_o    <= 1'b1;
					 
					 state        <= `PIO_32_RX_MEM_WR_DW3; 
				 
					end else 
                 state        <= `PIO_32_RX_MEM_WR_DW3; 
            end

            `PIO_32_RX_WAIT_STATE : begin

              wr_en_o      <= 1'b0;
              req_compl_o  <= 1'b0;

              if ((tlp_type == `PIO_32_RX_MEM_WR_FMT_TYPE) &&
                  (!wr_busy_i)) begin

                trn_rdst_rdy_n <= 1'b0;
                state          <= `PIO_32_RX_RST_STATE; 

              end else if ((tlp_type == `PIO_32_RX_MEM_RD_FMT_TYPE) &&
                           (compl_done_i)) begin

                trn_rdst_rdy_n <= 1'b0;
                state          <= `PIO_32_RX_RST_STATE; 

              end else
                state          <= `PIO_32_RX_WAIT_STATE; 

            end
                   
          endcase

        end   

    end       


endmodule // PIO_32_RX_ENGINE
