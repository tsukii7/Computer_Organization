`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/01 17:42:48
// Design Name: 
// Module Name: ezcpu_tb
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


module ezcpu_tb();
reg clk;
reg[23:0] switch;
wire[23:0] led;
reg reset;
CPU_Top cpu_test( 
clk,
reset,
switch,
led);
initial begin
    clk = 0;
    reset = 0;
    switch = 24'h00_2436;
    #3000 reset = 1;
    #10 reset = 0;  
    #10 switch = 24'h00_3253;
  
    #100 switch = 24'h07_3253;
    #100 switch = 24'h0f_ffff;
end

always #5 clk = ~clk;
endmodule
