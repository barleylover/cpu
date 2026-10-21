`include "opcodes.v"

module ControlUnit (
    // DEFINE THE INTERFACE OF THE CONTROL UNIT HERE
    input [15:0] rd_inst,
    input [1:0] rs_data, rt_data,
    
    output reg RegDst, Jump, Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite,
    output reg [3:0] ALUOp,
    output reg isWWD, isORI, isLHI, bcond
);

// ADD YOUR CODE HERE
    reg [5:0] funct;
    reg [3:0] opcode;
    always @(*) begin
        funct = rd_inst[5:0];
        opcode = rd_inst[15:12];
        RegDst = 0;
        Jump = 0;
        Branch = 0;
        MemRead = 0;
        MemtoReg = 0;
        ALUOp = `ALU_OP_ADD;
        MemWrite = 0;
        ALUSrc = 0;
        RegWrite = 0;
        isWWD = 0;
        isLHI = 0;
        isORI = 0;
        bcond = 0;
        case(opcode)
            `OPCODE_ADI : begin
                ALUOp = `ALU_OP_ADD;
                ALUSrc = 1;
                RegWrite = 1;
            end
            `OPCODE_ORI :  begin 
                ALUOp = `ALU_OP_OR;
                ALUSrc = 1;
                RegWrite = 1; 
                isORI = 1;
            end
            `OPCODE_LHI :   begin
                ALUOp = `ALU_OP_ID;
                ALUSrc = 1;
                RegWrite = 1;
                isLHI = 1;
            end
            `OPCODE_LWD :   begin
                MemRead = 1;
                MemtoReg = 1;  //register에 메모리값 전달
                ALUSrc = 1;
                RegWrite = 1;
            end
            `OPCODE_SWD :   begin
                MemWrite = 1;
                ALUSrc = 1;
            end
            `OPCODE_BNE :   begin
                Branch = 1;
                bcond = (rs_data==rt_data)? 0 : 1;
            end
            `OPCODE_BEQ :   begin
                Branch = 1;
                bcond = (rs_data==rt_data)? 1 : 0;
            end
            `OPCODE_BGZ :   begin
                Branch = 1;
                bcond = (rs_data>0)? 1:0;
            end
            `OPCODE_BLZ :   begin
                Branch = 1;
                bcond = ($signed(rs_data)<0)? 1:0;
            end
            `OPCODE_JMP :   begin
                Jump = 1;
            end
            `OPCODE_JAL :   begin
                Jump = 1;
            end
            `OPCODE_RTYPE : begin
                RegDst = 1;
                MemtoReg = 0;  //alu 연산 결과 전달
                RegWrite = 1; 
                case(funct)
                    `FUNC_ADD : ALUOp = `ALU_OP_ADD;
                    `FUNC_SUB : ALUOp = `ALU_OP_SUB;
                    `FUNC_AND : ALUOp = `ALU_OP_AND;
                    `FUNC_ORR : ALUOp = `ALU_OP_OR;
                    `FUNC_NOT : ALUOp = `ALU_OP_NOT;
                    `FUNC_TCP : ALUOp = `ALU_OP_NOT;
                    `FUNC_SHL : ALUOp = `ALU_OP_ALS;
                    `FUNC_SHR : ALUOp = `ALU_OP_ARS;
                    `FUNC_JPR : begin ALUOp = `ALU_OP_ID; RegWrite = 0; end
                    `FUNC_JRL : ALUOp = `ALU_OP_ID;
                    `FUNC_RWD : ALUOp = `ALU_OP_ID;
                    `FUNC_WWD : begin ALUOp = `ALU_OP_ID; RegWrite = 0; isWWD = 1; end
                endcase
            end
        
            
        endcase

    end
 
endmodule