`timescale 1ns / 1ps


module Ifetc32_uart(Instruction_o,Instruction_i,rom_adr_o,branch_base_addr,Addr_result,Read_data_1,Branch,nBranch,Jmp,Jal,Jr,Zero,clock,reset,link_addr);
    input[31:0] Instruction_i;
    input[31:0]  Addr_result;            // ����ALU,ΪALU���������ת��ַ
    input[31:0]  Read_data_1;           // ����Decoder��jrָ���õĵ�ַ
    input        Branch;                // ���Կ��Ƶ�Ԫ
    input        nBranch;               // ���Կ��Ƶ�Ԫ
    input        Jmp;                   // ���Կ��Ƶ�Ԫ
    input        Jal;                   // ���Կ��Ƶ�Ԫ
    input        Jr;                   // ���Կ��Ƶ�Ԫ
    input        Zero;                  //����ALU��ZeroΪ1��ʾ����ֵ��ȣ���֮��ʾ�����
    input        clock,reset; 
    output[13:0] rom_adr_o;
    output[31:0] link_addr;             // JALָ��ר�õ�PC+4
    output[31:0] Instruction_o;			// ����PC��ֵ�Ӵ��ָ���prgrom��ȡ����ָ��
    output[31:0] branch_base_addr;      // ������������ת���ָ����ԣ���ֵΪ(pc+4)����ALU

// prgrom instmem(
// .clka(clock),
// .addra(PC[15:2]),
// .douta(Instruction)
// );

reg[31:0] PC, Next_PC;
reg[31:0] link_address;
assign link_addr = link_address; // combinational or sequential?
assign branch_base_addr = PC+3'b100;
assign rom_adr_o = PC[15:2];
assign Instruction_o = Instruction_i;


always @* begin
    if(((Branch == 1) && (Zero == 1 )) || ((nBranch == 1) && (Zero == 0))) // beq, bne
    begin
        // branch_base_address = PC+3'b100;
        Next_PC = Addr_result; // the calculated new value for PC
    end
    else begin
        if(Jr == 1)
        Next_PC = Read_data_1; // the value of $31 register
        else Next_PC = PC+3'b100; // PC+4
    end
end

always @(negedge clock) begin
    if(reset == 1) begin
        PC <= 32'h0000_0000;
        link_address <= 3'b100;
        // branch_base_address <= 3'b100;
    end
    else if(Jal == 1) begin
            link_address <= PC+3'b100;
            PC <= {link_addr[31:28],Instruction_o[25:0],2'b00};
        end
    else begin
        if((Jmp == 1)) begin
            PC <= {link_addr[31:28],Instruction_o[25:0],2'b00};
        end
        else PC <= Next_PC;
    end
end


endmodule