`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/06/02 05:59:16
// Design Name: 
// Module Name: cpu_test1_tb
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


module cpu_test1_tb();
reg clk;
reg[23:0] switch;
wire[23:0] led;
reg reset;
CPU_Top cpu_test( 
clk,
reset,
switch,
led);

wire art;
assign art = $signed(3'b101) >>> 1'b1;
initial begin
    clk = 0;
    reset = 0;
    switch = 24'h0;
    #3000 reset = 1;
    #10 reset = 0;  
   // #10 switch = 24'hf0_0fff;
   // #10 switch = 24'hb0_0001;
    /*
    #10 switch = 24'hf0_0000;
    #100 switch = 24'hf0_0fff;
    #100 switch = 24'he0_00ff;
    #100 switch = 24'hf0_0001;
    #100 switch = 24'he0_0001;
    #100 switch = 24'he0_0000;*/

    #10 switch = 24'hf0_1010;
    #100 switch = 24'hf8_1010;
    #100 switch = 24'hfc_0001;
    
/*
    #100 switch = 24'hf0_0001;
    #100 switch = 24'he0_0001;
    #100 switch = 24'hf0_0001;
    #100 switch = 24'he0_0001;    */
end

always #1 clk = ~clk;
endmodule

