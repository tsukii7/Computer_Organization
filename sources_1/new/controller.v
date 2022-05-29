`timescale 1ns / 1ps

module ControllerIO(
input [5:0] Opcode,
input [5:0] Function_opcode,
output Jr,
output Jmp,
output Jal,
output Branch,
output nBranch,
output RegDST,
output MemtoReg,
output RegWrite,
output MemWrite,
output ALUSrc,
output I_format,
output Sftmd,
output[1:0] ALUOp,

// The real address of LW and SW is Alu_Result, the signal comes from the execution unit
// From the execution unit Alu_Result[31..10], used to help determine whether to process Mem or IO
input [21:0]Alu_resultHigh,

output MemorIOtoReg, // 1 indicates that data needs to be read from memory or I/O to the register
output MemRead, // 1 indicates that the instruction needs to read from the memory
output IORead, // 1 indicates I/O read
output IOWrite // 1 indicates I/O write
);


assign Jr =((Function_opcode==6'b001000)&&(Opcode==6'b000000)) ? 1'b1 : 1'b0;
assign Jmp = (Opcode==6'b000010) ? 1'b1 : 1'b0;
assign Jal = (Opcode==6'b000011) ? 1'b1 : 1'b0;
assign Branch = (Opcode==6'b000100) ? 1'b1 : 1'b0;
assign nBranch = (Opcode==6'b000101) ? 1'b1 : 1'b0;
assign RegDST = (Opcode==6'b000000)? 1'b1:1'b0;
assign MemtoReg = (Opcode==6'b100011)? 1'b1:1'b0;
assign RegWrite = (RegDST || Opcode == 6'b100011 || Jal || I_format) && !(Jr);
assign MemWrite = ((Opcode==6'b101011)&& (Alu_resultHigh[21:0] != 22'h3FFFFF))? 1'b1:1'b0;
assign MemRead = ((Opcode==6'b100011)&& (Alu_resultHigh[21:0] != 22'h3FFFFF))? 1'b1:1'b0;//Read memory
assign IORead = ((Opcode==6'b100011) && (Alu_resultHigh[21:0] == 22'h3FFFFF))? 1'b1:1'b0;//Read input port
assign IOWrite = ((Opcode==6'b101011) && (Alu_resultHigh[21:0] == 22'h3FFFFF))? 1'b1:1'b0;//Write output port

// Read operations require reading data from memory or I/O to write to the register
assign MemorIOtoReg = IORead || MemRead;

assign I_format = (Opcode[5:3]==3'b001)?1'b1:1'b0;
assign ALUSrc = ((I_format) || (Opcode == 6'b100011) || (Opcode == 6'b101011))? 1'b1:1'b0;
assign ALUOp = {(RegDST || I_format),(Branch || nBranch)};
assign Sftmd = (((Function_opcode==6'b000000)||(Function_opcode==6'b000010) ||(Function_opcode==6'b000011)||(Function_opcode==6'b000100) ||(Function_opcode==6'b000110)||(Function_opcode==6'b000111)) && RegDST)? 1'b1:1'b0;

endmodule