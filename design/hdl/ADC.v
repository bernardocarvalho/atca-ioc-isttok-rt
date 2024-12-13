//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company: INSTITUTO DOS PLASMAS E FUSAO NUCLEAR
// Engineer: AJNB
//
// Project Name:   JET PLASMA VS CONTROLLER
// Design Name:    ATCA-GPIO-CONTROL FIRMWARE
// Module Name:    ADC
// Target Devices: XC4VFX60-11FF1152 or XC4VFX100-11FF1152
//
// Revision: Final2_f
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module ADC (
input reset,
input processing_clock,
input acquisition_clk,
input ADC_word_sync,                    
input ADC_clock,
input ADC_serial_data,
input decimation_clk,
output reg [31:0] ADC_data
//output reg ADC_detection                                                                           				                                                             				
);

wire [3:0] counts;
bits_counter CORE1 (
.aclr(ADC_word_sync),
.clk(ADC_clock),
.q(counts)
);

// ADC module detection
/*always @ (posedge acquisition_clk)
begin
 if(counts != 0)
  ADC_detection <= 1;
 else 
  ADC_detection <= 0;
end*/

// ADC DDR recovery
wire IDDR_Q1;
wire IDDR_Q2;
IDDR #(
.DDR_CLK_EDGE("OPPOSITE_EDGE"), // "OPPOSITE_EDGE", "SAME_EDGE" or "SAME_EDGE_counterLINED"
.INIT_Q1(1'b0), // Initial value of Q1: 1'b0 or 1'b1
.INIT_Q2(1'b0), // Initial value of Q2: 1'b0 or 1'b1
.SRTYPE("ASYNC") // Set/Reset type: "SYNC" or "ASYNC"
) DESER (
.Q1(IDDR_Q1), // 1-bit output for positive edge of clock
.Q2(IDDR_Q2), // 1-bit output for negative edge of clock
.C(ADC_clock), // 1-bit clock input
.CE(1), // 1-bit clock enable input
.D(ADC_serial_data), // 1-bit DDR data input
.R(ADC_word_sync), // 1-bit reset
.S(0) // 1-bit set
);

// ADC deserialzer
reg [17:2] data = 0;	
always @ (posedge ADC_clock)
begin	
	case(counts)
	  8 : begin
	       data[2] <= IDDR_Q2;
          data[3] <= IDDR_Q1;
         end
	  7 : begin
	       data[4] <= IDDR_Q2;
          data[5] <= IDDR_Q1;
         end
	  6 : begin
	       data[6] <= IDDR_Q2;
          data[7] <= IDDR_Q1;
         end
	  5 : begin
	       data[8] <= IDDR_Q2;
          data[9] <= IDDR_Q1;
         end	
	  4 : begin
	       data[10] <= IDDR_Q2;
          data[11] <= IDDR_Q1;
         end
	  3 : begin
	       data[12] <= IDDR_Q2;
          data[13] <= IDDR_Q1;
         end
	  2 : begin
	       data[14] <= IDDR_Q2;
          data[15] <= IDDR_Q1;
         end
	  1 : begin
	       data[16] <= IDDR_Q2;
          data[17] <= IDDR_Q1;
         end
	 default : data <= 0;
	endcase 
end

reg [16:0] data_reg;
always @ (posedge acquisition_clk)
begin
 data_reg <= {data, IDDR_Q1/*, IDDR_Q2*/};
 //ADC_data[31:0] <= {data, IDDR_Q1, IDDR_Q2, 14'h0000};
end

wire ready_for_data;
reg FIR_new_data;
always @ (posedge processing_clock)
begin
 FIR_new_data <= ready_for_data & ADC_word_sync;
end

wire [17:0] FIR_data_out;
FIR_decimation_100 CORE2 (
.sclr(reset),
.clk(processing_clock),
.din(data_reg),
.nd(FIR_new_data),
.rfd(ready_for_data),
.rdy(),
.dout(FIR_data_out)
);

always @ (posedge decimation_clk)
begin
 ADC_data[31:0] <= {FIR_data_out, 14'h0000};
end


/*reg [8:0] ADC_data_pos = 0;	
reg [8:0] ADC_data_neg = 0;	

always @ (posedge ADC_clock)
	ADC_data_pos <= {ADC_data_pos[7:0], ADC_serial_data};
always @ (negedge ADC_clock)
	ADC_data_neg <= {ADC_data_neg[7:0], ADC_serial_data};


always @ (negedge ADC_word_sync)
 ADC_data[31:0] <= {ADC_data_pos[8], ADC_data_neg[8],
						ADC_data_pos[7], ADC_data_neg[7],
						ADC_data_pos[6], ADC_data_neg[6],
						ADC_data_pos[5], ADC_data_neg[5],
						ADC_data_pos[4], ADC_data_neg[4],
						ADC_data_pos[3], ADC_data_neg[3],
						ADC_data_pos[2], ADC_data_neg[2],
						ADC_data_pos[1], ADC_data_neg[1],
						ADC_data_pos[0], ADC_data_neg[0],14'h0000};*/

endmodule
