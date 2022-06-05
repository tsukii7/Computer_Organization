`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/05/20 21:25:43
// Design Name: 
// Module Name: cpu_test
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


module cpu_tb(

    );
    reg clk;
    reg[23:0] switch;
    wire[23:0] led;
    reg reset;
    reg start_pg;
    reg rx;
    wire tx;
    
    CPU_UART cpu(.fpga_clk(clk), .switch2N4(switch), .led2N4(led), .fpga_rst(reset), .start_pg(start_pg), .rx(rx), .tx(tx));
    
    initial begin
        clk = 0;
        reset = 0;
        start_pg = 0;
        rx = 1;
        switch = 22'h00_0000;
        #25000 reset=1;
        #5000 reset=0;
        #10000 switch = 22'h00_2a03;
        #5000 switch = 22'h01_2a03;
        #5000 switch = 22'h02_2a03;
        #5000 switch = 22'h03_2a03;
        #5000 switch = 22'h04_2a03;
        #5000 switch = 22'h05_2a03;
        #5000 switch = 22'h06_2a03;
        #5000 switch = 22'h07_2a03;
//        #1 reset = 0;
    end
    
    always #43 clk = ~clk;

endmodule
