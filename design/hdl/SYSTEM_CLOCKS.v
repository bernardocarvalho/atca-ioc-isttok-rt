//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company: INSTITUTO DOS PLASMAS E FUSAO NUCLEAR
// Engineer: AJNB
//
// Project Name:   JET PLASMA VS CONTROLLER
// Design Name:    ATCA-GPIO-CONTROL FIRMWARE
// Module Name:    SYSTEM_CLOCKS
// Target Devices: XC4VFX60-11FF1152 or XC4VFX100-11FF1152
//
// Revision: Final2_f
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module SYSTEM_CLOCKS (
input clock_33MHz,
input ATCA_clk_2MHz,
input PLL_clk_40MHz,
input AD9511_status,
output internal_clk_4MHz125,
output internal_clk_40MHz,
output reg ADCs_start_conv,
output reg ADCs_start_conv_out,
/********************************/
input RTM_clk_2MHz,
input ATCA_clk_40MHz,
output DCM_locked,
output internal_clk_2MHz
);

PMCD #(
.EN_REL("FALSE"), // TRUE/FALSE to allow synchronous deassertion of RST ????????????
.RST_DEASSERT_CLK("CLKA") // Reset syncronization to which clock: CLKA, CLKB, CLKC or CLKD
) AD9511_CLK (
//.CLKA1(CLKA1), // Output CLKA divided by 1
//.CLKA1D2(internal_clk_16MHz5/ Output CLKA divided by 2
//.CLKA1D4(internal_clk_8MHz25), // Output CLKA divided by 4
.CLKA1D8(internal_clk_4MHz125), // Output CLKA divided by 8
//.CLKB1(CLKB1), // Output phase matched CLKB
//.CLKC1(CLKC1), // Output phase matched CLKC
//.CLKD1(CLKD1), // Output phase matched CLKD
.CLKA(clock_33MHz), // Input CLKA
//.CLKB(CLKB), // Input CLKB
//.CLKC(CLKC), // Input CLKC
//.CLKD(CLKD), // Input CLKD
.REL(1), // PCMD release input
.RST(0) // Active high reset input
);

/*assign internal_clk_40MHz = PLL_clk_40MHz;

reg [4:0] counter;
reg start_conv;
always @ (posedge internal_clk_40MHz)
begin
 counter <= counter + 1;
 if(counter == 19)
  begin
   counter <= 0; 
   start_conv <= 1;
  end	
 else
  start_conv <= 0;
end  

reg ATCA_clk_2MHz_reg;
always @ (posedge internal_clk_40MHz)
begin
 if(AD9511_status == 1)
  begin
   ATCA_clk_2MHz_reg <= ATCA_clk_2MHz;
   ADCs_start_conv <= ~ATCA_clk_2MHz_reg & ATCA_clk_2MHz;
  end
 else
  ADCs_start_conv <= start_conv;
end  

reg ADCs_start_conv_delay;
always @ (posedge internal_clk_40MHz)
begin
 ADCs_start_conv_delay <= ADCs_start_conv;
 ADCs_start_conv_out <= ~ADCs_start_conv_delay;
end*/


wire clock_40MHz;
DCM_BASE #(
.CLKDV_DIVIDE(10.0), // Divide by: 1.5,2.0,2.5,3.0,3.5,4.0,4.5,5.0,5.5,6.0,6.5,7.0,7.5,8.0,9.0,10.0,11.0,12.0,13.0,14.0,15.0 or 16.0
.CLKFX_DIVIDE(1), // Can be any integer from 1 to 32
.CLKFX_MULTIPLY(20), // Can be any integer from 2 to 32
.CLKIN_DIVIDE_BY_2("FALSE"), // TRUE/FALSE to enable CLKIN divide by two feature
.CLKIN_PERIOD(500), // Specify period of input clock in ns from 1.25 to 1000.00
.CLKOUT_PHASE_SHIFT("NONE"), // Specify phase shift mode of NONE or FIXED
.CLK_FEEDBACK("NONE"), // Specify clock feedback of NONE, 1X or 2X
.DCM_PERFORMANCE_MODE("MAX_RANGE"), // Can be MAX_SPEED or MAX_RANGE
.DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), // SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or an integer from 0 to 15
.DFS_FREQUENCY_MODE("LOW"), // LOW or HIGH frequency mode for frequency synthesis
.DLL_FREQUENCY_MODE("LOW"), // LOW, HIGH, or HIGH_SER frequency mode for DLL
.DUTY_CYCLE_CORRECTION("TRUE"), // Duty cycle correction, TRUE or FALSE
.FACTORY_JF(16'hf0f0), // FACTORY JF value suggested to be set to 16'hf0f0
.PHASE_SHIFT(0), // Amount of fixed phase shift from -255 to 1023
.STARTUP_WAIT("FALSE") // Delay configuration DONE until DCM LOCK, TRUE/FALSE
) RTM_CLK (
.CLK0(), // 0 degree DCM CLK output
.CLK180(), // 180 degree DCM CLK output
.CLK270(), // 270 degree DCM CLK output
.CLK2X(), // 2X DCM CLK output
.CLK2X180(), // 2X, 180 degree DCM CLK out
.CLK90(), // 90 degree DCM CLK output
.CLKDV(), // Divided DCM CLK out (CLKDV_DIVIDE)
.CLKFX(clock_40MHz), // DCM CLK synthesis out (M/D)
.CLKFX180(), // 180 degree CLK synthesis out
.LOCKED(DCM_locked), // DCM LOCK status output
.CLKFB(), // DCM clock feedback
.CLKIN(RTM_clk_2MHz), // Clock input (from IBUFG, BUFG or DCM)
.RST(0) // DCM asynchronous reset input
);

reg [4:0] counter;
reg clock_2MHz;
always @ (posedge PLL_clk_40MHz)
begin
 counter <= counter + 1;
 if(counter == 19)
  begin
   counter <= 0; 
   clock_2MHz <= 1;
  end	
 else
  if(counter == 9)
   clock_2MHz <= 0;
end  

assign internal_clk_2MHz = (RTM_clk_2MHz & DCM_locked) | (clock_2MHz & ~DCM_locked);
assign internal_clk_40MHz = (PLL_clk_40MHz & ~DCM_locked) | (clock_40MHz & DCM_locked);

reg [1:0] ATCA_clk_2MHz_reg;
reg ADCs_start_conv_delay;
always @ (posedge ATCA_clk_40MHz)
begin
 ATCA_clk_2MHz_reg[0] <= ATCA_clk_2MHz;
 ATCA_clk_2MHz_reg[1] <= ATCA_clk_2MHz_reg[0];
 ADCs_start_conv <= ~ATCA_clk_2MHz_reg[1] & ATCA_clk_2MHz;
 ADCs_start_conv_delay <= ADCs_start_conv;
 ADCs_start_conv_out <= ~ADCs_start_conv_delay;
end


endmodule
	 