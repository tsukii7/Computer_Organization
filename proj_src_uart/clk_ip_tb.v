`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/01 20:47:29
// Design Name: 
// Module Name: clk_ip_tb
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


module clk_ip_tb(  );
reg clk;
wire clock;



cpuclk cpuclk (
.clk_in1(clk),
.clk_out1(clock));


always #5 clk = ~clk;
initial begin
    clk = 1'b0;
  
    #3000 $finish;
end
endmodule
