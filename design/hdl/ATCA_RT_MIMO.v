///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company: INSTITUTO DOS PLASMAS E FUSAO NUCLEAR
// Engineer: AJNB
//
// Project Name:   JET PLASMA VS CONTROLLER
// Design Name:    ATCA-GPIO-CONTROL FIRMWARE
// Module Name:    ATCA_RT_MIMO
// Target Devices: XC4VFX60-11FF1152 or XC4VFX100-11FF1152
//
// Revision: Final2_f
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module ATCA_RT_MIMO (

output reg ADCs_RESET = 0,
output ADCs_POWER_DOWN,
output ADCs_START_CONV_P,
output ADCs_START_CONV_N,
input [32:1] ADC_CLK_P,
input [32:1] ADC_CLK_N,
input [32:1] ADC_DATA_P,
input [32:1] ADC_DATA_N,

output [8:1] DAC_RESET,
output [8:1] DAC_ENABLE,
output DAC_CLK_P,
output DAC_CLK_N,
output [8:1] DAC_DATA_P,
output [8:1] DAC_DATA_N,

input [8:1] RS485_RX, // CTTS trigger [1], CTTS clock [2]
output [8:1] RS485_TX,
output [8:1] RS485_TX_ENABLE,

output PCIe_PLL_RESET,	
input PCIe_CLOCK_LOS,

output [3:0] ATCA_TX_P_C1_P,
output [3:0] ATCA_TX_N_C1_P,
input [3:0] ATCA_RX_P_C1_P,
input [3:0] ATCA_RX_N_C1_P,

input [1:0] MGT_CLK_P,
input [1:0] MGT_CLK_N,

output [13:3] ATCA_TX_P_P0_C,
output [13:3] ATCA_TX_N_P0_C,
input [13:3] ATCA_RX_P_P0_C,
input [13:3] ATCA_RX_N_P0_C,

output SFP_TX_P,
output SFP_TX_N,
input SFP_RX_P,
input SFP_RX_N,

input SFP_LOS,

input ATCA_RX_1A, // ATCA CTTS clock input
input ATCA_RX_2A, // ATCA DMA sync input
input ATCA_RX_1B, // ATCA CTTS trigger input
input ATCA_RX_2B, // ATCA DSP clock input
input ATCA_RX_3A, // ATCA PCIe reset input
output ATCA_TX_1A, // ATCA CTTS clock driver
output ATCA_TX_2A, // ATCA DMA sync driver
output ATCA_TX_1B, // ATCA CTTS trigger driver
output ATCA_TX_2B, // ATCA DSP clock driver
output ATCA_TX_3A, // Do not use
output ATCA_TX_1A_ENABLE,
output ATCA_TX_2A_ENABLE,
output ATCA_TX_1B_ENABLE,
output ATCA_TX_2B_ENABLE,
output ATCA_TX_3A_ENABLE,

//input SYS_RESET,

input RTM_PRESENT,

output [6:5] IPMC_GPO,
input [10:7] IPMC_GPI,

input SYSACE_CLOCK,
output SYSACE_MPCE,

output AD9511_REF_P,
output AD9511_REF_N,
input AD9511_OUT_P,
input AD9511_OUT_N,
input AD9511_STATUS,
output AD9511_FUNCTION,
output AD9511_CSB, 
output AD9511_SCLK,
output AD9511_SDIO,

input DDR_PLL_LOCK

// DDR2 test
/*
input sys_reset_in_n,
input sys_clk_p,
input sys_clk_n,
input clk200_p,
input clk200_n,
output [`ROW_ADDRESS-1:0] cntrl0_ddr2_a,
output [`BANK_ADDRESS-1:0] cntrl0_ddr2_ba,
output cntrl0_ddr2_ras_n,
output cntrl0_ddr2_cas_n,
output cntrl0_ddr2_we_n,
output [`CS_WIDTH-1:0] cntrl0_ddr2_cs_n,
output [`ODT_WIDTH-1:0] cntrl0_ddr2_odt,
output [`CKE_WIDTH-1:0] cntrl0_ddr2_cke,
output [`DATA_MASK_WIDTH-1:0] cntrl0_ddr2_dm,
inout [`DATA_WIDTH-1:0] cntrl0_ddr2_dq,
inout [`DATA_STROBE_WIDTH-1:0] cntrl0_ddr2_dqs,
inout [`DATA_STROBE_WIDTH-1:0] cntrl0_ddr2_dqs_n,
output [`CLK_WIDTH-1:0] cntrl0_ddr2_ck,
output [`CLK_WIDTH-1:0] cntrl0_ddr2_ck_n,
*/
// end DDR2 test

);

//`include "DDR2_512MB_parameters_0.v"

// Timing and syncronism ********************************************************************

assign RS485_TX[8:1] = 8'b11111111;
assign RS485_TX_ENABLE[8:1] = 8'b00000000;

wire ATCA_acquisition_clk;
wire software_trigger;
reg [1:0] software_trigger_delay;
reg [1:0] RS485_RX_1_delay;
reg trigger;
reg soft_trigger;
always @ (posedge ATCA_acquisition_clk)
begin
 software_trigger_delay[0] <= software_trigger;
 software_trigger_delay[1] <= software_trigger_delay[0];
 soft_trigger <= ~software_trigger | software_trigger_delay[1];
 RS485_RX_1_delay[0] <= RS485_RX[1];
 RS485_RX_1_delay[1] <= RS485_RX_1_delay[0];
 trigger <= RS485_RX[1] | ~RS485_RX_1_delay[1];
end 

wire master;
wire internal_clk_2MHz;
wire internal_clk_40MHz;

reg [33:0] time_counter;
reg DMA_clk;

assign master = ~IPMC_GPI[10] & ~IPMC_GPI[9] & IPMC_GPI[8] & IPMC_GPI[7];

assign ATCA_TX_1A = internal_clk_2MHz;//RS485_RX[2];
assign ATCA_TX_1B = soft_trigger & trigger & ~time_counter[33]; // 1 us low pulse 
assign ATCA_TX_2A = DMA_clk;
assign ATCA_TX_2B = internal_clk_40MHz;//1;
assign ATCA_TX_3A = 1;
assign ATCA_TX_1A_ENABLE = master;
assign ATCA_TX_1B_ENABLE = master;
assign ATCA_TX_2A_ENABLE = master;
assign ATCA_TX_2B_ENABLE = master; 
assign ATCA_TX_3A_ENABLE = 0; // Never enable when ATCA PCIe controller present

wire AD9511_ref;
assign AD9511_ref = ATCA_acquisition_clk; 
assign AD9511_FUNCTION = 1;

OBUFDS #(
.IOSTANDARD("LVDS_25")
) AD9511_REF (
.O(AD9511_REF_P),
.OB(AD9511_REF_N),
.I(AD9511_ref)
);

AD9511 CONFIGURATION1 (
.reset(0),
.AD9511_SCLK(AD9511_SCLK),
.AD9511_CSB(AD9511_CSB), 
.AD9511_SDIO(AD9511_SDIO)
);

assign SYSACE_MPCE = 1;

wire SYSACE_clock_buf;
IBUFG #(
.CAPACITANCE("LOW"), // "LOW", "NORMAL", "DONT_CARE"
.IOSTANDARD("LVCMOS33")
) SYSACE(
.O(SYSACE_clock_buf),
.I(SYSACE_CLOCK)
);

IBUFG #(
.CAPACITANCE("LOW"), // "LOW", "NORMAL", "DONT_CARE"
.IOSTANDARD("LVCMOS33")
) ATCA_RX_1 (
.O(ATCA_acquisition_clk),
.I(ATCA_RX_1A)
);

wire ATCA_processing_clk;
IBUFG #(
.CAPACITANCE("LOW"), // "LOW", "NORMAL", "DONT_CARE"
.IOSTANDARD("LVCMOS33")
) ATCA_RX_2 (
.O(ATCA_processing_clk),
.I(ATCA_RX_2B)
);

wire ATCA_reset; 
assign ATCA_reset = ~ATCA_RX_3A;

wire ATCA_trigger; 
assign ATCA_trigger = ~ATCA_RX_1B;

wire ATCA_DMA_clk; 
IBUFG #(
.CAPACITANCE("LOW"), // "LOW", "NORMAL", "DONT_CARE"
.IOSTANDARD("LVCMOS33")
) ATCA_RX_3 (
.O(ATCA_DMA_clk),
.I(ATCA_RX_2A)
);

wire AD9511_output_3;
IBUFGDS #(
.CAPACITANCE("LOW"), // "LOW", "NORMAL", "DONT_CARE"
.DIFF_TERM("TRUE"), // Differential Termination
.IOSTANDARD("LVDS_25")
) AD9511_CLK (
.O(AD9511_output_3),
.I(AD9511_OUT_P),
.IB(AD9511_OUT_N)
); 

wire DCM_locked;
wire ADCs_start_conv;
wire ADCs_start_conv_out;
SYSTEM_CLOCKS CONFIGURATION2 (
.clock_33MHz(SYSACE_clock_buf),
.ATCA_clk_2MHz(ATCA_acquisition_clk),
.PLL_clk_40MHz(AD9511_output_3),
.AD9511_status(AD9511_STATUS),
.internal_clk_4MHz125(AD9511_SCLK),
.internal_clk_40MHz(internal_clk_40MHz/*ATCA_processing_clk*/),
.ADCs_start_conv(ADCs_start_conv),
.ADCs_start_conv_out(ADCs_start_conv_out),
/*****************************/
.RTM_clk_2MHz(RS485_RX[2]),
.ATCA_clk_40MHz(ATCA_processing_clk),
.DCM_locked(DCM_locked),
.internal_clk_2MHz(internal_clk_2MHz)
);

OBUFDS #(
.IOSTANDARD("LVDS_25")
) ADCs_START (
.O(ADCs_START_CONV_P),
.OB(ADCs_START_CONV_N),
.I(ADCs_start_conv_out)
);

// downsampler
wire DMA_sync;
reg [7:0] DMA_counter;
always @ (posedge ATCA_acquisition_clk)
begin
 DMA_counter <= DMA_counter + 1; 
 if((DMA_counter == 99) || (ATCA_trigger == 1) || (ATCA_reset == 1) || (DMA_sync == 0))
  begin
   DMA_counter <= 0;
   DMA_clk <= 1;
  end
 else
  DMA_clk <= 0;
end

// DMA delay of master board
reg [9:0] ATCA_DMA_clk_delay;
reg ATCA_DMA_clk_reg;
always @ (posedge ATCA_processing_clk)
begin
 ATCA_DMA_clk_delay[0] <= ATCA_DMA_clk;
 ATCA_DMA_clk_delay[1] <= ATCA_DMA_clk_delay[0];
 ATCA_DMA_clk_delay[2] <= ATCA_DMA_clk_delay[1];
 ATCA_DMA_clk_delay[3] <= ATCA_DMA_clk_delay[2];
 ATCA_DMA_clk_delay[4] <= ATCA_DMA_clk_delay[3];
 ATCA_DMA_clk_delay[5] <= ATCA_DMA_clk_delay[4];
 ATCA_DMA_clk_delay[6] <= ATCA_DMA_clk_delay[5];
 ATCA_DMA_clk_delay[7] <= ATCA_DMA_clk_delay[6];
 ATCA_DMA_clk_delay[8] <= ATCA_DMA_clk_delay[7];
 ATCA_DMA_clk_delay[9] <= ATCA_DMA_clk_delay[8];
 if(master == 1) 
  ATCA_DMA_clk_reg <= ATCA_DMA_clk_delay[9];
 else
  ATCA_DMA_clk_reg <= ATCA_DMA_clk;
end

// time counter 500ns resolution
always @ (posedge ATCA_acquisition_clk)
begin
 if((ATCA_trigger == 1) || (ATCA_reset == 1))
  time_counter <= 1;
 else 
  time_counter <= time_counter + 1;
end

// time counter 1 us rsolution
reg [31:0] time_counter_reg;
always @ (posedge ATCA_DMA_clk)
begin
  time_counter_reg[31:0] <= time_counter[32:1];
end

// ADC channels *****************************************************************************

always @ (posedge ATCA_acquisition_clk)
begin
 case(IPMC_GPI[10:7])
  4'h3 : if(time_counter[15:0] == 10000) ADCs_RESET <= 1;
  4'h4 : if(time_counter[15:0] == 15000) ADCs_RESET <= 1;
  4'h5 : if(time_counter[15:0] == 20000) ADCs_RESET <= 1;
  4'h6 : if(time_counter[15:0] == 25000) ADCs_RESET <= 1;
  4'h7 : if(time_counter[15:0] == 30000) ADCs_RESET <= 1;
  4'h8 : if(time_counter[15:0] == 35000) ADCs_RESET <= 1;
  4'h9 : if(time_counter[15:0] == 40000) ADCs_RESET <= 1;
  4'hA : if(time_counter[15:0] == 45000) ADCs_RESET <= 1;
  4'hB : if(time_counter[15:0] == 50000) ADCs_RESET <= 1;
  4'hC : if(time_counter[15:0] == 55000) ADCs_RESET <= 1;
  4'hD : if(time_counter[15:0] == 60000) ADCs_RESET <= 1;
  4'hE : if(time_counter[15:0] == 65000) ADCs_RESET <= 1;
  default : ADCs_RESET <= 0;
 endcase
end

assign ADCs_POWER_DOWN = ~ADCs_RESET;

//parameter [32:1] SWAP_MASK = 32'h00801000;

wire [32:1] ADC_clock_buf;
wire [32:1] ADC_clock;
wire [32:1] ADC_serial_data; 
wire [31:0] ADC_data [32:1];
//wire [32:1] ADC_detection;

assign ADC_clock[12:1] = ADC_clock_buf[12:1];
assign ADC_clock[13] = ~ADC_clock_buf[13];
assign ADC_clock[23:14] = ADC_clock_buf[23:14];
assign ADC_clock[24] = ~ADC_clock_buf[24];
assign ADC_clock[32:25] = ADC_clock_buf[32:25];

genvar i; 
 
  generate for ( i = 1; i <= 32; i = i+1 ) 
    begin: ADCs 
	 
      IBUFDS #(
      .CAPACITANCE("DONT_CARE"), // "LOW", "NORMAL", "DONT_CARE"
      .DIFF_TERM("TRUE"), // Differential Termination
      .IOSTANDARD("LVDS_25")
      ) 
		ADCs_CLK_IBUFDS1_32 (
      .O(ADC_clock_buf[i]),
      .I(ADC_CLK_P[i]),
      .IB(ADC_CLK_N[i])
      );
		
		//assign ADC_clock[i] = ADC_clock_buf[i] ^ SWAP_MASK[i];

      IBUFDS #(
      .CAPACITANCE("DONT_CARE"), // "LOW", "NORMAL", "DONT_CARE"
      .DIFF_TERM("TRUE"), // Differential Termination
      .IOSTANDARD("LVDS_25")
      ) 
		ADCs_DATA_IBUFDS1_32 (
      .O(ADC_serial_data[i]),
      .I(ADC_DATA_P[i]),
      .IB(ADC_DATA_N[i])
      );

	    ADC CHANNEL1_32 ( 
		.reset(ATCA_reset | ATCA_trigger),
      .processing_clock(ATCA_processing_clk),
		.acquisition_clk(ATCA_acquisition_clk),
      .ADC_word_sync(ADCs_start_conv),
      .ADC_clock(ADC_clock[i]),
      .ADC_serial_data(ADC_serial_data[i]),
		.decimation_clk(ATCA_DMA_clk),
      .ADC_data(ADC_data[i])
      //.ADC_detection(ADC_detection[i])
		); 
    end 
  endgenerate

// DAC channels *****************************************************************************
wire PCIe_trn_clk;
wire [8:1] DAC_serial_data;
wire [15:0] DAC_data [8:1]; 

OBUFDS #(
.IOSTANDARD("BLVDS_25")
)
DACs_CLK_OBUFDS (
.O(DAC_CLK_P),
.OB(DAC_CLK_N),
.I(PCIe_trn_clk)
);

  generate for ( i = 1; i <= 8; i = i+1 ) 
    begin: DACs 
      OBUFDS #(
      .IOSTANDARD("LVDS_25")
      ) DACs_DATA_OBUFDS1_8 (
      .O(DAC_DATA_P[i]),
      .OB(DAC_DATA_N[i]),
      .I(DAC_serial_data[i])
      );

      DAC RTM_CHANNEL1_8 (
		.reset(ATCA_reset),
      .DAC_data(DAC_data[i]),
      .DAC_clock(PCIe_trn_clk),
      .DAC_serial_data(DAC_serial_data[i]),
      .DAC_word_sync(DAC_ENABLE[i]),
      .DAC_reset(DAC_RESET[i])		
      );
    end 
  endgenerate

// MGT clocks *******************************************************************************
wire PCIe_clock;
wire ref_clk2_column1;
wire ref_clk2_column0;

GT11CLK_MGT PCIe (   
.MGTCLKP(MGT_CLK_P[0]),
.MGTCLKN(MGT_CLK_N[0]),
.SYNCLK1OUT(PCIe_clock),
.SYNCLK2OUT()
);
defparam PCIe.SYNCLK1OUTEN = "ENABLE";
defparam PCIe.SYNCLK2OUTEN = "DISABLE";

GT11CLK_MGT AURORA_COLUMN0 (
.MGTCLKP(MGT_CLK_P[1]), 
.MGTCLKN(MGT_CLK_N[1]), 
.SYNCLK1OUT(), 
.SYNCLK2OUT(ref_clk2_column0)
);
defparam AURORA_COLUMN0.SYNCLK1OUTEN = "DISABLE";
defparam AURORA_COLUMN0.SYNCLK2OUTEN = "ENABLE";	

/*GT11CLK_MGT AURORA_COLUMN1 (
.MGTCLKP(MGT_CLK_P[2]), 
.MGTCLKN(MGT_CLK_N[2]), 
.SYNCLK1OUT(), 
.SYNCLK2OUT(ref_clk2_column1)
);
defparam AURORA_COLUMN1.SYNCLK1OUTEN = "DISABLE";
defparam AURORA_COLUMN1.SYNCLK2OUTEN = "ENABLE";	
//synthesis attribute LOC of AURORA_COLUMN1 is "GT11CLK_X1Y1";
//synthesis attribute period of ref_clk2_column1 is "4ns";*/

// ATCA fabric channels 3 to 13 *************************************************************  
/*wire [13:3] lane_up;
wire [13:3] channel_up;
wire [13:3] ref_clk2;

assign ref_clk2[3] = ref_clk2_column1;
assign ref_clk2[4] = ref_clk2_column1;
assign ref_clk2[5] = ref_clk2_column1;
assign ref_clk2[6] = ref_clk2_column1;

assign ref_clk2[7] = ref_clk2_column0;
assign ref_clk2[8] = ref_clk2_column0;
assign ref_clk2[9] = ref_clk2_column0;
assign ref_clk2[10] = ref_clk2_column0;
assign ref_clk2[11] = ref_clk2_column0;
assign ref_clk2[12] = ref_clk2_column0;
assign ref_clk2[13] = ref_clk2_column0;

  generate for ( i = 3; i <= 13; i = i+1 ) 
    begin: AURORA 
      AURORA_32_BITS ATCA_P0_C3_13 (
		.RESET(ATCA_reset),
	   .init_clk_i(SYSACE_clock_buf),
      .PMA_INIT(ATCA_reset),
      .RX_SIGNAL_DETECT(1),
      .RESET_CALBLOCKS(ATCA_reset),
	   .TX_LOCK(),
      .RX_LOCK(),
      .HARD_ERROR(),
      .SOFT_ERROR(),
      .FRAME_ERROR(),
      .ERROR_COUNT(),
      .LANE_UP(lane_up[i]),
      .CHANNEL_UP(channel_up[i]),
      .ref_clk2_left_i(ref_clk2[i]),
      .RXP(ATCA_RX_P_P0_C[i]),
      .RXN(ATCA_RX_N_P0_C[i]),
      .TXP(ATCA_TX_P_P0_C[i]),
      .TXN(ATCA_TX_N_P0_C[i])
      );
    end 
  endgenerate*/

//SFP RTM ***********************************************************************************
wire SFP_channel_up;
wire SFP_ref_clk2;
wire [3:0] ERFA_current;
wire [31:0] BAR1sel;
wire PCIe_wr_en;

// even parity generator
reg current_parity;
reg tx_clk_enable;
reg [1:0] BAR1sel_delay;
//reg [2:0] addr;
always @ (posedge PCIe_trn_clk)
begin
 current_parity <= ERFA_current[0] ^ ERFA_current[1] ^ ERFA_current[2] ^ ERFA_current[3];
 BAR1sel_delay[0] <= (BAR1sel[2] & PCIe_wr_en);
 BAR1sel_delay[1] <= BAR1sel_delay[0];
 if(BAR1sel_delay[1] == 1)
  begin
   tx_clk_enable <= 1;
	//addr <= addr + 1;
  end	
 else
  tx_clk_enable <= 0;
end
 
wire [31:0] ERFA_readings;
wire rx_clk_enable;

assign SFP_ref_clk2 = ref_clk2_column0;

AURORA_32_BITS RTM_SFP (
.RESET(ATCA_reset),
.init_clk_i(SYSACE_clock_buf),
.PMA_INIT(ATCA_reset),
.RX_SIGNAL_DETECT(1), //~SFP_LOS
.RESET_CALBLOCKS(ATCA_reset),
.TX_LOCK(),
.RX_LOCK(),
.HARD_ERROR(),
.SOFT_ERROR(),
.FRAME_ERROR(),
.ERROR_COUNT(),
.LANE_UP(),
.CHANNEL_UP(SFP_channel_up),
.ref_clk2_left_i(SFP_ref_clk2),
.RXP(SFP_RX_P),
.RXN(SFP_RX_N),
.TXP(SFP_TX_P),
.TXN(SFP_TX_N),

.TX_CLK_EN(tx_clk_enable),
.TX_CLOCK(PCIe_trn_clk),
//.TX_DATA({12'h000, 1'b0, addr, 1'b0, addr, 4'h0, 1'b0, 1'b0, 1'b0, current_parity, ERFA_current[3:0]}),
.TX_DATA({27'h0000000, current_parity, ERFA_current[3:0]}),

.RX_DATA_VALID(rx_clk_enable),
.RX_CLK_EN(rx_clk_enable),
.RX_CLOCK(ATCA_processing_clk),
.RX_DATA(ERFA_readings)
);  

wire parity_check;
reg [15:0] ERFA_data [8:1];
reg [8:1] parity_error;
reg [3:0] rx_clk_enable_delay;

always @ (posedge ATCA_processing_clk)
begin
 rx_clk_enable_delay[0] <=  rx_clk_enable;
 rx_clk_enable_delay[1] <=  rx_clk_enable_delay[0];
 rx_clk_enable_delay[2] <=  rx_clk_enable_delay[1];
 rx_clk_enable_delay[3] <=  rx_clk_enable_delay[2];
 
 if(rx_clk_enable_delay[3] == 1)
  case(ERFA_readings[19:17])
   3'h0 : begin 
           ERFA_data[1] <= ERFA_readings[15:0];
           parity_error[1] <= parity_check;
			 end 
   3'h1 : begin 
           ERFA_data[2] <= ERFA_readings[15:0];
           parity_error[2] <= parity_check;
			 end
   3'h2 : begin 
           ERFA_data[3] <= ERFA_readings[15:0];
           parity_error[3] <= parity_check;
			 end 
   3'h3 : begin 
           ERFA_data[4] <= ERFA_readings[15:0];
           parity_error[4] <= parity_check;
			 end		
   3'h4 : begin 
           ERFA_data[5] <= ERFA_readings[15:0];
           parity_error[5] <= parity_check;
			 end 
   3'h5 : begin 
           ERFA_data[6] <= ERFA_readings[15:0];
           parity_error[6] <= parity_check;
			 end
   3'h6 : begin 
           ERFA_data[7] <= ERFA_readings[15:0];
           parity_error[7] <= parity_check;
			 end 
   3'h7 : begin 
           ERFA_data[8] <= ERFA_readings[15:0];
           parity_error[8] <= parity_check;
			 end			
  endcase
end 

assign parity_check = ERFA_readings[15] ^ ERFA_readings[14] ^ ERFA_readings[13] ^ ERFA_readings[12]
                    ^ ERFA_readings[11] ^ ERFA_readings[10] ^ ERFA_readings[9] ^ ERFA_readings[8] 
				        ^ ERFA_readings[7] ^ ERFA_readings[6] ^ ERFA_readings[5] ^ ERFA_readings[4]
				        ^ ERFA_readings[3] ^ ERFA_readings[2] ^ ERFA_readings[1] ^ ERFA_readings[0]
			           ^ ERFA_readings[16];

//Front panel LEDs***************************************************************************  
assign IPMC_GPO[6] = time_counter[20];
							  
assign IPMC_GPO[5] = ~SFP_channel_up; 
 	 
// ATCA fabric channel 1 ********************************************************************

assign PCIe_PLL_RESET = 0;

wire PCIe_trn_rst;
wire PCIe_rd_en;
wire [31:0] PCIe_rd_data;
 
PCIe_32_BITS ATCA_P0_C1 (
.PCIe_TX_P(ATCA_TX_P_C1_P[0]), //O
.PCIe_TX_N(ATCA_TX_N_C1_P[0]), //O
.PCIe_RX_P(ATCA_RX_P_C1_P[0]), //I
.PCIe_RX_N(ATCA_RX_N_C1_P[0]), //I
.PCIe_reset(ATCA_reset),     //I
.PCIe_clock(PCIe_clock),     //I
.PCIe_trn_clk(PCIe_trn_clk), //O
.PCIe_trn_rst(PCIe_trn_rst), //O 
.PCIe_wr_en(PCIe_wr_en),		           //O	
.PCIe_wr_addr(),             //O
.PCIe_wr_data(),             //O
.PCIe_LEN(), 
.BAR0_SEL(),   		        //O
.BAR1_SEL(BAR1sel),   		  //O	
.BAR1_ACT_REG(0),            //I
.PCIe_rd_addr(),             //O
.PCIe_req_en(),		        //O
.PCIe_rd_en(PCIe_rd_en),     //I
.PCIe_rd_data(PCIe_rd_data), //I
.busy(),			              //O	
.DSP_clock(ATCA_processing_clk),
.software_trigger(software_trigger),
.software_reset(),
.master_slave(master),
.DMA_sync(DMA_sync),
.DMA_enable(1),
.RTM_present(~RTM_PRESENT),
.slot_id(IPMC_GPI[10:7]),
.DAC_1(DAC_data[1]),
.DAC_2(DAC_data[2]),
.DAC_3(DAC_data[3]),
.DAC_4(DAC_data[4]),
.DAC_5(DAC_data[5]),
.DAC_6(DAC_data[6]),
.DAC_7(DAC_data[7]),
.DAC_8(DAC_data[8]),
.ERFA_current(ERFA_current)
);

// Data sent to host, via DMA, in real time *************************************************
RT_DATA_PCIe_HOST INTERFACE1 ( 
.ATCA_DMA_clk(ATCA_DMA_clk_reg),
.word0(time_counter_reg),
.word1(ADC_data[1]),
.word2(ADC_data[2]),
.word3(ADC_data[3]),
.word4(ADC_data[4]),
.word5(ADC_data[5]),
.word6(ADC_data[6]),
.word7(ADC_data[7]),
.word8(ADC_data[8]),
.word9(ADC_data[9]),
.word10(ADC_data[10]),
.word11(ADC_data[11]),
.word12(ADC_data[12]),
.word13(ADC_data[13]),
.word14(ADC_data[14]),
.word15(ADC_data[15]),
.word16(ADC_data[16]),
.word17(ADC_data[17]),
.word18(ADC_data[18]),
.word19(ADC_data[19]),
.word20(ADC_data[20]),
.word21(ADC_data[21]),
.word22(ADC_data[22]),
.word23(ADC_data[23]),
.word24(ADC_data[24]),
.word25(ADC_data[25]),
.word26(ADC_data[26]),
.word27(ADC_data[27]),
.word28(ADC_data[28]),
.word29(ADC_data[29]),
.word30(ADC_data[30]),
.word31(ADC_data[31]),
.word32(ADC_data[32]),
.word33({ERFA_data[1], 16'h0000}),
.word34({ERFA_data[2], 16'h0000}),
.word35({ERFA_data[3], 16'h0000}),
.word36({ERFA_data[4], 16'h0000}),
.word37({ERFA_data[5], 16'h0000}),
.word38({ERFA_data[6], 16'h0000}),
.word39({ERFA_data[7], 16'h0000}),
.word40({ERFA_data[8], 16'h0000}),
.word41({SFP_channel_up, ~SFP_LOS, ~AD9511_STATUS, ~PCIe_CLOCK_LOS, ~DDR_PLL_LOCK, ~DCM_locked,
 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, 1'b0, parity_error[8:1], RS485_RX[8:3], 1'b1, RS485_RX[1], IPMC_GPI[10:7]}),
.processing_clock(ATCA_processing_clk), 
.PCIe_trn_rst(~PCIe_trn_rst),
.PCIe_rd_en(PCIe_rd_en), 
.PCIe_rd_data(PCIe_rd_data)
);

/*
DDR2_PCIE INTERFACE2 (
.cntrl0_ddr2_dq(cntrl0_ddr2_dq),
.cntrl0_ddr2_a(cntrl0_ddr2_a),
.cntrl0_ddr2_ba(cntrl0_ddr2_ba),
.cntrl0_ddr2_ras_n(cntrl0_ddr2_ras_n),
.cntrl0_ddr2_cas_n(cntrl0_ddr2_cas_n),
.cntrl0_ddr2_we_n(cntrl0_ddr2_we_n),
.cntrl0_ddr2_cs_n(cntrl0_ddr2_cs_n),
.cntrl0_ddr2_odt(cntrl0_ddr2_odt),
.cntrl0_ddr2_cke(cntrl0_ddr2_cke),
.cntrl0_ddr2_dm(cntrl0_ddr2_dm),
.cntrl0_ddr2_dqs(cntrl0_ddr2_dqs),
.cntrl0_ddr2_dqs_n(cntrl0_ddr2_dqs_n),
.cntrl0_ddr2_ck(cntrl0_ddr2_ck),
.cntrl0_ddr2_ck_n(cntrl0_ddr2_ck_n),
.sys_clk_p(sys_clk_p),
.sys_clk_n(sys_clk_n),
.clk200_p(clk200_p),
.clk200_n(clk200_n),
.sys_reset_in_n(sys_reset_in_n),
.cntrl0_init_done(cntrl0_init_done),
.PCIe_trn_clk(PCIe_trn_clk),
.PCIe_rd_data(PCIe_rd_data),                
.PCIe_wr_addr(PCIe_wr_addr), 
.PCIe_wr_data(PCIe_wr_data),
.PCIe_wr_en(PCIe_wr_en), 
.PCIe_wr_busy(PCIe_wr_busy),
.PCIe_req_len(PCIe_req_len),
.PCIe_req_compl(PCIe_req_compl),
.trn_rbar_hit_n(trn_rbar_hit_n),
.start_req(start_req),
.rst_n(rst_n)	 
);
*/

/*
REGISTERS INTERFACE3 (
.reset(),
.clock(),
.BAR1(),
.read_enable(),
.write_enable(),
.bus_read(),
.bus_write(),
.channels_status(),
.channels_enable()
);
*/	

endmodule
