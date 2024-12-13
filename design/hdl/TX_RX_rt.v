`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    
// Design Name: 
// Module Name:    TX_RX_rt 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module TX_RX_rt (

input						clk_pcie,
input						rst_n, 
output reg           RST,
	
input 		[1:0]		trn_rbar_hit_n, 
		
input    				wr_en, 
input       [31:0]   addr,
input			[31:0]   wr_data,

output reg  			PCIe_wr_en,
output reg  [31:0]   PCIe_wr_addr, 
output reg 	[31:0]	PCIe_wr_data,         

output reg 	[31:0]   BAR1_SEL, 
output reg           BAR0_SEL, 
input       [31:0]   BAR1_ACT_REG,

input                req_compl, 
output reg  [31:0]   rd_data_o,			  
output reg				start_rd_req, 		

output      [31:0]   PCIe_rd_addr,		
output               PCIe_req_en, 
input      			   PCIe_rd_en,			
input       [31:0]   PCIe_rd_data,		
    
output  reg [31:0]	addr_host_out, 
output  reg          start_wr_req, 
output  reg [5:0]    data_payload_out,  //DMA BYTE SIZE

output    				cfg_interrupt_n,
input					   cfg_interrupt_rdy_n, 

input 				 	trn_tsrc_rdy_n,
input    	[4:0]    trn_tbuf_av, 

output               busy,
input DSP_clock,
output reg STRG,
output reg SRST,
input MASTER,
output reg DMAE_sync,
input DMAE,
input RTM_present,
input [3:0] slot_id,
output reg [15:0] DAC_1,
output reg [15:0] DAC_2,
output reg [15:0] DAC_3,
output reg [15:0] DAC_4,
output reg [15:0] DAC_5,
output reg [15:0] DAC_6,
output reg [15:0] DAC_7,
output reg [15:0] DAC_8,
output reg [3:0] ERFA_current

);

   assign cfg_interrupt_n = 1'b1;
	assign PCIe_req_en		= 1'b0;	
	assign PCIe_rd_addr     = 32'b0; 

//#################################################################################//


//write request
always @ (posedge clk_pcie or negedge rst_n) begin 	
	if (!rst_n) begin 
			PCIe_wr_en		<= 1'b0; 
			PCIe_wr_data   <= 32'b0; 
			PCIe_wr_addr	<= 32'b0; 		
	 end else begin 	
			if (wr_en) begin // WR BAR0/BAR1	
					PCIe_wr_en		<= 1'b1; 
					PCIe_wr_data   <= wr_data; 
					PCIe_wr_addr	<= addr; 
			end else begin 
					PCIe_wr_en		<= 1'b0; 
					PCIe_wr_data   <= 32'b0; 
					PCIe_wr_addr	<= 32'b0; 			
			end 
	 end 
end 
	
//BAR_0 or BAR_1 selected
reg bar_0; 
reg bar_1; 
always @ (posedge clk_pcie or negedge rst_n) begin 	
	if (!rst_n) begin 
		bar_0 <= 1'b0; 
		bar_1 <= 1'b0; 
	end else begin 
		if (trn_rbar_hit_n == 2'b10) begin 
			bar_0 <= 1'b1; 
		   bar_1 <= 1'b0; 
	   end else if (trn_rbar_hit_n == 2'b01) begin 
			bar_0 <= 1'b0; 
		   bar_1 <= 1'b1; 
		end else begin 
		end 
	end 
end 


// REGISTERS SELECT
always @ (posedge clk_pcie or negedge rst_n) begin 	
	if (!rst_n) begin 
			BAR0_SEL 		<= 1'h0; 
			BAR1_SEL 		<= 32'b0;

	end else begin 	
		
		if (bar_0) begin // WR/RD BAR0	
			
					BAR0_SEL 		<= 1'h1; 
					BAR1_SEL 		<= 32'b0; 

		end else if (bar_1) begin //WR BAR1	
					
					BAR0_SEL 		<= 1'h0; 
								
					case  (addr[6:0]) //32 REGISTERS SELECT
				
					7'h0: begin  // REVISION_ID + STATUS
								BAR1_SEL[0]  	 <= 1'h1; 
								BAR1_SEL[31:1]  <= 31'h0; 
							end 				
					7'h4: begin  //COMMAND
								BAR1_SEL[1]  	<= 1'h1; 
								BAR1_SEL[31:2] <= 30'h0; 
								BAR1_SEL[0] 	<= 1'h0; 
							end 		
					7'h8: begin  //ERFA current - OLD AQ. FREQUENCY
								BAR1_SEL[2]  	<= 1'h1; 
								BAR1_SEL[31:3] <= 29'h0; 
								BAR1_SEL[1:0] 	<= 2'h0; 
							end 
					7'hC: begin  //DMA BYTE SIZE + DMA BUFFER NUMBER
								BAR1_SEL[3]  	<= 1'h1; 
								BAR1_SEL[31:4] <= 28'h0; 
								BAR1_SEL[2:0] 	<= 3'h0; 			
							end 
					7'h10: begin  //DMA CURRENT BUFFER
								BAR1_SEL[4]  	<= 1'h1; 
								BAR1_SEL[31:5] <= 27'h0; 
								BAR1_SEL[3:0] 	<= 4'h0; 
							end 		
					7'h14: begin  //RESERVED - INT COUNT
								BAR1_SEL[5]  	<= 1'h1; 
								BAR1_SEL[31:6] <= 26'h0; 
								BAR1_SEL[4:0] 	<= 5'h0; 
							end 				
					7'h18: begin  //RESERVED
								BAR1_SEL[6]  	<= 1'h1; 
								BAR1_SEL[31:7] <= 25'h0; 
								BAR1_SEL[5:0] 	<= 6'h0; 
							end 		
					7'h1C: begin  //RESERVED 
								BAR1_SEL[7]  	<= 1'h1; 
								BAR1_SEL[31:8] <= 24'h0; 
								BAR1_SEL[6:0] 	<= 7'h0; 
							end 
					7'h20: begin  //DMA ADRESSES
								BAR1_SEL[8]  	<= 1'h1; 
								BAR1_SEL[31:9] <= 23'h0; 
								BAR1_SEL[7:0] 	<= 8'h0; 
							end 				
					7'h24: begin  //DMA ADRESSES
								BAR1_SEL[9]  	<= 1'h1; 
								BAR1_SEL[31:10] <= 22'h0; 
								BAR1_SEL[8:0] 	<= 9'h0; 
							end 
					7'h28: begin  //DMA ADRESSES
								BAR1_SEL[10]  	<= 1'h1; 
								BAR1_SEL[31:11] <= 21'h0; 
								BAR1_SEL[9:0] 	<= 10'h0; 
							end 
					7'h2c: begin  //DMA ADRESSES
								BAR1_SEL[11]  	<= 1'h1; 
								BAR1_SEL[31:12] <= 20'h0; 
								BAR1_SEL[10:0] 	<= 11'h0; 
							end 	
					7'h30: begin  //DMA ADRESSES
								BAR1_SEL[12]  	<= 1'h1; 
								BAR1_SEL[31:13] <= 19'h0; 
								BAR1_SEL[11:0] 	<= 12'h0; 
							end 
					7'h34: begin  //DMA ADRESSES
								BAR1_SEL[13]  	<= 1'h1; 
								BAR1_SEL[31:14] <= 18'h0; 
								BAR1_SEL[12:0] 	<= 13'h0; 
							end 
					7'h38: begin  //DMA ADRESSES
								BAR1_SEL[14]  	<= 1'h1; 
								BAR1_SEL[31:15] <= 17'h0; 
								BAR1_SEL[13:0] 	<= 14'h0; 
							end 					
					7'h3c: begin  //DMA ADRESSES
								BAR1_SEL[15]  	<= 1'h1; 
								BAR1_SEL[31:16] <= 16'h0; 
								BAR1_SEL[14:0] 	<= 15'h0; 
							end 
					7'h40: begin  //DMA ADRESSES
								BAR1_SEL[16]  	<= 1'h1; 
								BAR1_SEL[31:17] <= 15'h0; 
								BAR1_SEL[15:0] 	<= 16'h0; 
							end 
					7'h44: begin  //DMA ADRESSES
								BAR1_SEL[17]  	<= 1'h1; 
								BAR1_SEL[31:18] <= 14'h0; 
								BAR1_SEL[16:0] 	<= 17'h0; 
							end 					
					7'h48: begin  //DMA ADRESSES
								BAR1_SEL[18]  	<= 1'h1; 
								BAR1_SEL[31:19] <= 13'h0; 
								BAR1_SEL[17:0] 	<= 18'h0; 
							end 
					7'h4c: begin  //DMA ADRESSES
								BAR1_SEL[19]  	<= 1'h1; 
								BAR1_SEL[31:20] <= 12'h0; 
								BAR1_SEL[18:0] 	<= 19'h0; 
							end 
					7'h50: begin  //DMA ADRESSES
								BAR1_SEL[20]  	<= 1'h1; 
								BAR1_SEL[31:21] <= 11'h0; 
								BAR1_SEL[19:0] 	<= 20'h0; 
							end 
					7'h54: begin  //DMA ADRESSES
								BAR1_SEL[21]  	<= 1'h1; 
								BAR1_SEL[31:22] <= 10'h0; 
								BAR1_SEL[20:0] 	<= 21'h0; 
							end 		
					7'h58: begin  //DMA ADRESSES
								BAR1_SEL[22]  	<= 1'h1; 
								BAR1_SEL[31:23] <= 9'h0; 
								BAR1_SEL[21:0] 	<= 22'h0; 
							end 	
					7'h5c: begin  //DMA ADRESSES
								BAR1_SEL[23]  	<= 1'h1; 
								BAR1_SEL[31:24] <= 8'h0; 
								BAR1_SEL[22:0] 	<= 23'h0; 
							end 	
							
					7'h60: begin  //DAC1 - OLD N BYTES REQ. BY HOST
								BAR1_SEL[24]  	<= 1'h1; 
								BAR1_SEL[31:25] <= 7'h0; 
								BAR1_SEL[23:0] 	<= 24'h0; 
							end 	
							
					7'h64: begin  //DAC2 - OLD MEM_INIT_ADDR
								BAR1_SEL[25]  	<= 1'h1; 
								BAR1_SEL[31:26] <= 6'h0; 
								BAR1_SEL[24:0] 	<= 25'h0; 
							end 
					
					7'h68: begin  //DAC3 - OLD DATA_PROCESSING
								BAR1_SEL[26]  	<= 1'h1; 
								BAR1_SEL[31:27] <= 5'h0; 
								BAR1_SEL[25:0] 	<= 26'h0; 
							end 
					
					7'h6c: begin  //DAC4 - OLD GENERIC
								BAR1_SEL[27]  	 <= 1'h1; 
								BAR1_SEL[31:28] <=4'h0; 
								BAR1_SEL[26:0]  <= 27'h0; 
							end 
							
					7'h70: begin  //DAC5 - OLD ACQ_BYTE_SIZE
								BAR1_SEL[28]  	 <= 1'h1; 
								BAR1_SEL[31:29] <= 3'h0; 
								BAR1_SEL[27:0]  <= 28'h0; 
							end 
							
					7'h74: begin  //DAC6
								BAR1_SEL[29]  	 <= 1'h1; 
								BAR1_SEL[31:30] <= 2'h0; 
								BAR1_SEL[28:0]  <= 29'h0; 
							end 	
							
					7'h78: begin  //DAC7
								BAR1_SEL[30]  	 <= 1'h1; 
								BAR1_SEL[31] <= 1'h0; 
								BAR1_SEL[29:0]  <= 30'h0; 
							end 
							
					7'h7c: begin  //DAC8
								BAR1_SEL[31]  	 <= 1'h1;  
								BAR1_SEL[30:0]  <= 31'h0; 
							end 
							
					//..... to continue até BAR1_SEL[32] 
				
					default: begin
						//do nothing
					end 
				endcase

			end else begin 
			end 
	end
end 
				

//######### STANDARD REGISTERS #############################################// 
//STATUS REG.
//reg 		   ACQC; 
//reg 		   DMAC;  // - clear da interrupt
wire        FIFF;
wire 		   FIFE;
wire        ERR0;
wire 		   ERR1;
//reg 		   RST;   //HOST RESET
wire 		   FSH;
//VS - wire [7:0]  channels; NOT USED

//assign ACQC 	 = 1'b0; 	//send interrupt after acquisition 
assign FIFF 	 = 1'b0;  	//fifo not full
assign FIFE	 	 = 1'b0;  	//fifo not empty
assign ERR0		 = 1'b0; 	//no error0
assign ERR1 	 = 1'b0; 	//no error1 
assign FSH 		 = 1'b0; 	//no flush data on reset??
//assign channels = 8'h4; 	//number of ADCS modules

//REVISION ID REG
wire 		  	DBG;
wire 		  	HDR;
wire        TMR;
wire [3:0]  REV_ID; 

assign DBG		 = 1'b0; // no debbug pins
assign HDR		 = 1'h1; // RTDN 
assign TMR		 = 1'h1; // Timming information
assign REV_ID   = 4'h2; // firmware version final 2

//COMMAND REG 
//VS - reg [5:0]  acquisition_bits;  // adcs resolution  - 6'h12
//VS - reg [7:0]  channels_number;   // number of adcs => to be less or = to channels - 8h'20;

reg        DMAC; 
reg        ACQC; 

wire       ACQM; 					// NEW - aquisition mode-memory '0'/ real time '1'
reg [1:0]  DQTP;              // NEW - Data aquisition type-raw'00'/adcs proc. data'01'/PCIe proc data'11'
reg  		  LOAD; 					// NEW - load for download; - 1'h0 
reg [1:0]  CHN; 					// NEW - number of selected channels 
wire [1:0]  ILVM; 					// NEW - interlived 2ch '01'/4ch '11'/single '00'

reg        HOP; 					// generate RTDN packet - 1'h0
reg        TOP; 					// generate timming packet - 1'h0
reg        ACQS; 					// clock source - internall or externall - 1'h1
reg        ACQT; 					// one shot / continuous acquisition - 1'h0 
reg        ACQK;    				// clock edge trigger - 1'h1
reg        ACQE;        	   // en_counter - enable board - 1'h1

//reg        STRG;					// NEW - startup trigger- enable aquisition - 1'h1; 
reg        DMAF; 					// enable fast acknowledge mode  1'h0
//reg        DMAE;   			   // start_DMA - enable dma - dma address must be defined - 1'h1 
reg        ERRiE;  				// error interrupt enable 1'h0
reg        DMAiE;  				// interrup_on  - assert interrupt after DMA - 1'h1
reg        ACQiE;					// assert interrupt after acquisition - 1'h0

assign ACQM = 1'b0; 
//assign CHN  = 2'b0; 
assign ILVM = 2'b0; 

//ACQ. FREQUENCY REG.  
//reg [31:0] acquisition_freq;	// freq of the internal clock	

//DMA BYTE SIZE REG. 
reg [13:0] data_payload; 		// DMA Byte Size - data_payload in DW 

// DMA BUFFERS NUMBER REG. 
reg [15:0] DMA_Buffer_number; // Size of the DMA adresses array = 16'h3 

//DMA CURRENT BUFFER REG.		
reg [31:0]  DMA_current_buffer;// index of currently used adress buffer

//DMA ADRESSES ARRAY 
reg [31:0] DMA_address_0; //define after reset 
reg [31:0] DMA_address_1; //define after reset 
reg [31:0] DMA_address_2; //define after reset 
reg [31:0] DMA_address_3; //define after reset 
reg [31:0] DMA_address_4; //define after reset 
reg [31:0] DMA_address_5; //define after reset 
reg [31:0] DMA_address_6; //define after reset 
reg [31:0] DMA_address_7; //define after reset 
reg [31:0] DMA_address_8; //define after reset 
reg [31:0] DMA_address_9; //define after reset 
reg [31:0] DMA_address_10; //define after reset 
reg [31:0] DMA_address_11; //define after reset 
reg [31:0] DMA_address_12; //define after reset 
reg [31:0] DMA_address_13; //define after reset 
reg [31:0] DMA_address_14; //define after reset 
reg [31:0] DMA_address_15; //define after reset 

reg [31:0]  N_BYTES; 
reg [31:0]  MEM_ADDR; 
//reg [31:0]  DATA_PROCESS; 
//reg [31:0]  GENERIC; 
//reg [31:0]  ACQ_BYTE_SIZE;

reg DMAE_r; 
reg DMAE_r1; 
reg DMAE_r2; 
reg DMAE_r3; 

always @ (posedge clk_pcie or negedge rst_n) begin 	
	if (!rst_n) begin 
		DMAE_r		   		 <= 1'b0;	 // DMAE - host must enable dma                   - USED
		DMAE_r1		   		 <= 1'b0;	 // DMAE - host must enable dma                   - USED
		DMAE_r2		   		 <= 1'b0;	 // DMAE - host must enable dma                   - USED
		DMAE_r3		   		 <= 1'b0;	 // DMAE - host must enable dma                   - USED
	end else begin 
		DMAE_r		   		 <= DMAE;	 // DMAE - host must enable dma                   - USED
		DMAE_r1		   		 <= DMAE_r;	 // DMAE - host must enable dma                   - USED
		DMAE_r2		   		 <= DMAE_r1;	 // DMAE - host must enable dma                   - USED
		DMAE_r3		   		 <= DMAE_r2;	 // DMAE - host must enable dma                   - USED
	end 
end 
 

//################## WRITE REQUESTS #############################################//
//reg     		clear_DMAC; 
//reg     	   clear_ACQC; 
reg     		host_reset; 
reg     		start_DMA_ready;


always @ (posedge clk_pcie or negedge rst_n) begin 	
	if (!rst_n) begin 
			//REGISTERS DEFAULTS - BAR1
			SRST <= 0;  
			//clear_ACQC  		 <= 1'b1;    // indirect write to clear aq. complete
			//clear_DMAC	       <= 1'b1;  	 // indirect write to DMAC 
			host_reset         <= 1'b0;  	 // indirect write to RST
			
			//VS - acquisition_bits	 <= 6'hD;    // adcs resolution 
	
			//ACQM  				<= 1'b0; assigned for this project
			DQTP  				<= 2'b0;  
			LOAD  				<= 1'b0;  				
	
			//VS - channels_number	    <= 8'h1;    // number of used adcs 
			
			CHN					 <= 2'b0; 		    
         //ILVM				  <= 2'b0; //assigned for this project	
	
			HOP 					 <= 1'b0;    // generate RTDN packet 
			TOP 					 <= 1'b0;    // generate timming packet 
			ACQS 				    <= 1'b1;	 // clock source - external
			ACQT 				    <= 1'b0;	 // 1 shot / continuous acquisition                  - USED
			ACQK    		   	 <= 1'b1;	 // clock positive edge trigger 
			ACQE 	   	 		 <= 1'b0;	 // host must start aquisition  - assign           - USED
			STRG               <= 1'b0;    // startup TRIGGER
			DMAF   				 <= 1'b0;	 // not enable fast acknowledge mode
			DMAE_sync		   		 <= 1'b0;	 // DMAE - host must enable dma                   - USED
			ERRiE  				 <= 1'b0;    // not enable error interrupt
			DMAiE        		 <= 1'b0;    // DMAiE - host must assert interrupt after DMA     - USED
			ACQiE			   	 <= 1'b0;    // not assert interrupt after acquisition
			
			//acquisition_freq	 <= 32'h0; // freq of the internal clock	
			
			data_payload		 <= 14'h0; // DMA Byte Size - data_payload in DW              
			DMA_Buffer_number  <= 16'h1; // Size of the DMA adresses array = 16'h1	
         
			//DMA_current_buffer <= 31'h0; // index of currently used adress buffer
					
			DMA_address_0      <= 32'h0; //define after reset 
         DMA_address_1		 <= 32'h0; //define after reset 
			DMA_address_2      <= 32'h0; //define after reset 
         DMA_address_3		 <= 32'h0; //define after reset 
			DMA_address_4      <= 32'h0; //define after reset 
         DMA_address_5		 <= 32'h0; //define after reset 
			DMA_address_6      <= 32'h0; //define after reset 
         DMA_address_7		 <= 32'h0; //define after reset 
         DMA_address_8		 <= 32'h0; //define after reset 
			DMA_address_9      <= 32'h0; //define after reset 
         DMA_address_10		 <= 32'h0; //define after reset 
			DMA_address_11     <= 32'h0; //define after reset 
         DMA_address_12		 <= 32'h0; //define after reset 
         DMA_address_13		 <= 32'h0; //define after reset 
			DMA_address_14     <= 32'h0; //define after reset 
         DMA_address_15		 <= 32'h0; //define after reset 

			N_BYTES       		 <= 32'h0; //Number of bytes requested by host      
			MEM_ADDR 			 <= 32'h0; //Initial mem addr
			//DATA_PROCESS		 <= 32'h0;
			//GENERIC				 <= 32'h0;
			//ACQ_BYTE_SIZE      <= 32'h3FFFFC0;
			DAC_1				 <= 16'h7FFF;
         DAC_2				 <= 16'h7FFF;
         DAC_3				 <= 16'h7FFF;
         DAC_4				 <= 16'h7FFF;
			DAC_5				 <= 16'h7FFF;
         DAC_6				 <= 16'h7FFF;
         DAC_7				 <= 16'h7FFF;
         DAC_8				 <= 16'h7FFF;
			ERFA_current    <= 4'h0;
			
			start_DMA_ready  	 <= 1'b0;  // host address defined
			
			
					
	end else begin
		
		if (PCIe_wr_en) begin  // WRITE BAR1 - BAR0 only DMA mode 
		
			if (BAR1_SEL[0]) begin // RD only - do nothing
			
					//if (PCIe_wr_data[30] == 1'b1 ) begin  //DMAC - host acknowledge DMA interrupt  
					//	clear_DMAC  <= 1'b0; 
					//end 
					
					if (PCIe_wr_data[19] == 1'b1 ) begin  //RST - host quer resetar a BOARD
						host_reset  <= 1'b1; 
					end 
					
					//if (PCIe_wr_data[31] == 1'b1 ) begin  //ACQC - host acknowledge aquisition complete interrupt 
					//	clear_ACQC  <= 1'b0; 
					//end 
					
			
			end else if (BAR1_SEL[1]) begin 		 	// afecta imediatamente 
			         SRST <= PCIe_wr_data[0];  
						//VS acquisition_bits <= PCIe_wr_data[7:2];  	
						//ACQM  				<= PCIe_wr_data[3]; assigned for this project
						DQTP  				<= PCIe_wr_data[5:4];  
						LOAD  				<= PCIe_wr_data[6];  				
					
						//channels_number  <= PCIe_wr_data[15:8];				
						CHN					 <= PCIe_wr_data[9:8]; 				    
						//ILVM			    <= PCIe_wr_data[11:10]; //assigned for this project	
 	
					   HOP              <= PCIe_wr_data[18];
					   TOP              <= PCIe_wr_data[19];
						ACQS             <= PCIe_wr_data[20];  	
						ACQT             <= PCIe_wr_data[21];    //one shot aq. 
						ACQK             <= PCIe_wr_data[22];  	
						ACQE             <= PCIe_wr_data[23];  // en_aq - só serve para a leitura do reg
						STRG             <= PCIe_wr_data[24];  // startup TRIGGER
						DMAF             <= PCIe_wr_data[26]; 
						DMAE_sync        	  <= PCIe_wr_data[27];    //start_DMA
						ERRiE            <= PCIe_wr_data[29];  
						DMAiE            <= PCIe_wr_data[30];    //interrup_on
						ACQiE     		  <= PCIe_wr_data[31]; 
						
			end else if (BAR1_SEL[2]) begin  		
				    //acquisition_freq  <= PCIe_wr_data[31:0];		
			       ERFA_current  <= PCIe_wr_data[3:0];
			
			end else if (BAR1_SEL[3]) begin  		
					 data_payload      <= PCIe_wr_data[15:2]; //DW - trunca a 128B = 32DW ?? neste caso 8'hFC-63DW (e não 8'h80-32DW)
					 DMA_Buffer_number <= {PCIe_wr_data[31:16]}; //trunca a 16 endereços ?? - neste caso 5'h1F-31 (e não 5'h10-16)	
					 start_DMA_ready   <= 1'b1; 					 
			
			end else if (BAR1_SEL[4]) begin 
				//	 DMA_current_buffer <= PCIe_wr_data[31:0]; - CHANGED ONLY BY FIRMWARE IN THIS APP

			end else if (BAR1_SEL[5]) begin  		
					// do nothing - reserved - count int. 	
			
			end else if (BAR1_SEL[6]) begin  		
					N_BYTES 			<= PCIe_wr_data[31:0];  //  NEW	
			
			end else if (BAR1_SEL[7]) begin  	
					MEM_ADDR 		<= PCIe_wr_data[31:0];  //  NEW	
			
			end else if (BAR1_SEL[8]) begin  	
					DMA_address_0 <= PCIe_wr_data[31:0];
			end else if (BAR1_SEL[9]) begin  	
					DMA_address_1 <= PCIe_wr_data[31:0];
			end else if (BAR1_SEL[10]) begin  	
					DMA_address_2 <= PCIe_wr_data[31:0];
			end else if (BAR1_SEL[11]) begin  	
					DMA_address_3 <= PCIe_wr_data[31:0];
			end else if (BAR1_SEL[12]) begin  	
					DMA_address_4 <= PCIe_wr_data[31:0];		
			end else if (BAR1_SEL[13]) begin  	
					DMA_address_5 <= PCIe_wr_data[31:0];
			end else if (BAR1_SEL[14]) begin  	
					DMA_address_6 <= PCIe_wr_data[31:0];
			end else if (BAR1_SEL[15]) begin  	
					DMA_address_7 <= PCIe_wr_data[31:0];
			end else if (BAR1_SEL[16]) begin  	
					DMA_address_8 <= PCIe_wr_data[31:0];
			end else if (BAR1_SEL[17]) begin  	
					DMA_address_9 <= PCIe_wr_data[31:0];
			end else if (BAR1_SEL[18]) begin  	
					DMA_address_10 <= PCIe_wr_data[31:0];
			end else if (BAR1_SEL[19]) begin  	
					DMA_address_11 <= PCIe_wr_data[31:0];
			end else if (BAR1_SEL[20]) begin  	
					DMA_address_12 <= PCIe_wr_data[31:0];
			end else if (BAR1_SEL[21]) begin  	
					DMA_address_13 <= PCIe_wr_data[31:0];
			end else if (BAR1_SEL[22]) begin  	
					DMA_address_14 <= PCIe_wr_data[31:0];
			end else if (BAR1_SEL[23]) begin  	
					DMA_address_15 <= PCIe_wr_data[31:0];
			
			end else if (BAR1_SEL[24]) begin  	
					DAC_1 <= PCIe_wr_data[15:0];			

		   end else if (BAR1_SEL[25]) begin  	
					DAC_2 <= PCIe_wr_data[15:0];

			end else if (BAR1_SEL[26]) begin  	
					//DATA_PROCESS   <= PCIe_wr_data[31:0];  //  NEW
			      DAC_3 <= PCIe_wr_data[15:0];
			
			end else if (BAR1_SEL[27]) begin  	
					//GENERIC        <= PCIe_wr_data[31:0];  //  NEW
					DAC_4 <= PCIe_wr_data[15:0];
					
			end else if (BAR1_SEL[28]) begin  	
					//ACQ_BYTE_SIZE  <= PCIe_wr_data[31:0];  //  NEW
					DAC_5 <= PCIe_wr_data[15:0];
					
			end else if (BAR1_SEL[29]) begin //NEW
               DAC_6 <= PCIe_wr_data[15:0];
			
         end else if (BAR1_SEL[30]) begin //NEW	
			      DAC_7 <= PCIe_wr_data[15:0];
				  
			end else if (BAR1_SEL[31]) begin  	
               DAC_8 <= PCIe_wr_data[15:0];   //  NEW
			
			end else begin
			end	
		
		end else begin 			
			//if (!DMAC) begin 
			//	clear_DMAC  <= 1'b1; 
			//end
			
			//if (!ACQC) begin 
			//	clear_ACQC  <= 1'b1; 
			//end
			
		end 
	end
end	


//#############################################################################//

//###################### DEFINE CURRENT HOST ADDRESS  #########################//    
reg [31:0]	addr_host; 

always @ (posedge clk_pcie or negedge rst_n) begin 	
	if (!rst_n) begin
		addr_host <= 32'b0; 
	end else begin 
		if (DMA_current_buffer == 4'h0) begin 
					addr_host <= DMA_address_0; 
		end else if (DMA_current_buffer == 4'h1) begin 
					addr_host <= DMA_address_1; 
		end else if (DMA_current_buffer == 4'h2) begin 
					addr_host <= DMA_address_2; 
	   end else if (DMA_current_buffer == 4'h3) begin 
					addr_host <= DMA_address_3; 
	   end else if (DMA_current_buffer == 4'h4) begin 
					addr_host <= DMA_address_4; 	
		end else if (DMA_current_buffer == 4'h5) begin 
					addr_host <= DMA_address_5; 
		end else if (DMA_current_buffer == 4'h6) begin 
					addr_host <= DMA_address_6; 
		end else if (DMA_current_buffer == 4'h7) begin 
					addr_host <= DMA_address_7; 
	   end else if (DMA_current_buffer == 4'h8) begin 
					addr_host <= DMA_address_8; 
	   end else if (DMA_current_buffer == 4'h9) begin 
					addr_host <= DMA_address_9; 	
		end else if (DMA_current_buffer == 4'hA) begin 
					addr_host <= DMA_address_10; 			
		end else if (DMA_current_buffer == 4'hB) begin 
					addr_host <= DMA_address_11; 			
		end else if (DMA_current_buffer == 4'hC) begin 
					addr_host <= DMA_address_12; 			
		end else if (DMA_current_buffer == 4'hD) begin 
					addr_host <= DMA_address_13; 			
	   end else if (DMA_current_buffer == 4'hE) begin 
					addr_host <= DMA_address_14; 			
		end else if (DMA_current_buffer == 4'hF) begin 
					addr_host <= DMA_address_15; 
		end else begin
					addr_host <= DMA_address_0; //if DMA_current_buffer > 15 => current addr = DMA_address_0
		end
	end 
end
//#############################################################################//

//######################## HOST RESET ###################################################//

always @ (posedge clk_pcie) begin 
   if (host_reset) begin 
		RST <= 1'b1; 
	end else begin 
		RST <= 1'b0;
	end 
end 


//####################### RD REQUESTS / DMA MODE #########################################//						
wire  [15:0]   	test_data; 	//debug


wire  [31:0] rd_data;  
reg   [31:0] rd_data_r; 
reg   [31:0] count_int; 
reg          rd_en; 
reg 		    rd_en_r;     	  

always @ (posedge clk_pcie or negedge rst_n) begin 
	if (!rst_n) begin    	
		rd_data_r		<= 32'b0;
	end else begin 		
		
		if (start_rd_req) begin  //READ REQ BAR1 - BAR0 only DMA mode 		
			
			if (BAR1_SEL[0]) begin // STATUS + REVISION ID 
					rd_data_r <= {ACQC,DMAC,2'b0,FIFF,FIFE,2'b0,ERR0,ERR1,2'b0,RST,FSH,2'b0,/*VS -channels*/2'b0,slot_id,RTM_present,MASTER, 
									  1'b0,DBG,HDR,TMR,REV_ID};  
			end else if (BAR1_SEL[1]) begin 	//COMMAND 
			       rd_data_r <= {ACQiE, DMAiE, ERRiE, 1'b0, 
										DMAE_sync,
										DMAF, 1'b0,
										STRG,
										ACQE, 
										ACQK, ACQT, ACQS, TOP, HOP, 2'b0,
										4'b0, ILVM, CHN /*channels_number*/, 
										1'b0, LOAD, DQTP, ACQM, 1'b0/*acquisition_bits*/, 
										1'b0,SRST}; 
			end else if (BAR1_SEL[2]) begin  		
					 //rd_data_r 	 <= acquisition_freq; 
					 rd_data_r 	 <= {28'h0000000, ERFA_current[3:0]};
			end else if (BAR1_SEL[3]) begin  		
					 rd_data_r 	 <= {DMA_Buffer_number, data_payload,2'h0};   
			end else if (BAR1_SEL[4]) begin 
					 rd_data_r 	 	<= DMA_current_buffer;
			end else if (BAR1_SEL[5]) begin  		
					rd_data_r   <= count_int; // contagem das interr.
			end else if (BAR1_SEL[6]) begin  		
					rd_data_r   <=  N_BYTES;   //  NEW			   
			end else if (BAR1_SEL[7]) begin  	
					rd_data_r   <=  MEM_ADDR; //  NEW	
			end else if (BAR1_SEL[8]) begin  	
					rd_data_r   <= DMA_address_0; 
			end else if (BAR1_SEL[9]) begin  	
					rd_data_r   <= DMA_address_1; 
			end else if (BAR1_SEL[10]) begin  	
					rd_data_r   <= DMA_address_2; 
			end else if (BAR1_SEL[11]) begin  	
					rd_data_r   <= DMA_address_3; 
			end else if (BAR1_SEL[12]) begin  	
					rd_data_r   <= DMA_address_4; 
			end else if (BAR1_SEL[13]) begin  	
					rd_data_r   <= DMA_address_5; 
			end else if (BAR1_SEL[14]) begin  	
					rd_data_r   <= DMA_address_6; 
			end else if (BAR1_SEL[15]) begin  	
					rd_data_r   <= DMA_address_7; 
			end else if (BAR1_SEL[16]) begin  	
					rd_data_r   <= DMA_address_8; 
			end else if (BAR1_SEL[17]) begin  	
					rd_data_r   <= DMA_address_9; 
			end else if (BAR1_SEL[18]) begin  	
					rd_data_r   <= DMA_address_10; 
			end else if (BAR1_SEL[19]) begin  	
					rd_data_r   <= DMA_address_11; 
			end else if (BAR1_SEL[20]) begin  	
					rd_data_r   <= DMA_address_12; 
			end else if (BAR1_SEL[21]) begin  	
					rd_data_r   <= DMA_address_13; 
			end else if (BAR1_SEL[22]) begin  	
					rd_data_r   <= DMA_address_14; 
			end else if (BAR1_SEL[23]) begin  	
					rd_data_r   <= DMA_address_15; 
					
			end else if (BAR1_SEL[24]) begin  	
					rd_data_r   <=  {16'h0000, DAC_1[15:0]}; 
						

		   end else if (BAR1_SEL[25]) begin  	
					rd_data_r   <=  {16'h0000, DAC_2[15:0]}; 

			end else if (BAR1_SEL[26]) begin  	
					//rd_data_r   <= DATA_PROCESS;  //  NEW
			      rd_data_r   <=  {16'h0000, DAC_3[15:0]}; 
			end else if (BAR1_SEL[27]) begin  	
					//rd_data_r   <=  GENERIC;  //  NEW		
					rd_data_r   <=  {16'h0000, DAC_4[15:0]}; 
			end else if (BAR1_SEL[28]) begin  	
					//rd_data_r   <=  ACQ_BYTE_SIZE;  //  NEW	
					rd_data_r   <=  {16'h0000, DAC_5[15:0]}; 
					
			end else if (BAR1_SEL[29]) begin  	
					rd_data_r   <=  {16'h0000, DAC_6[15:0]};  //  NEW	
					
			end else if (BAR1_SEL[30]) begin  	
					rd_data_r   <=  {16'h0000, DAC_7[15:0]};  //  NEW	
					
         end else if (BAR1_SEL[31]) begin  	
					rd_data_r   <=  {16'h0000, DAC_8[15:0]};  //  NEW					
					
			end else begin
			end
			
		end else if (rd_en_r) begin // write DMA - from fifo 
			rd_data_r  <= rd_data; // data from fifo
			//rd_data_r  <= {16'h0, test_data}; //debug
		end else begin
			rd_data_r   <= rd_data_r; 
		end
	end
end 

always @ (posedge clk_pcie or negedge rst_n) begin 
	if (!rst_n) begin    	
		rd_data_o      <= 32'b0;	
	end else begin 
		rd_data_o      <= rd_data_r;
	end
end

always @ (posedge clk_pcie or negedge rst_n) begin 
	if (!rst_n) begin    	
		rd_en_r     <= 1'b0;	
	end else begin 
		rd_en_r      <= rd_en;
	end
end

reg start_wr_req_r;
always @ (posedge clk_pcie or negedge rst_n) begin 
	if (!rst_n) begin    	
		start_wr_req     <= 1'b0;	
	end else begin 
		start_wr_req      <= start_wr_req_r;
	end
end

//############# PACKETS DIVISION IN MAX PAYLOAD ########################//

wire 	 [5:0] data_payload_max; 
assign data_payload_max = 6'h20; //32DW

wire [5:0]  packets;     // max transfer = 4096Bytes = 1024DW => se max DW in each packet = 32DW => 1024/32 = 32 packets 
wire [11:0] remainder;
wire [11:0] remainder_r;
reg 		   rest;
reg  [5:0]  npacket;    

assign packets = data_payload / data_payload_max; 
/*division division (
	.clk 		  (clk_pcie),
	.dividend  (data_payload),
	.divisor   (data_payload_max),
	.quotient  (packets),
	.remainder (),
	.rfd       ());  */
	
assign remainder_r = packets * data_payload_max; // - data_payload;  
 
assign remainder = (remainder_r < data_payload) ? (data_payload - remainder_r) : (remainder_r - data_payload);
//########################################################################################//

//##################### BUILD DMA PACKET ##########################################//
reg 					req_compl_delay; 
reg 					DMA_packet; 
reg 					half_mem_tmp; 
reg 					half_mem; 
reg   [1:0]       state_rd_wr; 
reg   [9:0]       len_i;               


always @ (posedge clk_pcie or negedge rst_n) begin 

	if (!rst_n) begin 	
		DMA_packet 		  <= 1'b0; 
		half_mem_tmp     <= 1'b0; 
		rd_en 			  <= 1'b0;
		len_i      	 	  <= 10'b0; 
		state_rd_wr 	  <= 2'b0; 
		start_wr_req_r	  <= 1'b0; 
		start_rd_req	  <= 1'b0; 
		npacket          <= 6'b0; 
		rest				  <= 1'b0;
		data_payload_out <= 6'b0;
		addr_host_out    <= 32'b0; 
		req_compl_delay  <= 1'b0;
	end else begin 
	
if(DMAE == 0) DMA_current_buffer <= 31'h0;
	
	case (state_rd_wr) 
	2'b00: begin	

         if (rest) begin  //ainda falta enviar + pacotes da mesma request
		 
				DMA_packet <= 1'b1; 
				
				if (half_mem) begin 
					half_mem_tmp <=1'b1; 
				end else begin 
					half_mem_tmp <=1'b0; 
				end
				
				if (req_compl) begin 
						req_compl_delay	<=1'b1;
				end
				  
				if (trn_tbuf_av != 4'b0) begin 
				
				  addr_host_out <= {addr_host_out +  {data_payload_max,2'b0}}; 
				
					if (npacket == 1'b0 && remainder != 1'b0) begin 
							len_i 				<= remainder[5:0];
							data_payload_out  <= remainder[5:0];
							rest  				<= 1'b0; 
							
							start_wr_req_r	  <=1'b1; 
							rd_en 			  <= 1'b0;	//atrasa 1clk	
							state_rd_wr 	  <= 2'b01;
							
							
					end else if (npacket == 5'b0 && remainder == 1'b0) begin 
							
							len_i     			<= 10'b1;			
							data_payload_out 	<= 6'b0;
							rest  				<= 1'b0; 
							
							start_wr_req_r		<= 1'b0; 			
							rd_en 				<= 1'b0; 
							state_rd_wr 		<= 2'b00;
							
					end else begin 
							len_i   				 <= data_payload_max;
							data_payload_out   <= data_payload_max;
							rest    				 <= 1'b1; 
							npacket 				 <= npacket -1'b1; 
							
							start_wr_req_r	    <=1'b1; 
							rd_en 			    <= 1'b0;  //atrasa 1clk	
							state_rd_wr 	    <= 2'b01;
					end 
				
				end else begin
			   end
		
								
			end else if (start_DMA_ready && DMAE_r3 && half_mem && !half_mem_tmp && trn_tsrc_rdy_n && data_payload !=10'b0) begin 			//mem_read					
				
				
				if (req_compl) begin 
						req_compl_delay	<=1'b1;
				end
				
				
				if (trn_tbuf_av != 4'b0) begin 
				
					if (DMA_current_buffer[3:0] == (DMA_Buffer_number[3:0] - 1'h1)) begin 		
							DMA_current_buffer[3:0] <= 4'h0; 
					end else begin
						DMA_current_buffer[3:0] <= DMA_current_buffer[3:0] + 1'b1; //mudo aqui o current buffer
					end 
				
					DMA_packet 	 	<= 1'b1; 
					half_mem_tmp 	<= 1'b1; 
				
				  	addr_host_out 	<= addr_host; 

					start_wr_req_r	  <=1'b1; 
					rd_en 			  <= 1'b0; //atrasa 1clk
					state_rd_wr 	  <= 2'b01; 	
					
					if (packets == 5'b0) begin 
							len_i 				 <= remainder[5:0];
							data_payload_out   <= remainder[5:0];
							rest 			 		 <= 1'b0; 
					end else begin 
							len_i   				 <= data_payload_max;
							data_payload_out   <= data_payload_max;
							rest    				 <= 1'b1; 
							npacket  			 <= packets -1'b1; 
					end		
				end else begin
				end
		
        end else if (req_compl || req_compl_delay) begin 
	
				DMA_packet 			<= 1'b0;	
					
				if (trn_tbuf_av != 4'b0) begin 
					
					start_rd_req		<= 1'b1;  //REGISTERS
					start_wr_req_r		<= 1'b0; 
			      req_compl_delay   <= 1'b0; 
					state_rd_wr 		<= 2'b10; 
					
				end else begin 
					req_compl_delay 	<= 1'b1; 
				end 				
		  
		  end else begin	
		 		
				DMA_packet 			<= 1'b0;
				
				start_wr_req_r	   <= 1'b0; 			
				rd_en 			   <= 1'b0;
				len_i     		   <= 10'b0;				
				state_rd_wr 	   <= 2'b00;
				data_payload_out  <= 6'b0;
				req_compl_delay   <= 1'b0;
				
			end
		end
		  
	2'b01: begin  //DMA
			
					
				DMA_packet 			<= 1'b1;
				
				start_wr_req_r		<=1'b0; 
				data_payload_out  <= data_payload_out;
				
				if (req_compl) begin 
					req_compl_delay	<=1'b1;
				end
				
				if (trn_tbuf_av != 4'b0) begin 
				
					if (len_i >= 1'b1) begin				
					
						rd_en 		<= 1'b1;  
						len_i     	<= len_i - 1'b1; 
						state_rd_wr <= 2'b01; 
				
					end else begin 
						rd_en 		<= 1'b0;			 		
						len_i    	<= 10'b0;
						state_rd_wr <= 2'b11; 
					end
		
				end else begin 
						rd_en 		<= 1'b0; 
				end
			 
	end
	
	2'b10: begin  //read req      
					
					DMA_packet 	   <= 1'b0;
					
					start_wr_req_r	<=1'b0; 
					start_rd_req	<=1'b0;
					state_rd_wr 	<= 2'b00; 
	end  
	
	2'b11: begin
					
					DMA_packet 		<= 1'b1;
					
					start_wr_req_r	<=	1'b0; 
					start_rd_req	<=	1'b0;
					state_rd_wr 	<= 2'b00; 
					
				  if (req_compl) begin 
						req_compl_delay	<=1'b1;
				  end
				  
					if (half_mem) begin 
						half_mem_tmp <=1'b1; 
					end else begin 
						half_mem_tmp <=1'b0; 
					end
	end
	endcase
	end 
end


//########################################################################//


//############## FIFO - WR_MEM_DATA; RD PCIE_DMA #########################//

/*reg      		PCIe_rd_en_r; 			
reg  [31:0]   	PCIe_rd_data_r; 		

always @ (posedge clk_pcie or negedge rst_n) begin 
	if (!rst_n) begin 	
		PCIe_rd_en_r		<=  1'h0; 
		PCIe_rd_data_r    <= 32'h0; 
	end else begin 
		PCIe_rd_en_r		<= PCIe_rd_en; 
		PCIe_rd_data_r    <= PCIe_rd_data; 
	end 
end 
*/
//--------------------------------------------------------------------------//
reg 			rst_DMA_FIFO; 

dma_fifo dma_fifo (
   .rst				(rst_DMA_FIFO),	
	.wr_en			(PCIe_rd_en),
	.din				(PCIe_rd_data),
	.wr_clk        (DSP_clock),
	.rd_clk 		   (clk_pcie),
	.rd_en 			(rd_en),
	.dout				(rd_data),
	.empty			(empty_dma_fifo),
	.full				(),
	.prog_full		(busy)
); 
//########################################################################//

/*always @ (posedge clk_pcie or negedge rst_n) begin 
	if (!rst_n) begin 	
		DMAn		      <=  1'h1; 
		rst_DMA_FIFO   <=  1'b1; 
		en_count       <= 1'h0;
	end else begin 
		rst_DMA_FIFO   <= 1'b0; 
		en_count       <= 1'h0; 		
		if ( busy && !half_mem && ACQ_COMP) begin 
			DMAn    						<=1'h1; 
			en_count 					<=1'h1; 
		end else if (state_rd_wr == 2'b01) begin //tá a enviar DMA 
			DMAn                    <=1'h0; 
		end else if (!DMAE_r3) begin 
			DMAn    			 <= 1'h1;
			rst_DMA_FIFO    <= 1'b1; 
		end else begin 
		end
		
   end 		
end 

reg  state_half_mem; 
always @ (posedge clk_pcie or negedge rst_n) begin 	
	if (!rst_n) begin 
		half_mem 			<= 1'b0; 
		state_half_mem		<= 1'b0; 
	end else begin 
	
		case (state_half_mem) 
		
			1'b0: begin 
				if (ACQ_COMP && !ACQE && DMAE_r3 && !empty_dma_fifo) begin 
					half_mem				<= 1'b0; 	
					state_half_mem		<= 1'b1; 	
				end else begin 
					half_mem				<= 1'b0; 
				end 
			end 	
			1'b1: begin 
				if (!DMAE_r3) begin 
					half_mem				<= 1'b0; 	
					state_half_mem		<= 1'b0; 
				end else begin
					half_mem				<= DMAn; 	
				end 
			end
		endcase
	end 
end */

reg [1:0] state_half_mem; 
always @ (posedge clk_pcie or negedge rst_n) begin 	
	if (!rst_n) begin 
		half_mem 			<= 1'b0; 
		state_half_mem		<= 2'b0; 
		rst_DMA_FIFO      <= 1'b0;
	end else begin 
		
		rst_DMA_FIFO      <= 1'b0;
		
		if (!DMAE_r3) begin 
				half_mem				<= 1'b0; 
				rst_DMA_FIFO      <= 1'b1;
		
		end else begin 
			case (state_half_mem) 
		
			2'b00: begin 
					if (DMAE_r3 && busy) begin 
						half_mem				<= 1'b1;
						state_half_mem		<= 2'b01; 	
					end else begin
						half_mem				<= 1'b0;
						state_half_mem		<= 2'b00; 
					end
			end
			2'b01: begin 
				if (DMA_packet) begin 
						half_mem				<= 1'b0;
						state_half_mem		<= 2'b10; 
				end else begin 
						half_mem				<= 1'b1;
						state_half_mem		<= 2'b01; 
				end
			end
			2'b10: begin 
				if (!DMA_packet) begin 
						half_mem				<= 1'b0;
						state_half_mem		<= 2'b00; 
				end else begin 
						half_mem				<= 1'b0;
						state_half_mem		<= 2'b10; 
				end
			end
			endcase
		end 
   end 
end 
			

//##########################################################################//



endmodule