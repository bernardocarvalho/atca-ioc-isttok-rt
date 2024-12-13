`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: IPFN
// Engineer: Ana Fernandes
// 
// Create Date: 21:52:50 07/02/2008 
// Design Name: ML405
// Module Name: PCIe_32_BITS
// Project Name: ML405
// Target Devices: XC4VFX20-FF672-10
// Tool versions: ISE9.2
// Description: INTERFACE PCIe logic Core - RX module - TX_DMA module and Turnoff module
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module PCIe_32_BITS(

output 		  PCIe_TX_P,
output 		  PCIe_TX_N,
input  		  PCIe_RX_P,
input  		  PCIe_RX_N,

input         PCIe_reset,
input         PCIe_clock,
//input  		  PCIe_CLOCK_P, 
//input  		  PCIe_CLOCK_N, 

output 		  PCIe_trn_clk,
output 		  PCIe_trn_rst,

output 		  PCIe_wr_en,
output [31:0] PCIe_wr_addr,
output [31:0] PCIe_wr_data, 
output [9:0]  PCIe_LEN,

output [31:0] BAR1_SEL, 
output        BAR0_SEL, 

input  [31:0] BAR1_ACT_REG, 

//DATA FOR DMA/req comp BAR0
output [31:0] PCIe_rd_addr,
output        PCIe_req_en,
input 		  PCIe_rd_en,   		
input  [31:0] PCIe_rd_data, 

output        busy,

//DEBUG 
/*output  		   ACQC, 
output 		   DMAC,  
output			start_interrupt,
output 			half_mem,
output         empty_dma_fifo, 
output         rd_en, 
output         DMAn, 
output         DMAE_r3, 
output         trig_cbuffer,
output         cfg_interrupt_n_out,
output 			cfg_interrupt_rdy_n_out,
output   		cfg_interrupt_msienable, // 0 - legacy; 1 - MSI

output 			SERR_Enable,
output 			Recived_MASTER_ABORT,
output 			Recived_TARGET_ABORT,
output 			signaled_TARGET_ABORT,
output 			Interrupt_status,*/
input DSP_clock,
output software_trigger,
output software_reset,
input master_slave,
output DMA_sync,
input DMA_enable,
input RTM_present,
input [3:0] slot_id,
output [15:0] DAC_1,
output [15:0] DAC_2,
output [15:0] DAC_3,
output [15:0] DAC_4,
output [15:0] DAC_5,
output [15:0] DAC_6,
output [15:0] DAC_7,
output [15:0] DAC_8,	
output [3:0] ERFA_current
);

//----- ENDPOINT CORE ------------------//			    
wire                      trn_reset_n_c;
wire                      trn_lnk_up_n_c;
wire    [31:0]       	  trn_td_c;
wire                      trn_tsof_n_c;
wire                      trn_teof_n_c;
wire                      trn_tsrc_dsc_n_c;
wire                      trn_tdst_rdy_n_c;
wire                      trn_tdst_dsc_n_c; 
wire                      trn_terrfwd_n_c;
wire    [31:0]            trn_rd_c;
wire                      trn_rsof_n_c;
wire                      trn_reof_n_c;
wire                      trn_rsrc_rdy_n_c;
wire                      trn_rsrc_dsc_n_c;
wire                      trn_rdst_rdy_n_c;
wire                      trn_rerrfwd_n_c;
wire                      trn_rnp_ok_n_c;
wire    [6:0]      		  trn_rbar_hit_n_c;
wire    [7:0]      		  trn_rfc_nph_av_c;
wire    [11:0]     		  trn_rfc_npd_av_c;
wire    [7:0]       		  trn_rfc_ph_av_c;
wire    [11:0]      		  trn_rfc_pd_av_c;
wire    [7:0]       		  trn_rfc_cplh_av_c;
wire    [11:0]      		  trn_rfc_cpld_av_c;
wire    [31:0]            cfg_do_c;
wire    [31:0]            cfg_di_c;
wire    [9:0]             cfg_dwaddr_c;
wire    [3:0]             cfg_byte_en_n_c;
wire                      cfg_wr_en_n_c;
wire                      cfg_rd_en_n_c;
wire                      cfg_rd_wr_done_n_c;
wire                      cfg_err_cor_n_c;
wire                      cfg_err_ur_n_c;
wire                      cfg_err_ecrc_n_c;
wire                      cfg_err_cpl_timeout_n_c;
wire                      cfg_err_cpl_abort_n_c;
wire                      cfg_err_cpl_unexpect_n_c;
wire                      cfg_err_posted_n_c;    
wire    [47:0]            cfg_err_tlp_cpl_header_c;
wire                      cfg_turnoff_ok_n_c;
wire                      cfg_to_turnoff_n_c;
wire                      cfg_trn_pending_n_c;
wire                      cfg_pm_wake_n_c;
wire    [2:0]        	  cfg_pcie_link_state_n_c;
wire    [63:0]            cfg_dsn_c;
wire    [7:0]       		  cfg_bus_number_c;
wire    [4:0]       		  cfg_device_number_c;
wire    [2:0]       		  cfg_function_number_c;
wire    [15:0]            cfg_status_c;
wire    [15:0]            cfg_command_c;
wire    [15:0]            cfg_dstatus_c;
wire    [15:0]            cfg_dcommand_c;
wire    [15:0]            cfg_lstatus_c;
wire    [15:0]            cfg_lcommand_c; 
wire    [7:0]             cfg_interrupt_do;
//wire    [2:0]             cfg_interrupt_mmenable;
//wire                      cfg_interrupt_msienable;

		// Core input tie-offs
	assign trn_rnp_ok_n_c  = 1'b0;
	assign trn_terrfwd_n_c = 1'b1;
	assign cfg_err_cor_n_c = 1'b1;
	assign cfg_err_ur_n_c  = 1'b1;
	assign cfg_err_ecrc_n_c = 1'b1;
	assign cfg_err_cpl_timeout_n_c = 1'b1;
	assign cfg_err_cpl_abort_n_c = 1'b1;
	assign cfg_err_cpl_unexpect_n_c = 1'b1;
	assign cfg_err_posted_n_c = 1'b0;
	assign cfg_pm_wake_n_c = 1'b1;
	assign cfg_trn_pending_n_c = 1'b1;
	assign cfg_dwaddr_c = 0;
	assign cfg_err_tlp_cpl_header_c = 0;
	assign cfg_di_c = 0;
	assign cfg_byte_en_n_c = 4'hf;
	assign cfg_wr_en_n_c = 1;
	assign cfg_rd_en_n_c = 1;
	// PCI Express Device Serial Number = { 40'h<Extension Id.>, 24'h<Company Id> }
	assign cfg_dsn_c[31:0] =  {{8'h1},24'h000A35};  // EUI-64 1st DW
	assign cfg_dsn_c[63:32] = 32'h00000001;  // EUI-64 2nd DW 
	
	
	assign SERR_Enable = cfg_command_c[8]; 
	assign Recived_MASTER_ABORT = cfg_status_c[13]; 
	assign Recived_TARGET_ABORT = cfg_status_c[12]; 
	assign signaled_TARGET_ABORT = cfg_status_c[11]; 
	assign Interrupt_status = cfg_status_c[3]; 

//used in DMA_mode - comment when used
wire                      trn_tsrc_rdy_n;
wire    [4:0]       		  trn_tbuf_av;
wire                      cfg_interrupt_n;
wire                      cfg_interrupt_rdy_n;
wire    						  cfg_interrupt_assert_n; //LEGACY only
wire 	  [7:0]      		  cfg_interrupt_di;
wire    [2:0]             cfg_interrupt_mmenable; //MSI only 
	
	//assign cfg_interrupt_n = 1'b1;
	assign cfg_interrupt_di = 8'b0; // single MSI inter. - not used
	assign cfg_interrupt_assert_n = 1'b1; // MSI inter. - not used 
	
	assign cfg_interrupt_n_out     = cfg_interrupt_n;
	assign cfg_interrupt_rdy_n_out = cfg_interrupt_rdy_n; 
	
	
pcie37    ep (
      .pci_exp_txp				(PCIe_TX_P),              // O [7/3/0:0]
      .pci_exp_txn				(PCIe_TX_N),              // O [7/3/0:0]
      .pci_exp_rxp				(PCIe_RX_P),              // O [7/3/0:0]
      .pci_exp_rxn				(PCIe_RX_N),              // O [7/3/0:0]
		
		.sys_clk						(PCIe_clock),             // I
      .sys_reset_n				(~PCIe_reset),             // I

      .trn_clk						(PCIe_trn_clk),             // O
      .trn_reset_n				(trn_reset_n_c),         // O
      .trn_lnk_up_n				(trn_lnk_up_n_c),        // O

      .trn_td						(trn_td_c),              // I [31:0]
      .trn_tsof_n					(trn_tsof_n_c),          // I
      .trn_teof_n					(trn_teof_n_c),          // I
      .trn_tsrc_rdy_n			(trn_tsrc_rdy_n ),      // I
      .trn_tsrc_dsc_n			(trn_tsrc_dsc_n_c ),      // I
      .trn_tdst_rdy_n			(trn_tdst_rdy_n_c ),      // O
      .trn_tdst_dsc_n			(trn_tdst_dsc_n_c ),      // O
      .trn_terrfwd_n				(trn_terrfwd_n_c ),       // I
      .trn_tbuf_av				(trn_tbuf_av ),         // O [4:0]

      .trn_rd						(trn_rd_c ),              // O [31:0]
      .trn_rsof_n					(trn_rsof_n_c ),          // O
      .trn_reof_n					(trn_reof_n_c ),          // O
      .trn_rsrc_rdy_n			(trn_rsrc_rdy_n_c ),      // O
      .trn_rsrc_dsc_n			(trn_rsrc_dsc_n_c ),      // O
      .trn_rdst_rdy_n			(trn_rdst_rdy_n_c ),      // I
      .trn_rerrfwd_n				(trn_rerrfwd_n_c ),       // O
      .trn_rnp_ok_n				(trn_rnp_ok_n_c ),        // I
      .trn_rbar_hit_n			(trn_rbar_hit_n_c ),      // O [6:0]
      .trn_rfc_nph_av			(trn_rfc_nph_av_c ),      // O [11:0]
      .trn_rfc_npd_av			(trn_rfc_npd_av_c ),      // O [7:0]
      .trn_rfc_ph_av				(trn_rfc_ph_av_c ),       // O [11:0]
      .trn_rfc_pd_av				(trn_rfc_pd_av_c ),       // O [7:0]
      .trn_rfc_cplh_av			(trn_rfc_cplh_av_c ),     // O [11:0]
      .trn_rfc_cpld_av			(trn_rfc_cpld_av_c ),     // O [7:0]

      .cfg_do						(cfg_do_c ),              // O [31:0]
      .cfg_di						(cfg_di_c ),              // I [31:0]
      .cfg_dwaddr					(cfg_dwaddr_c ),          // I [9:0]
      .cfg_byte_en_n				(cfg_byte_en_n_c ),       // I [3:0]
      .cfg_wr_en_n				(cfg_wr_en_n_c ),         // I
      .cfg_rd_en_n				(cfg_rd_en_n_c ),         // I
      .cfg_rd_wr_done_n			(cfg_rd_wr_done_n_c ),    // O
      .cfg_err_cor_n				(cfg_err_cor_n_c ),       // I
      .cfg_err_ur_n				(cfg_err_ur_n_c ),        // I
      .cfg_err_ecrc_n			(cfg_err_ecrc_n_c ),      // I
      .cfg_err_cpl_timeout_n  (cfg_err_cpl_timeout_n_c ), // I
      .cfg_err_cpl_abort_n    (cfg_err_cpl_abort_n_c ),   // I
      .cfg_err_cpl_unexpect_n (cfg_err_cpl_unexpect_n_c ),// I
      .cfg_err_posted_n       (cfg_err_posted_n_c ),      // I
      .cfg_err_tlp_cpl_header (cfg_err_tlp_cpl_header_c ),// I [47:0]
      .cfg_interrupt_n        (cfg_interrupt_n),       // I
      .cfg_interrupt_rdy_n    (cfg_interrupt_rdy_n),   // O
		.cfg_turnoff_ok_n       (cfg_turnoff_ok_n_c ),      // I
		.cfg_to_turnoff_n       (cfg_to_turnoff_n_c ),      // O
		.cfg_trn_pending_n      (cfg_trn_pending_n_c ),     // I
      .cfg_pm_wake_n          (cfg_pm_wake_n_c ),         // I
      .cfg_pcie_link_state_n  (cfg_pcie_link_state_n_c ), // O [2:0]
      .cfg_dsn                (cfg_dsn_c ),     			 // I [63:0]                          
      .cfg_bus_number         (cfg_bus_number_c ),        // O [7:0]
      .cfg_device_number      (cfg_device_number_c ),     // O [4:0]
      .cfg_function_number    (cfg_function_number_c ),   // O [2:0]
      .cfg_status             (cfg_status_c ),            // O [15:0]
      .cfg_command            (cfg_command_c ),           // O [15:0]
      .cfg_dstatus            (cfg_dstatus_c ),           // O [15:0]
      .cfg_dcommand           (cfg_dcommand_c ),          // O [15:0]
      .cfg_lstatus            (cfg_lstatus_c ),           // O [15:0]
      .cfg_lcommand           (cfg_lcommand_c ),          // O [15:0]

		.cfg_interrupt_assert_n (cfg_interrupt_assert_n),
		.cfg_interrupt_di			(cfg_interrupt_di),
		.cfg_interrupt_do			(cfg_interrupt_do),
      .cfg_interrupt_mmenable	(cfg_interrupt_mmenable),
      .cfg_interrupt_msienable(cfg_interrupt_msienable), 
		
		.fast_train_simulation_only (1'b0),
		.two_plm_auto_config        (2'b00));
	
//------------------------------------//

//------- HOST RESET DELAY ------------------------//
/*wire 				   HOST_RST; 
reg 				   HOST_RST_OUT; 
reg     [24:0]    data; 
reg               state; 


always @ (posedge PCIe_trn_clk  or negedge trn_reset_n_c) begin 
	if (!trn_reset_n_c) begin 
		HOST_RST_OUT <= 1'b0; 
		data         <= 25'h0; 
		state        <= 1'b0; 
	end else begin 

	case (state) 
	
	1'b0 : begin 
		if (HOST_RST) begin 
			HOST_RST_OUT <= 1'b1; 
			data         <= 25'h0; 
			state        <= 1'b1; 

		end else begin 
		   HOST_RST_OUT <= 1'b0; 
		   data         <= 25'h0; 
			state        <= 1'b0; 
		end 
	end 
	
	1'b1 : begin 	
		if (!data[24]) begin 
			HOST_RST_OUT <= 1'b1; 
			data         <= data + 1'b1;
		   state        <= 1'b1; 
		end else begin 
			HOST_RST_OUT <= 1'b0; 
			data         <= 25'h0;
			state        <= 1'b0; 
		end 
	end
endcase
end
end*/
//-------------------------------------------------//	

//----- RX-TX ENGINE 32b x1 lane ------------------//
//wire 				   HOST_RST; 
//assign  				PCIe_trn_rst = trn_reset_n_c & !trn_lnk_up_n_c & !HOST_RST; //activo a '0'

assign  				PCIe_trn_rst = trn_reset_n_c & !trn_lnk_up_n_c;// & !HOST_RST_OUT;   //activo a '0'

wire              compl_done;
wire  [2:0]       req_tc;
wire              req_td; 
wire              req_ep; 
wire  [1:0]       req_attr; 
wire  [9:0]       req_len;
wire  [15:0]      req_rid;
wire  [7:0]       req_tag;
wire  [7:0]       req_be;
wire  [6:0]       req_addr;   

wire 					wr_en;
wire  [31:0]      addr;
wire  [31:0]      wr_data;

wire  				req_compl; 
wire  [31:0]      rd_data; 
wire              comp_en; 

wire  [31:0]  		PCIe_DMA_addr;		//Host adress
wire         		PCIe_DMA_en; 		//start DMA 
wire  [5:0]   		DMA_SIZE;	      //DMA size		


TX_RX_rt TX_RX (

	.clk_pcie 					(PCIe_trn_clk),						//I
	.rst_n    					(PCIe_trn_rst),						//I	
	.RST              		(/*HOST_RST*/),        					//0
	
	.trn_rbar_hit_n 			(trn_rbar_hit_n_c[1:0]), 			//I

	.wr_en   					(wr_en),       						// I
	.addr 			   		(addr),     						   // O [31:0]
	.wr_data 					(wr_data),      						// O [31:0]

	.PCIe_wr_en  				(PCIe_wr_en),       //=wr_en      // O
	.PCIe_wr_addr  			(PCIe_wr_addr),     //=addr       // O [31:0]
	.PCIe_wr_data  			(PCIe_wr_data),     //=wr_data    // O [31:0]

	.BAR0_SEL         		(BAR0_SEL),								 // O [31:0]
	.BAR1_SEL         		(BAR1_SEL), 							 // 0
	
	.BAR1_ACT_REG     		(BAR1_ACT_REG), 						 // I [31:0]
	
	.req_compl					(req_compl),							//I
	.rd_data_o			   	(rd_data),   							//0
	.start_rd_req	   		(comp_en),	     						//0
	
	.PCIe_rd_addr				(PCIe_rd_addr),   					//O
	.PCIe_req_en      		(PCIe_req_en),							//O
	.PCIe_rd_en					(PCIe_rd_en),     					//I
	.PCIe_rd_data				(PCIe_rd_data),   					//I

	.addr_host_out			   (PCIe_DMA_addr), 	  					//O =host_addr
	.start_wr_req		      (PCIe_DMA_en),       				//O =start_wr_req                  
   .data_payload_out       (DMA_SIZE), 		 					//O

	.cfg_interrupt_n  		(cfg_interrupt_n),					//0
   .cfg_interrupt_rdy_n 	(cfg_interrupt_rdy_n),				//I 
	//.cfg_interrupt_assert_n (cfg_interrupt_assert_n),  		//0 not used for MSI 
	//.cfg_interrupt_di			(cfg_interrupt_di),					//0
	
	.trn_tsrc_rdy_n			(trn_tsrc_rdy_n),						//I	
	.trn_tbuf_av            (trn_tbuf_av),							//I
	.busy                   (busy),								   //0
	.DSP_clock(DSP_clock),
	.STRG(software_trigger),
	.SRST(software_reset),
	.MASTER(master_slave),
	.DMAE_sync(DMA_sync),
	.DMAE(DMA_enable),
	.RTM_present(RTM_present),
   .slot_id(slot_id),
	.DAC_1(DAC_1),
   .DAC_2(DAC_2),
   .DAC_3(DAC_3),
   .DAC_4(DAC_4),
	.DAC_5(DAC_5),
   .DAC_6(DAC_6),
   .DAC_7(DAC_7),
   .DAC_8(DAC_8),
	.ERFA_current(ERFA_current)
); 

// Local-Link Receive Controller
RX_ENGINE_32 EP_RX (

               .clk(PCIe_trn_clk),                   // I
               .rst_n(PCIe_trn_rst),                 // I

               .trn_rd(trn_rd_c),                     // I [63/31:0]
               .trn_rsof_n(trn_rsof_n_c),             // I
               .trn_reof_n(trn_reof_n_c),             // I
               .trn_rsrc_rdy_n(trn_rsrc_rdy_n_c),     // I
               .trn_rsrc_dsc_n(trn_rsrc_dsc_n_c),     // I
               .trn_rdst_rdy_n(trn_rdst_rdy_n_c),     // O
					
               // Handshake with Tx engine 
               .req_compl_o(req_compl),             // O
					
					.compl_done_i(compl_done),           // I
					.req_tc_o(req_tc),                   // O [2:0]
               .req_td_o(req_td),                   // O
               .req_ep_o(req_ep),                   // O
               .req_attr_o(req_attr),               // O [1:0]
               .req_len_o(req_len),                 // O [9:0]
               .req_rid_o(req_rid),                 // O [15:0]
               .req_tag_o(req_tag),                 // O [7:0]
               .req_be_o(req_be),                   // O [7:0]
               .req_addr_o(req_addr),               // O [31:0]
  
               // Memory Write Port
               .wr_en_o   (wr_en),       //=wr_en      // O
               .addr_o 	  (addr),     	  //=addr       // O [31:0]
               .wr_data_o (wr_data),     //=wr_data    // O [31:0]
					
					.wr_busy_i 	 (1'b0),	
					.wr_rd_len_o (PCIe_LEN)
					
 );
						 
wire  [15:0]  	   cfg_completer_id;
assign cfg_completer_id = {cfg_bus_number_c, cfg_device_number_c, cfg_function_number_c};
wire   cfg_bus_mstr_enable;
assign cfg_bus_mstr_enable = cfg_command_c[2];  						 
		
		
// Local-Link Transmit Controller 
EP_TX_DMA EP_TX (

                .clk    (PCIe_trn_clk),              // I
                .rst_n  (PCIe_trn_rst),              // I
                  
				    .trn_td(trn_td_c),                   // O [63/31:0]
                .trn_tsof_n(trn_tsof_n_c),           // O
                .trn_teof_n(trn_teof_n_c),           // O
                .trn_tsrc_dsc_n(trn_tsrc_dsc_n_c),   // O
                .trn_tsrc_rdy_n(trn_tsrc_rdy_n),     // O
                .trn_tdst_dsc_n(trn_tdst_dsc_n_c),   // I
                .trn_tdst_rdy_n(trn_tdst_rdy_n_c),   // I
                   
					 // Handshake with Rx engine 
                .compl_done_o(compl_done),         // 0
				    .req_tc_i(req_tc),                 // I [2:0]
                .req_td_i(req_td),                 // I
                .req_ep_i(req_ep),                 // I
                .req_attr_i(req_attr),             // I [1:0]
                .req_len_i(req_len),               // I [9:0]
                .req_rid_i(req_rid),               // I [15:0]
                .req_tag_i(req_tag),               // I [7:0]
                .req_be_i(req_be),                 // I [7:0]
                .req_addr_i(req_addr),             // I [31:0]   
	
					 .requester_id_i		  	(cfg_completer_id),    // I [15:0]
					 .cfg_bus_mstr_enable_i	(cfg_bus_mstr_enable), // I
			 
					 .data_i			(rd_data),   	//=rd_data       // I [31:0]
				    .start_compl	(comp_en),		//=start_rd_req  //
                
					 .addr_i			(PCIe_DMA_addr), 	  	//=wr_addr
					 .start_wr		(PCIe_DMA_en),       //=start_wr_req                  
					 .data_payload (DMA_SIZE) 		 
);
	
	   
PIO_TO_CTRL PIO_TO  (
                   .clk   			    (PCIe_trn_clk),          // I
                   .rst_n 			    (PCIe_trn_rst),          // I
                   .req_compl_i	    (req_compl),             // I
                   .compl_done_i     (compl_done),            // I
                   .cfg_to_turnoff_n (cfg_to_turnoff_n_c),    // I
                   .cfg_turnoff_ok_n (cfg_turnoff_ok_n_c)     // O    
);


//pedido de leitura - outputs do modulo PCIe_endpoint 
	//.PCIe_wr_en(PCIe_rd_en),
	//.PCIe_rd_addr(PCIe_rd_addr),  

//realização (completion) do pedido de leitura ou envio de DMA - inputs no modulo PCIe_endpoint 
	//.PCIe_DMA_en (PCIe_DMA_en),    //enable do envio DMA        
	//.PCIe_comp_en (PCIe_comp_en),  //completion enable 
	//.PCIe_rd_data(PCIe_rd_data),   //linha de dados comum aos dois tipos de envio


//sinais utilizados para envio de legacy interrupts 
	//.PCIe_interrupt_on      (PCI_interrupt_on),         //pedido de interrupção ao core - input no modulo PCIe_endpoint
	//.PCIe_interrupt_ready   (PCIe_interrupt_ready),     //core indica que pedido de interrupção foi aceite - output modulo PCIe_endpoint                                     
	//.PCIe_interrupt_assert  (cfg_interrupt_assert_n),   //assert/deassert da legacy interrupt - input no modulo PCIe_endpoint
	//.PCIe_interrupt_di      (cfg_interrupt_di),			 //define qual o tipo de legacy interrupt que tamos a enviar (INTA,INTB,INTC ou INTD)

//registos do BAR 1
	//.BAR1_reg_sel ??

//sinais actualmente utilizados que posso não utilizar se o BAR1 for descodificado dentro do modulo PCIe_endpoint
	//.PCIe_DMA_addr(PCIe_DMA_addr), // endereço do host para onde envio o DMA actual
	//.DMA_size(DMA_size), // tamanho do DMA 

//outros sinais que preciso que saiam do modulo 
	//.PCIe_buffers_av(PCIe_buffers_av),  //indica se o PCIe tem buffers disponiveis para enviar pacotes, caso contrario o utilizador tem de esperar - output do modulo PCIe_endpoint.
	//.PCIe_busy (PCIe_busy) ???          //PCIe ocupado a enviar um pacote - acho que não preciso deste, mas tenho de ver melhor 


endmodule
