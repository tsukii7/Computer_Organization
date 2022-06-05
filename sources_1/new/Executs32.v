`timescale 1ns / 1ps

module executs32(Read_data_1,Read_data_2,Sign_extend,Function_opcode,Exe_opcode,ALUOp,
                Shamt,ALUSrc,I_format,Zero,Jr,Sftmd,ALU_Result,Addr_Result,PC_plus_4
                 );
    input[31:0]  Read_data_1;		// 从译码单元的Read_data_1中来
    input[31:0]  Read_data_2;		// 从译码单元的Read_data_2中来
    input[31:0]  Sign_extend;		// 从译码单元来的扩展后的立即数
    input[5:0]   Function_opcode;  	// 取指单元来的r-类型指令功能码,r-form instructions[5:0]
    input[5:0]   Exe_opcode;  		// 取指单元来的操作码
    input[1:0]   ALUOp;             // 来自控制单元的运算指令控制编码
    input[4:0]   Shamt;             // 来自取指单元的instruction[10:6]，指定移位次数
    input  		 Sftmd;             // 来自控制单元的，表明是移位指令
    input        ALUSrc;            // 来自控制单元，表明第二个操作数是立即数（beq，bne除外）
    input        I_format;          // 来自控制单元，表明是除beq, bne, LW, SW之外的I-类型指令
    input        Jr;                // 来自控制单元，表明是JR指令
    output       Zero;              // 为1表明计算值为0 
    output[31:0] ALU_Result;        // 计算的数据结果
    output[31:0] Addr_Result;		// 计算的地址结果        
    input[31:0]  PC_plus_4;         // 来自取指单元的PC+4

    wire[31:0] Ainput, Binput;      // 两个运算用的操作数
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