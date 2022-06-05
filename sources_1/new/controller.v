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
    input[5:0]   Opcode;            // ����IFetchģ���ָ���6bit, instruction[31..26]
    input[5:0]   Function_opcode;  	// ����IFetchģ���ָ���6bit, ��������r-�����е�ָ��, instructions[5..0]
    input[21:0]  Alu_resultHigh; // From the execution unit Alu_Result[31..10]
    output       Jr;         	 // Ϊ1������ǰָ����jr, Ϊ0��ʾ��ǰָ���jr
    output       RegDST;          // Ϊ1����Ŀ�ļĴ�����rd, ����Ŀ�ļĴ�����rt
    output       ALUSrc;          // Ϊ1�����ڶ�����������ALU�е�Binput������������beq, bne���⣩, Ϊ0ʱ��ʾ�ڶ������������ԼĴ���
    output       MemorIOtoReg; // 1 indicates that data needs to be read from memory or I/O to the register
    output       RegWrite; // 1 indicates that the instruction needs to write to the register
    output       MemRead; // 1 indicates that the instruction needs to read from the memory
    output       MemWrite; // 1 indicates that the instruction needs to write to the memory
    output       IORead; // 1 indicates I/O read
    output       IOWrite; // 1 indicates I/O write
    output       Branch;        // Ϊ1������beqָ��, Ϊ0ʱ��ʾ����beqָ��
    output       nBranch;       // Ϊ1������Bneָ��, Ϊ0ʱ��ʾ����bneָ��
    output       Jmp;            // Ϊ1������Jָ��, Ϊ0ʱ��ʾ����Jָ��
    output       Jal;            // Ϊ1������Jalָ��, Ϊ0ʱ��ʾ����Jalָ��
    output       I_format;      // Ϊ1������ָ���ǳ�beq, bne, LW, SW֮�������I-����ָ��
    output       Sftmd;         // Ϊ1��������λָ��, Ϊ0����������λָ��
    output[1:0]  ALUOp;        // ��R-���ͻ�I_format=1ʱλ1����bitλ��Ϊ1,  beq��bneָ����λ0����bitλ��Ϊ1
    
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
