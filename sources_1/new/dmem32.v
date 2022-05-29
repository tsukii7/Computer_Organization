`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/04/21 08:29:13
// Design Name: 
// Module Name: dmem32
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


module dmem32(readData, address,writeData,memWrite,clock);
    input clock; //Clock signal
    input memWrite;
    input [31 : 0] address;
    input [31 : 0] writeData;
    output [31 : 0] readData;
    // Part of dmemory32 module
    //Create a instance of RAM(IP core), binding the ports
    RAM ram (
    .clka(clk), // input wire clka
    .wea(memWrite), // input wire [0 : 0] wea
    .addra(address[15:2]), // input wire [13 : 0] addra
    .dina(writeData), // input wire [31 : 0] dina
    .douta(readData) // output wire [31 : 0] douta
    );
    /*The clock is from CPU-TOP, suppose its one edge has been used at the upstream module of data memory, suchas IFetch, Why Data-Memroy DO NOT use the same edge as other module ? */
    assign clk = !clock;
endmodule
