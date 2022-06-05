`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/01 13:57:57
// Design Name: 
// Module Name: ramTb
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


//The testbench module for dmemory32
module ramTb( );
reg clock = 1'b0;
reg memWrite = 1'b0;
reg [31:0] addr = 32'h0000_0000;
reg [31:0] writeData = 32'ha000_0000;
wire [31:0] readData;
dmemory32 uram
(readData, addr,writeData,memWrite,clock);
always #50 clock = ~clock;
always #100 addr = addr + 3'b100;
initial fork
#1200 memWrite = 1'b1;
#100
writeData = 32'h0000_00f5;
#200
memWrite = 1'b0;
// ... to be completed
join
endmodule
