`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/05/20 09:13:41
// Design Name: 
// Module Name: controller
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


module control32(Opcode,Function_opcode,Jr,Branch,nBranch,Jmp,Jal, Alu_resultHigh, RegDST, MemorIOtoReg, RegWrite, MemRead, MemWrite, IORead, IOWrite, ALUSrc,ALUOp,Sftmd,I_format);
    input[5:0]   Opcode;            // 来自IFetch模块的指令高6bit, instruction[31..26]
    input[5:0]   Function_opcode;  	// 来自IFetch模块的指令低6bit, 用于区分r-类型中的指令, instructions[5..0]
    input[21:0]  Alu_resultHigh; // From the execution unit Alu_Result[31..10]
    output       Jr;         	 // 为1表明当前指令是jr, 为0表示当前指令不是jr
    output       RegDST;          // 为1表明目的寄存器是rd, 否则目的寄存器是rt
    output       ALUSrc;          // 为1表明第二个操作数（ALU中的Binput）是立即数（beq, bne除外）, 为0时表示第二个操作数来自寄存器
    output       MemorIOtoReg; // 1 indicates that data needs to be read from memory or I/O to the register
    output       RegWrite; // 1 indicates that the instruction needs to write to the register
    output       MemRead; // 1 indicates that the instruction needs to read from the memory
    output       MemWrite; // 1 indicates that the instruction needs to write to the memory
    output       IORead; // 1 indicates I/O read
    output       IOWrite; // 1 indicates I/O write
    output       Branch;        // 为1表明是beq指令, 为0时表示不是beq指令
    output       nBranch;       // 为1表明是Bne指令, 为0时表示不是bne指令
    output       Jmp;            // 为1表明是J指令, 为0时表示不是J指令
    output       Jal;            // 为1表明是Jal指令, 为0时表示不是Jal指令
    output       I_format;      // 为1表明该指令是除beq, bne, LW, SW之外的其他I-类型指令
    output       Sftmd;         // 为1表明是移位指令, 为0表明不是移位指令
    output[1:0]  ALUOp;        // 是R-类型或I_format=1时位1（高bit位）为1,  beq、bne指令则位0（低bit位）为1
    
    wire R_format, Lw, Sw;
    assign Lw = (Opcode==6'b100_011)?1'b1:1'b0;
    assign Sw = (Opcode==6'b101_011)?1'b1:1'b0;
    assign R_format = (Opcode==6'b000000)? 1'b1:1'b0;
    assign I_format = (Opcode[5:3]==3'b001)?1'b1:1'b0;
    assign Jr =((Opcode==6'b000000)&&(Function_opcode==6'b001000)) ? 1'b1 : 1'b0;
    assign RegDST = R_format;
    assign RegWrite = (R_format || Lw || Jal || I_format) &&!(Jr);
    assign ALUOp = {(R_format || I_format),(Branch || nBranch)};
    assign Sftmd = (((Function_opcode==6'b000000)||(Function_opcode==6'b000010)||
                    (Function_opcode==6'b000011)||(Function_opcode==6'b000100)||(Function_opcode==6'b000110)||
                    (Function_opcode==6'b000111))&& R_format)? 1'b1:1'b0;
    assign Branch = (Opcode==6'b000100)?1'b1:1'b0;
    assign nBranch = (Opcode==6'b000101)?1'b1:1'b0;
    assign ALUSrc = (R_format || Branch || nBranch || Jal || Jmp)? 1'b0:1'b1;
    
    // assign MemtoReg =  Lw ?1'b1:1'b0;
    // assign MemWrite =  Sw ?1'b1:1'b0;
    assign MemWrite = ( Sw && (Alu_resultHigh[21:0] != 22'h3FFFFF))? 1'b1:1'b0;
    assign MemRead = ( Lw && (Alu_resultHigh[21:0] != 22'h3FFFFF))? 1'b1:1'b0;//Read memory
    assign IORead = ( Lw  && (Alu_resultHigh[21:0] == 22'h3FFFFF))? 1'b1:1'b0;//Read input port
    assign IOWrite = ( Sw  && (Alu_resultHigh[21:0] == 22'h3FFFFF))? 1'b1:1'b0;//Write out put port
    // Read operations require reading data from memory or I/O to write to the register
    assign MemorIOtoReg = IORead || MemRead;

    assign Jmp = (Opcode==6'b000010)?1'b1:1'b0;
    assign Jal = (Opcode==6'b000011)?1'b1:1'b0;


    
endmodule
