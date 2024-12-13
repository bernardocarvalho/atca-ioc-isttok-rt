//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Company: INSTITUTO DOS PLASMAS E FUSAO NUCLEAR
// Engineer: AJNB
//
// Project Name:   JET PLASMA VS CONTROLLER
// Design Name:    ATCA-GPIO-CONTROL FIRMWARE
// Module Name:    REGISTERS
// Target Devices: XC4VFX60-11FF1152 or XC4VFX100-11FF1152
//
// Revision: Final 2
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns / 1ps

module REGISTERS(
reset,
clock,
BAR1,
read_enable,
write_enable,
bus_read,
bus_write,
channels_status,
channels_enable
);

input reset;
input clock;
input [31:0] BAR1;
input read_enable;
input write_enable;
output reg [31:0] bus_read;
input [31:0] bus_write;
input [31:0] channels_status;
output [31:0] channels_enable;

channels_enable REGISTER1 (
.ainit(reset),
.ce(write_enable),
.clk(clock),
.d(bus_write),
.q(channels_enable)
);

always @ (posedge clock)
begin
 if(read_enable == 1)
  if(BAR1[0] == 1)
   bus_read <= channels_status;
  else if(BAR1[1] == 1)
   bus_read <= channels_enable;
  else if(BAR1[2] == 1)
   bus_read <= channels_status;
  else if(BAR1[3] == 1)
   bus_read <= channels_status;
  else if(BAR1[4] == 1)
   bus_read <= channels_status;
  else if(BAR1[5] == 1)
   bus_read <= channels_status;
  else if(BAR1[6] == 1)
   bus_read <= channels_status;
  else if(BAR1[7] == 1)
   bus_read <= channels_status;
  else if(BAR1[8] == 1)
   bus_read <= channels_status;
  else if(BAR1[9] == 1)
   bus_read <= channels_status;
  else if(BAR1[10] == 1)
   bus_read <= channels_status;
  else if(BAR1[11] == 1)
   bus_read <= channels_status;
  else if(BAR1[12] == 1)
   bus_read <= channels_status;
  else if(BAR1[13] == 1)
   bus_read <= channels_status;
  else if(BAR1[14] == 1)
   bus_read <= channels_status;
  else if(BAR1[15] == 1)
   bus_read <= channels_status;
  else if(BAR1[16] == 1)
   bus_read <= channels_status;
  else if(BAR1[17] == 1)
   bus_read <= channels_status;
  else if(BAR1[18] == 1)
   bus_read <= channels_status;
  else if(BAR1[19] == 1)
   bus_read <= channels_status;
  else if(BAR1[20] == 1)
   bus_read <= channels_status;
  else if(BAR1[21] == 1)
   bus_read <= channels_status;
  else if(BAR1[22] == 1)
   bus_read <= channels_status;
  else if(BAR1[23] == 1)
   bus_read <= channels_status;
  else if(BAR1[24] == 1)
   bus_read <= channels_status;
  else if(BAR1[25] == 1)
   bus_read <= channels_status;
  else if(BAR1[26] == 1)
   bus_read <= channels_status;
  else if(BAR1[27] == 1)
   bus_read <= channels_status;
  else if(BAR1[28] == 1)
   bus_read <= channels_status;
  else if(BAR1[29] == 1)
   bus_read <= channels_status;
  else if(BAR1[30] == 1)
   bus_read <= channels_status;
  else if(BAR1[31] == 1)
   bus_read <= channels_status;
 else  
  bus_read <= 32'hZZZZZZZZ;
end  
endmodule
