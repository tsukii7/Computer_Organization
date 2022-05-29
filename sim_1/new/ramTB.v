`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/21 08:33:32
// Design Name: 
// Module Name: ramTB
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ramTB( );
//The testbench module for dmemory32
reg clock = 1'b0;
reg memWrite = 1'b0;
reg [31:0] addr = 32'h0000_0010;
reg [31:0] writeData = 32'ha000_0000;
wire [31:0] readData;
dmem32 uram
(readData,addr,writeData,memWrite,clock);
always #50 clock = ~clock;
initial fork
#120 memWrite = 1'b1;
#200
writeData = 32'h0000_00f5;
#400
memWrite = 1'b0;
// ... to be completed
join
endmodule
