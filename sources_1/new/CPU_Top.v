`timescale 1ns / 1ps

module CPU_Top(
clk,
rst,
switch2N4,
led2N4);

input clk;
input rst;
input[23:0] switch2N4;
output wire [23:0]led2N4;
wire clock;

// iftech
wire [31:0]Instruction; 
wire [31:0]branch_base_addr, link_addr;
wire [31:0]Addr_result; 
wire [31:0]Read_data_1; 
wire Branch,nBranch,Jmp,Jal,Jr,Zero;

// decoder
wire [31:0] Read_data_2; 
wire [31:0] ALU_result;
wire [31:0] read_data;
wire RegWrite; 
wire RegDst; 
wire [31:0]Sign_extend;

// control
wire MemorIOtoReg; 
wire MemRead; 
wire MemWrite;
wire IORead;
wire IOWrite;
wire ALUSrc; 
wire I_format;
wire Sftmd;
wire [1:0]ALUOp;

// execute
wire [4:0]Shamt;

//MemOrIO
wire[31:0] write_data; 
wire[31:0] r_wdata; 
wire[31:0] address; 
wire [15:0]ioread_data;
wire LEDCtrl, SwitchCtrl;

//dmemory
wire[31:0] readData; 

/*
// switch
wire switchcs;

// led
wire ledcs;
*/

cpuclk cpuclk (
.clk_in1(clk),
.clk_out1(clock));


Ifetc32 ifetch(
.Instruction(Instruction),
.branch_base_addr(branch_base_addr),
.Addr_result(Addr_result),
.Read_data_1(Read_data_1),
.Branch(Branch),
.nBranch(nBranch),
.Jmp(Jmp),
.Jal(Jal),
.Jr(Jr),
.Zero(Zero),
.clock(clock),
.reset(rst),
.link_addr(link_addr)
);

decode32 decoder(
.Instruction(Instruction),          // 取指单元来的指令
.mem_data(r_wdata),   				//  从DATA RAM or I/O port取出的数据
.ALU_result(ALU_result),   			// 从执行单元来的运算的结果
.Jal(Jal),                          //  来自控制单元，说明是JAL指令 
.RegWrite(RegWrite),                // 来自控制单元
.MemtoReg(MemorIOtoReg),                // 来自控制单元
.RegDst(RegDst),                    // 来自控制单元
.clock(clock),
.reset(rst),                        // 时钟和复位
.opcplus4(link_addr),               // 来自取指单元，JAL中用
.Sign_extend(Sign_extend),          // 扩展后的32位立即数
.read_data_1(Read_data_1),          // 输出的第一操作数
.read_data_2(Read_data_2)           // 输出的第二操作数
); 


control32 control(
.Opcode(Instruction[31:26]),
.Function_opcode(Instruction[5:0]),
.Jr(Jr),
.Branch(Branch),
.nBranch(nBranch),
.Jmp(Jmp),
.Jal(Jal),
.Alu_resultHigh(ALU_result[31:10]),
.RegDST(RegDst),
.MemorIOtoReg(MemorIOtoReg),
.RegWrite(RegWrite),
.MemRead(MemRead),
.MemWrite(MemWrite),
.IORead(IORead),
.IOWrite(IOWrite),
.ALUSrc(ALUSrc),
.ALUOp(ALUOp),
.Sftmd(Sftmd),
.I_format(I_format)
);

executs32 execute(
.Read_data_1(Read_data_1),
.Read_data_2(Read_data_2),
.Sign_extend(Sign_extend),
.Function_opcode(Instruction[5:0]),    
.Exe_opcode(Instruction[31:26]),
.ALUOp(ALUOp),
.Shamt(Instruction[10:6]),    
.ALUSrc(ALUSrc),
.I_format(I_format),
.Zero(Zero),
.Jr(Jr),
.Sftmd(Sftmd),
.ALU_Result(ALU_result),    
.Addr_Result(Addr_result),
.PC_plus_4(branch_base_addr)
);


dmemory32 memory(
.readData(readData),
.address(address),
.writeData(write_data),
.memWrite(MemWrite),    //不是直接来自idecode,而是先从memorio里经过wdata变成write_data
.clock(clock)
);

MemOrIO memio(
.mRead(MemRead),
.mWrite(MemWrite),
.ioRead(IORead),
.ioWrite(IOWrite),
.addr_in(ALU_result),
.addr_out(address),
.m_rdata(readData),
.io_rdata(ioread_data),
.r_wdata(r_wdata),
.r_rdata(Read_data_2),
.write_data(write_data),
.LEDCtrl(LEDCtrl),
.SwitchCtrl(SwitchCtrl)
);

Switch switch24(
.switclk(clock),
.switrst(rst),
.switchread(IORead),
.switchcs(SwitchCtrl),
.switchaddr(address[1:0]),
.switchrdata(ioread_data),
.switch_i(switch2N4)
);

LED led24(
.led_clk(clock),
.ledrst(rst),
.ledwrite(IOWrite),
.ledcs(LEDCtrl),
.ledaddr(address[1:0]),
.ledwdata(write_data[15:0]),
.ledout(led2N4)
);

endmodule