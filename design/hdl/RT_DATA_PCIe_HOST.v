//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company: INSTITUTO DOS PLASMAS E FUSAO NUCLEAR
// Engineer: AJNB
//
// Project Name:   JET PLASMA VS CONTROLLER
// Design Name:    ATCA-GPIO-CONTROL FIRMWARE
// Module Name:    RT_DATA_PCIe_HOST
// Target Devices: XC4VFX60-11FF1152 or XC4VFX100-11FF1152
//
// Revision: Final2_f
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module RT_DATA_PCIe_HOST (
input ATCA_DMA_clk,
input [31:0] word0,
input [31:0] word1,
input [31:0] word2,
input [31:0] word3,
input [31:0] word4,
input [31:0] word5,
input [31:0] word6,
input [31:0] word7,
input [31:0] word8,
input [31:0] word9,
input [31:0] word10,
input [31:0] word11,
input [31:0] word12,
input [31:0] word13,
input [31:0] word14,
input [31:0] word15,
input [31:0] word16,
input [31:0] word17,
input [31:0] word18,
input [31:0] word19,
input [31:0] word20,
input [31:0] word21,
input [31:0] word22,
input [31:0] word23,
input [31:0] word24,
input [31:0] word25,
input [31:0] word26,
input [31:0] word27,
input [31:0] word28,
input [31:0] word29,
input [31:0] word30,
input [31:0] word31,
input [31:0] word32,
input [31:0] word33,	
input [31:0] word34,	
input [31:0] word35,	
input [31:0] word36,	
input [31:0] word37,	
input [31:0] word38,	
input [31:0] word39,	
input [31:0] word40,
input [31:0] word41,	
input processing_clock,  	 
input PCIe_trn_rst, 
output reg PCIe_rd_en, 
output reg [31:0] PCIe_rd_data
);

reg [15:0] word_counts;
always @ (posedge processing_clock)
begin
 if((ATCA_DMA_clk == 1) || (PCIe_trn_rst == 1))
  word_counts <= 0;
 else
  word_counts <= word_counts + 1;
end

always @ (posedge processing_clock)
begin
 case (word_counts) 
16'd1 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word0;
		  end 
16'd2 : begin 
	      PCIe_rd_en <= 1;
			PCIe_rd_data <= word1;
		  end 
16'd3 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word2;
		  end 
16'd4 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word3;
		  end 
16'd5 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word4;
		  end 
16'd6 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word5;
		  end 
16'd7 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word6;
		  end 
16'd8 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word7;
		  end 
16'd9 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word8;
		  end 
16'd10 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word9;
		  end 
16'd11 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word10;
		  end 
16'd12 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word11;
		  end 
16'd13 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word12;
		  end 
16'd14 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word13;
		  end 
16'd15 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word14;
		  end 
16'd16 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word15;
		  end 
16'd17 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word16;
		  end 
16'd18 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word17;
		  end 
16'd19 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word18;
		  end 
16'd20 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word19;
		  end 
16'd21 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word20;
		  end 
16'd22 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word21;
		  end 
16'd23 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word22;
		  end 
16'd24 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word23;
		  end 
16'd25 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word24;
		  end 
16'd26 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word25;
		  end 
16'd27 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word26;
		  end 
16'd28 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word27;
		  end 
16'd29 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word28;
		  end 
16'd30 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word29;
		  end 
16'd31 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word30;
		  end 
16'd32 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word31;
		  end 
16'd33 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word32;
		  end 
16'd34 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word33;
		  end 
16'd35 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word34;
		  end 
16'd36 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word35;
		  end 		 
16'd37 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word36;
		  end 
16'd38 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word37;
		  end 	
16'd39 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word38;
		  end 	
16'd40 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word39;
		  end 		
16'd41 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word40;
		  end 
16'd42 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word41;
		  end 		  
16'd43 : begin 
	      PCIe_rd_en <= 1;
	      PCIe_rd_data <= word0;
		  end  
   default : begin 
	           PCIe_rd_en <= 0;
	           PCIe_rd_data <= 0;
			    end
 endcase
end
	
endmodule
