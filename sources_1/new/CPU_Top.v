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
.Instruction(Instruction),          // ȡָ��Ԫ����ָ��
.mem_data(r_wdata),   				//  ��DATA RAM or I/O portȡ��������
.ALU_result(ALU_result),   			// ��ִ�е�Ԫ��������Ľ��
.Jal(Jal),                          //  ���Կ��Ƶ�Ԫ��˵����JALָ�� 
.RegWrite(RegWrite),                // ���Կ��Ƶ�Ԫ
.MemtoReg(MemorIOtoReg),                // ���Կ��Ƶ�Ԫ
.RegDst(RegDst),                    // ���Կ��Ƶ�Ԫ
.clock(clock),
.reset(rst),                        // ʱ�Ӻ͸�λ
.opcplus4(link_addr),               // ����ȡָ��Ԫ��JAL����
.Sign_extend(Sign_extend),          // ��չ���32λ������
.read_data_1(Read_data_1),          // ����ĵ�һ������
.read_data_2(Read_data_2)           // ����ĵڶ�������
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
.memWrite(MemWrite),    //����ֱ������idecode,�����ȴ�memorio�ﾭ��wdata���write_data
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