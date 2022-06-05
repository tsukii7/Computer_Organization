`timescale 1ns / 1ps

module executs32(Read_data_1,Read_data_2,Sign_extend,Function_opcode,Exe_opcode,ALUOp,
                Shamt,ALUSrc,I_format,Zero,Jr,Sftmd,ALU_Result,Addr_Result,PC_plus_4
                 );
    input[31:0]  Read_data_1;		// �����뵥Ԫ��Read_data_1����
    input[31:0]  Read_data_2;		// �����뵥Ԫ��Read_data_2����
    input[31:0]  Sign_extend;		// �����뵥Ԫ������չ���������
    input[5:0]   Function_opcode;  	// ȡָ��Ԫ����r-����ָ�����,r-form instructions[5:0]
    input[5:0]   Exe_opcode;  		// ȡָ��Ԫ���Ĳ�����
    input[1:0]   ALUOp;             // ���Կ��Ƶ�Ԫ������ָ����Ʊ���
    input[4:0]   Shamt;             // ����ȡָ��Ԫ��instruction[10:6]��ָ����λ����
    input  		 Sftmd;             // ���Կ��Ƶ�Ԫ�ģ���������λָ��
    input        ALUSrc;            // ���Կ��Ƶ�Ԫ�������ڶ�������������������beq��bne���⣩
    input        I_format;          // ���Կ��Ƶ�Ԫ�������ǳ�beq, bne, LW, SW֮���I-����ָ��
    input        Jr;                // ���Կ��Ƶ�Ԫ��������JRָ��
    output       Zero;              // Ϊ1��������ֵΪ0 
    output[31:0] ALU_Result;        // ��������ݽ��
    output[31:0] Addr_Result;		// ����ĵ�ַ���        
    input[31:0]  PC_plus_4;         // ����ȡָ��Ԫ��PC+4

    wire[31:0] Ainput, Binput;      // ���������õĲ�����
    wire[5:0] Exe_code;             // use to generate ALU_ctrl. (I_format==0) ? Function_opcode : { 3'b000 , Opcode[2:0] };
    wire[2:0] ALU_ctl;              // the control signals which affact operation in ALU directely
    wire[2:0] Sftm;                 // identify the types of shift instruction, equals to Function_opcode[2:0]
    reg[31:0] Shift_Result;         // the result of shift operation
    reg[31:0] ALU_output_mux;       // the result of arithmetic or logic calculation
    wire[32:0] Branch_Addr;         // the calculated address of the instruction, Addr_Result is Branch_Addr[31:0]

    assign Ainput = Read_data_1;
    assign Binput = (ALUSrc==0)?Read_data_2:Sign_extend[31:0];
    assign Exe_code = (I_format==0) ? Function_opcode :{ 3'b000 , Exe_opcode[2:0]};
    assign ALU_ctl[0] = (Exe_code[0] | Exe_code[3]) & ALUOp[1]; 
    assign ALU_ctl[1] = ((!Exe_code[2]) | (!ALUOp[1]));
    assign ALU_ctl[2] = (Exe_code[1] & ALUOp[1]) | ALUOp[0];


    assign Zero = (ALU_output_mux[31:0] == 32'h00000000) ? 1'b1 : 1'b0;
    
    assign Addr_Result = $signed(PC_plus_4) + $signed(Sign_extend << 2);  
    always @(ALU_ctl or Ainput or Binput)begin
        case(ALU_ctl)
            3'b000: begin ALU_output_mux = Ainput & Binput; 
            end

            3'b001: begin ALU_output_mux = Ainput | Binput; 
            end

            3'b010: begin ALU_output_mux = $signed(Ainput) + $signed(Binput); 
            end

            3'b011: begin ALU_output_mux = Ainput + Binput; 
            end

            3'b100: begin ALU_output_mux = Ainput ^ Binput; 
            end

            3'b101: begin
                ALU_output_mux = ~(Ainput|Binput); 
            end

            3'b110: begin 
                ALU_output_mux = Ainput - Binput;
            end

            3'b111: begin 
                ALU_output_mux = Ainput - Binput;
            end
            default: begin ALU_output_mux = 32'h0000_0000;
            end
        endcase
        
    end

    assign Sftm = Function_opcode[2:0];
    always @(*)begin
        if(Sftmd)
            case(Sftm[2:0])
            3'b000:Shift_Result = $signed(Binput) << Shamt;
            3'b010:Shift_Result = $signed(Binput) >> Shamt;
            3'b100:Shift_Result = $signed(Binput) << Ainput;
            3'b110:Shift_Result = $signed(Binput) >> Ainput;
            3'b011:Shift_Result = $signed(Binput) >>> Shamt;
            3'b111:Shift_Result = $signed(Binput) >>> Ainput;
            default:Shift_Result = Binput;
            endcase
    end
    
    reg[31:0] middle;
    assign ALU_Result = middle;
    always @(*) begin
        // set type operation (slt slti sltu sltiu)
        if(((ALU_ctl==3'b111) && (Exe_code[3]==1)) || ((ALU_ctl[2:1]==2'b11) && (I_format==1)))
            middle = ALU_output_mux[31]==1? 1:0;
        else if((ALU_ctl==3'b101) && (I_format==1))
            middle = Binput;  // lui
        else if(Sftmd == 1)
            middle = Shift_Result;
        else 
            middle = ALU_output_mux[31:0];
    end
endmodule