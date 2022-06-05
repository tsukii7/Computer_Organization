`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/20 12:49:28
// Design Name: 
// Module Name: decoder32
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


module decode32(read_data_1,read_data_2,Instruction,mem_data,ALU_result,
                 Jal,RegWrite,MemtoReg,RegDst,Sign_extend,clock,reset,opcplus4);
    input[31:0]  Instruction;               // 取指单元来的指令
    input[31:0]  mem_data;   				//  从DATA RAM or I/O port取出的数据
    input[31:0]  ALU_result;   				// 从执行单元来的运算的结果
    input        Jal;                       //  来自控制单元，说明是JAL指令 
    input        RegWrite;                  // 来自控制单元
    input        MemtoReg;              // 来自控制单元
    input        RegDst;             
    input		 clock,reset;                // 时钟和复位
    input[31:0]  opcplus4;                 // 来自取指单元，JAL中用
    output[31:0] Sign_extend;               // 扩展后的32位立即数
    output[31:0] read_data_1;               // 输出的第一操作数
    output[31:0] read_data_2;               // 输出的第二操作数

wire [4:0] read_register_1, read_register_2, write_register; 
wire [31:0] WriteData;
reg [31:0] extend_data;
reg [31:0] register[0:31];

assign Sign_extend = extend_data;
assign read_register_1 = Instruction[25:21];
assign read_register_2 = Instruction[20:16];
assign read_data_1 = register[read_register_1];
assign read_data_2 = register[read_register_2];
assign write_register = (RegDst)? Instruction[15:11]:Instruction[20:16];
assign WriteData = (MemtoReg)? mem_data:ALU_result;

integer i;
always @(posedge clock) begin
    if(reset) begin
        for(i = 0; i < 32; i=i+1)begin
            register[i] <= 0;
        end
    end 
    else begin
        if (RegWrite) begin
            if(Jal)
                register[31] <= opcplus4;
            else if(write_register != 0)
                register[write_register] <= WriteData;
        end
    end
end

always@(*) begin
    if(Instruction[31:26] != 6'b000000 && Instruction[31:26] != 6'b000010 
        && Instruction[31:26] != 6'b000011) begin
            if(Instruction[31:26] == 6'b001111)
                extend_data = {Instruction[15:0],16'b0};
            else if(Instruction[31:26] == 6'b001001 || Instruction[31:26] == 6'b001011 || Instruction[31:26] == 6'b001111 ||
               Instruction[31:26] == 6'b001100 || Instruction[31:26] == 6'b001101  || Instruction[31:26] == 6'b001110)
                extend_data = {16'b0,Instruction[15:0]};
            else begin
                if(Instruction[15]==1'b1)
                    extend_data = {{16{1'b1}},Instruction[15:0]};
                else
                    extend_data = {16'b0,Instruction[15:0]};
            end
        end
    else begin
        extend_data = {16'b0,Instruction[15:0]};
    end
end

endmodule