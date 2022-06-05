`timescale 1ns / 1ps

module CPU_Top_uart(
fpga_clk,
fpga_rst,
start_pg,
switch2N4,
led2N4,
rx,
tx);

input fpga_clk;
input fpga_rst;
input start_pg;
input rx;
output tx;
input[23:0] switch2N4;
output wire [23:0]led2N4;
wire cpu_clk;
wire reset;

// UART Programmer Pinouts
 wire upg_clk, upg_clk_o;
 wire upg_wen_o; //Uart write out enable
 wire upg_wen_i; //Uart write in enable
 wire upg_done_o; //Uart rx data have done
 //data to which memory unit of program_rom/dmemory32
 wire [14:0] upg_adr_o;
 //data to program_rom or dmemory32
 wire [31:0] upg_dat_o;
 assign upg_wen_i = upg_wen_o & upg_adr_o[14];
 wire spg_bufg;
 BUFG U1(.I(start_pg), .O(spg_bufg));      // de-twitter
 // Generate UART Programmer reset signal reg upg_rst;
reg upg_rst;
 always @ (posedge fpga_clk) begin
 if (spg_bufg) upg_rst = 0;
 if (fpga_rst) upg_rst = 1;
 end

 assign reset = fpga_rst | !upg_rst;

// iftech
wire [31:0]Instruction_o;
wire [31:0]Instruction_i;
wire [31:0]branch_base_addr, link_addr;
wire [31:0]Addr_result; 
wire [31:0]Read_data_1; 
wire Branch,nBranch,Jmp,Jal,Jr,Zero;
wire[13:0] rom_adr_o;

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

// cpufpga_clk cpufpga_clk (
// .fpga_clk_in1(fpga_clk),
// .fpga_clk_out1(cpu_clk));

cpuclk clock(
.clk_in1(fpga_clk),
.clk_out1(cpu_clk),
.clk_out2(upg_clk));

Ifetc32_uart ifetch(
.Instruction_i(Instruction_i)
.Instruction_o(Instruction_o),
.rom_adr_o(rom_adr_o),
.branch_base_addr(branch_base_addr),
.Addr_result(Addr_result),
.Read_data_1(Read_data_1),
.Branch(Branch),
.nBranch(nBranch),
.Jmp(Jmp),
.Jal(Jal),
.Jr(Jr),
.Zero(Zero),
.clock(cpu_clk),
.reset(fpga_rst),
.link_addr(link_addr)
);

decode32 decoder(
.Instruction(Instruction_o),          // ȡָ��Ԫ����ָ��
.mem_data(r_wdata),   				//  ��DATA RAM or I/O portȡ��������
.ALU_result(ALU_result),   			// ��ִ�е�Ԫ��������Ľ��
.Jal(Jal),                          //  ���Կ��Ƶ�Ԫ��˵����JALָ�� 
.RegWrite(RegWrite),                // ���Կ��Ƶ�Ԫ
.MemtoReg(MemorIOtoReg),                // ���Կ��Ƶ�Ԫ
.RegDst(RegDst),                    // ���Կ��Ƶ�Ԫ
.clock(cpu_clk),
.reset(fpga_rst),                        // ʱ�Ӻ͸�λ
.opcplus4(link_addr),               // ����ȡָ��Ԫ��JAL����
.Sign_extend(Sign_extend),          // ��չ���32λ������
.read_data_1(Read_data_1),          // ����ĵ�һ������
.read_data_2(Read_data_2)           // ����ĵڶ�������
); 


control32 control(
.Opcode(Instruction_o[31:26]),
.Function_opcode(Instruction_o[5:0]),
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
.Function_opcode(Instruction_o[5:0]),    
.Exe_opcode(Instruction_o[31:26]),
.ALUOp(ALUOp),
.Shamt(Instruction_o[10:6]),    
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
.clock(cpu_clk),
.upg_rst_i(upg_rst),
.upg_clk_i(upg_clk), 
.upg_wen_i(upg_wen_i),
.upg_adr_i(upg_adr_o[13:0]),
.upg_dat_i(upg_dat_o),
.upg_done_i(upg_done_o)
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

ProgramROM_UART prgram32( 
.rom_clk_i(cpu_clk), 
.rom_adr_i(rom_adr_o), 
.upg_rst_i(upg_rst), 
.upg_clk_i(upg_clk), 
.upg_wen_i(upg_wen_i), 
.upg_dat_i(upg_dat_o),
.upg_done_i(upg_done_o), 
.Instruction_o(Instruction_i), 
.upg_adr_i(upg_adr_o[13:0])
);

Switch switch24(
.switfpga_clk(cpu_clk),
.switrst(fpga_rst),
.switchread(IORead),
.switchcs(SwitchCtrl),
.switchaddr(address[1:0]),
.switchrdata(ioread_data),
.switch_i(switch2N4)
);

LED led24(
.led_fpga_clk(cpu_clk),
.ledrst(fpga_rst),
.ledwrite(IOWrite),
.ledcs(LEDCtrl),
.ledaddr(address[1:0]),
.ledwdata(write_data[15:0]),
.ledout(led2N4)
);

endmodule