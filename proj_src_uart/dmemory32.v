`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/01 17:54:43
// Design Name: 
// Module Name: dmemory32
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


module dmemory32(readData, address,writeData,memWrite,clock,upg_rst_i,upg_clk_i,upg_wen_i,upg_adr_i,upg_dat_i,upg_done_i);
    input clock; //Clock signal
    input memWrite;
    input [31 : 0] address;
    input [31 : 0] writeData;
    output [31 : 0] readData;
    input upg_rst_i; // UPG reset (Active High)
    input upg_clk_i; // UPG ram_clk_i (10MHz)
    input upg_wen_i; // UPG write enable
    input [13:0] upg_adr_i; // UPG write address
    input [31:0] upg_dat_i; // UPG write data
    input upg_done_i; // 1 if programming is finished

    wire clk;
    wire kickOff = upg_rst_i | (~upg_rst_i & upg_done_i);

    // Part of dmemory32 module
    //Create a instance of RAM(IP core), binding the ports

    // RAM ram (
    // .clka(clk), // input wire clka
    // .wea(memWrite), // input wire [0 : 0] wea
    // .addra(address[15:2]), // input wire [13 : 0] addra
    // .dina(writeData), // input wire [31 : 0] dina
    // .douta(readData) // output wire [31 : 0] douta
    // );
        RAM ram (
    .clka (kickOff ? clk : upg_clk_i),
    .wea (kickOff ? memWrite : upg_wen_i),
    .addra (kickOff ? address[15:2] : upg_adr_i),
    .dina (kickOff ? writeData : upg_dat_i),
    .douta (readData)
    );
    /*The clock is from CPU-TOP, suppose its one edge has been used at the upstream module of data memory, suchas IFetch, Why Data-Memroy DO NOT use the same edge as other module ? */
    assign clk = !clock;
endmodule
