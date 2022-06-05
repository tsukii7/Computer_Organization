`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/06/01 18:15:56
// Design Name: 
// Module Name: Ifetc32_tb
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


module Ifetc32_tb( );
reg[31:0]  Addr_result;            // 来自ALU,为ALU计算出的跳转地址
reg[31:0]  Read_data_1;           // 来自Decoder，jr指令用的地址
reg        Branch;                // 来自控制单元
reg        nBranch;               // 来自控制单元
reg        Jmp;                   // 来自控制单元
reg        Jal;                   // 来自控制单元
reg        Jr;                   // 来自控制单元
reg        Zero;                  //来自ALU，Zero为1表示两个值相等，反之表示不相等
reg        clock,reset;           //时钟与复位,复位信号用于给PC赋初始值，复位信号高电平有效
wire[31:0] link_addr;             // JAL指令专用的PC+4
wire[31:0] Instruction;            // 根据PC的值从存放指令的prgrom中取出的指令
wire[31:0] branch_base_addr;      // 对于有条件跳转类的指令而言，该值为(pc+4)送往ALU

Ifetc32 ifetch(
.Addr_result(Addr_result),.Read_data_1(Read_data_1),.Branch(Branch),.nBranch(nBranch),.Jmp(Jmp),
.Jal(Jal),.Jr(Jr),.Zero(Zero),.clock(clock),.reset(reset),.link_addr(link_addr),.Instruction(Instruction),
.branch_base_addr(branch_base_addr)
);

always #5 clock = ~clock;
initial begin
    clock = 1'b0;
    Addr_result = 0;
    Read_data_1 = 0;
    Branch = 0;
    nBranch = 0;
    Jmp = 0;
    Jal = 0;
    Jr = 0;
    Zero = 0;
    reset = 1'b0;
    #10 reset = 1'b1;
    #10 reset = 1'b0;
    // repeat(5) begin
    // #10 PC = PC+4;
    #1000 $finish;
end


endmodule
