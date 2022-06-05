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
reg[31:0]  Addr_result;            // ����ALU,ΪALU���������ת��ַ
reg[31:0]  Read_data_1;           // ����Decoder��jrָ���õĵ�ַ
reg        Branch;                // ���Կ��Ƶ�Ԫ
reg        nBranch;               // ���Կ��Ƶ�Ԫ
reg        Jmp;                   // ���Կ��Ƶ�Ԫ
reg        Jal;                   // ���Կ��Ƶ�Ԫ
reg        Jr;                   // ���Կ��Ƶ�Ԫ
reg        Zero;                  //����ALU��ZeroΪ1��ʾ����ֵ��ȣ���֮��ʾ�����
reg        clock,reset;           //ʱ���븴λ,��λ�ź����ڸ�PC����ʼֵ����λ�źŸߵ�ƽ��Ч
wire[31:0] link_addr;             // JALָ��ר�õ�PC+4
wire[31:0] Instruction;            // ����PC��ֵ�Ӵ��ָ���prgrom��ȡ����ָ��
wire[31:0] branch_base_addr;      // ������������ת���ָ����ԣ���ֵΪ(pc+4)����ALU

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
