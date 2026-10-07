`include "opcodes.v"

module ControlUnit (
    // DEFINE THE INTERFACE OF THE CONTROL UNIT HERE
    input wire [15:0] rd_inst,
    input wire reset_n,

    output reg [3:0] ALUOp,
    output reg RegDst,
    output reg MemRead,
    output reg MemtoReg,
    output reg MemWrite,
    output reg RegWrite,
    output reg Branch,
    output reg Jump,

    output reg isStore,
    output reg isItype,
    output reg isLHI,
    output reg isJAL,
    output reg isJPR,
    output reg is_wwd
);

// ADD YOUR CODE HERE
  reg [3:0] opcode;
  reg [5:0] func;

  always @(*) begin
    if (!reset_n) begin
        RegDst          = 1'b0;
        Jump            = 1'b0;
        Branch          = 1'b0;
        MemRead         = 1'b0;
        MemtoReg        = 1'b0;
        ALUOp           = 5'b0;
        MemWrite        = 1'b0;
        ALUSrc          = 1'b0;
        RegWrite        = 1'b0;
        isLHI           = 1'b0;
        isWWD           = 1'b0;
        isJAL_JRL       = 1'b0;
        isJPR_JRL       = 1'b0;
        sign            = 1'b0;
    end
    else begin
        //초기화

        opcode = rd_inst[15:12];
        func = rd_inst[5:0];

        case(opcode)
            // R-type
            `OPCODE_RTYPE: begin
                case(func)
                    `FUNC_ADD: begin
                        RegDst          = 1'b1;
                        Jump            = 1'b0;
                        Branch          = 1'b0;
                        MemRead         = 1'b0;
                        MemtoReg        = 1'b0;
                        ALUOp           = `ALU_OP_ADD;
                        MemWrite        = 1'b0;
                        ALUSrc          = 1'b0;
                        RegWrite        = 1'b1;
                        isLHI           = 1'b0;
                        isWWD           = 1'b0;
                        isJAL_JRL       = 1'b0;
                        isJPR_JRL       = 1'b0;
                        sign            = 1'b0;
                    end
                    `FUNC_SUB: begin
                        RegDst          = 1'b1;
                        Jump            = 1'b0;
                        Branch          = 1'b0;
                        MemRead         = 1'b0;
                        MemtoReg        = 1'b0;
                        ALUOp           = `ALU_OP_SUB;
                        MemWrite        = 1'b0;
                        ALUSrc          = 1'b0;
                        RegWrite        = 1'b1;
                        isLHI           = 1'b0;
                        isWWD           = 1'b0;
                        isJAL_JRL       = 1'b0;
                        isJPR_JRL       = 1'b0;
                        sign            = 1'b0;
                    end
                    `FUNC_AND: begin
                        RegDst          = 1'b1;
                        Jump            = 1'b0;
                        Branch          = 1'b0;
                        MemRead         = 1'b0;
                        MemtoReg        = 1'b0;
                        ALUOp           = `ALU_OP_AND;
                        MemWrite        = 1'b0;
                        ALUSrc          = 1'b0;
                        RegWrite        = 1'b1;
                        isLHI           = 1'b0;
                        isWWD           = 1'b0;
                        isJAL_JRL       = 1'b0;
                        isJPR_JRL       = 1'b0;
                        sign            = 1'b0;
                    end
                    `FUNC_ORR: begin
                        RegDst          = 1'b1;
                        Jump            = 1'b0;
                        Branch          = 1'b0;
                        MemRead         = 1'b0;
                        MemtoReg        = 1'b0;
                        ALUOp           = `ALU_OP_OR;
                        MemWrite        = 1'b0;
                        ALUSrc          = 1'b0;
                        RegWrite        = 1'b1;
                        isLHI           = 1'b0;
                        isWWD           = 1'b0;
                        isJAL_JRL       = 1'b0;
                        isJPR_JRL       = 1'b0;
                        sign            = 1'b0;
                    end
                    `FUNC_NOT: begin
                        RegDst          = 1'b1;
                        Jump            = 1'b0;
                        Branch          = 1'b0;
                        MemRead         = 1'b0;
                        MemtoReg        = 1'b0;
                        ALUOp           = `ALU_OP_NOT;
                        MemWrite        = 1'b0;
                        ALUSrc          = 1'b0;
                        RegWrite        = 1'b1;
                        isLHI           = 1'b0;
                        isWWD           = 1'b0;
                        isJAL_JRL       = 1'b0;
                        isJPR_JRL       = 1'b0;
                        sign            = 1'b0;
                    end
                    `FUNC_TCP: begin
                        RegDst          = 1'b1;
                        Jump            = 1'b0;
                        Branch          = 1'b0;
                        MemRead         = 1'b0;
                        MemtoReg        = 1'b0;
                        ALUOp           = `ALU_OP_TCP;
                        MemWrite        = 1'b0;
                        ALUSrc          = 1'b0;
                        RegWrite        = 1'b1;
                        isLHI           = 1'b0;
                        isWWD           = 1'b0;
                        isJAL_JRL       = 1'b0;
                        isJPR_JRL       = 1'b0;
                        sign            = 1'b0;
                    end
                    `FUNC_SHL: begin
                        RegDst          = 1'b1;
                        Jump            = 1'b0;
                        Branch          = 1'b0;
                        MemRead         = 1'b0;
                        MemtoReg        = 1'b0;
                        ALUOp           = `ALU_OP_LLS;
                        MemWrite        = 1'b0;
                        ALUSrc          = 1'b0;
                        RegWrite        = 1'b1;
                        isLHI           = 1'b0;
                        isWWD           = 1'b0;
                        isJAL_JRL       = 1'b0;
                        isJPR_JRL       = 1'b0;
                        sign            = 1'b0;
                    end
                    `FUNC_SHR: begin
                        RegDst          = 1'b1;
                        Jump            = 1'b0;
                        Branch          = 1'b0;
                        MemRead         = 1'b0;
                        MemtoReg        = 1'b0;
                        ALUOp           = `ALU_OP_ARS;
                        MemWrite        = 1'b0;
                        ALUSrc          = 1'b0;
                        RegWrite        = 1'b1;
                        isLHI           = 1'b0;
                        isWWD           = 1'b0;
                        isJAL_JRL       = 1'b0;
                        isJPR_JRL       = 1'b0;
                        sign            = 1'b0;
                    end
                    `FUNC_WWD: begin
                        RegDst          = 1'b1;
                        Jump            = 1'b0;
                        Branch          = 1'b0;
                        MemRead         = 1'b0;
                        MemtoReg        = 1'b0;
                        ALUOp           = 5'b0;
                        MemWrite        = 1'b0;
                        ALUSrc          = 1'b0;
                        RegWrite        = 1'b0;
                        isLHI           = 1'b0;
                        isWWD           = 1'b1;
                        isJAL_JRL       = 1'b0;
                        isJPR_JRL       = 1'b0;
                        sign            = 1'b0;
                    end
                    `FUNC_JPR: begin
                        RegDst          = 1'b1;
                        Jump            = 1'b0;
                        Branch          = 1'b0;
                        MemRead         = 1'b0;
                        MemtoReg        = 1'b0;
                        ALUOp           = 5'b0;
                        MemWrite        = 1'b0;
                        ALUSrc          = 1'b0;
                        RegWrite        = 1'b0;
                        isLHI           = 1'b0;
                        isWWD           = 1'b0;
                        isJAL_JRL       = 1'b0;
                        isJPR_JRL       = 1'b1;
                        sign            = 1'b0;
                    end
                    `FUNC_JRL: begin
                        RegDst          = 1'b1;
                        Jump            = 1'b0;
                        Branch          = 1'b0;
                        MemRead         = 1'b0;
                        MemtoReg        = 1'b0;
                        ALUOp           = 5'b0;
                        MemWrite        = 1'b0;
                        ALUSrc          = 1'b0;
                        RegWrite        = 1'b1;
                        isLHI           = 1'b0;
                        isWWD           = 1'b0;
                        isJAL_JRL       = 1'b1;
                        isJPR_JRL       = 1'b1;
                        sign            = 1'b0;
                    end
                    default: begin
                        RegDst          = 1'b0;
                        Jump            = 1'b0;
                        Branch          = 1'b0;
                        MemRead         = 1'b0;
                        MemtoReg        = 1'b0;
                        ALUOp           = 5'b0;
                        MemWrite        = 1'b0;
                        ALUSrc          = 1'b0;
                        RegWrite        = 1'b0;
                        isLHI           = 1'b0;
                        isWWD           = 1'b0;
                        isJAL_JRL       = 1'b0;
                        isJPR_JRL       = 1'b0;
                        sign            = 1'b0;
                    end
                endcase
            end
            // I-type
            `OPCODE_ADI: begin
                RegDst          = 1'b0;
                Jump            = 1'b0;
                Branch          = 1'b0;
                MemRead         = 1'b0;
                MemtoReg        = 1'b0;
                ALUOp           = `ALU_OP_ADD;
                MemWrite        = 1'b0;
                ALUSrc          = 1'b1;
                RegWrite        = 1'b1;
                isLHI           = 1'b0;
                isWWD           = 1'b0;
                isJAL_JRL       = 1'b0;
                isJPR_JRL       = 1'b0;
                sign            = 1'b1;
            end
            `OPCODE_ORI: begin
                RegDst          = 1'b0;
                Jump            = 1'b0;
                Branch          = 1'b0;
                MemRead         = 1'b0;
                MemtoReg        = 1'b0;
                ALUOp           = `ALU_OP_OR;
                MemWrite        = 1'b0;
                ALUSrc          = 1'b1;
                RegWrite        = 1'b1;
                isLHI           = 1'b0;
                isWWD           = 1'b0;
                isJAL_JRL       = 1'b0;
                isJPR_JRL       = 1'b0;
                sign            = 1'b0;
            end
            `OPCODE_LHI: begin
                RegDst          = 1'b0;
                Jump            = 1'b0;
                Branch          = 1'b0;
                MemRead         = 1'b0;
                MemtoReg        = 1'b0;
                ALUOp           = 5'b0;
                MemWrite        = 1'b0;
                ALUSrc          = 1'b1;
                RegWrite        = 1'b1;
                isLHI           = 1'b1;
                isWWD           = 1'b0;
                isJAL_JRL       = 1'b0;
                isJPR_JRL       = 1'b0;
                sign            = 1'b0;       
            end
            `OPCODE_LWD: begin
                RegDst          = 1'b0;
                Jump            = 1'b0;
                Branch          = 1'b0;
                MemRead         = 1'b1;
                MemtoReg        = 1'b1;
                ALUOp           = `ALU_OP_ADD;
                MemWrite        = 1'b0;
                ALUSrc          = 1'b1;
                RegWrite        = 1'b1;
                isLHI           = 1'b0;
                isWWD           = 1'b0;
                isJAL_JRL       = 1'b0;
                isJPR_JRL       = 1'b0;
                sign            = 1'b1;
            end
            `OPCODE_SWD: begin 
                RegDst          = 1'b0;
                Jump            = 1'b0;
                Branch          = 1'b0;
                MemRead         = 1'b0;
                MemtoReg        = 1'b0;
                ALUOp           = `ALU_OP_ADD;
                MemWrite        = 1'b1;
                ALUSrc          = 1'b1;
                RegWrite        = 1'b0;
                isLHI           = 1'b0;
                isWWD           = 1'b0;
                isJAL_JRL       = 1'b0;
                isJPR_JRL       = 1'b0;
                sign            = 1'b1;
            end
            `OPCODE_BNE: begin
                RegDst          = 1'b0;
                Jump            = 1'b0;
                Branch          = 1'b1;
                MemRead         = 1'b0;
                MemtoReg        = 1'b0;
                ALUOp           = `ALU_OP_NE;
                MemWrite        = 1'b0;
                ALUSrc          = 1'b0;
                RegWrite        = 1'b0;
                isLHI           = 1'b0;
                isWWD           = 1'b0;
                isJAL_JRL       = 1'b0;
                isJPR_JRL       = 1'b0;
                sign            = 1'b1;
            end
            `OPCODE_BEQ: begin
                RegDst          = 1'b0;
                Jump            = 1'b0;
                Branch          = 1'b1;
                MemRead         = 1'b0;
                MemtoReg        = 1'b0;
                ALUOp           = `ALU_OP_EQ;
                MemWrite        = 1'b0;
                ALUSrc          = 1'b0;
                RegWrite        = 1'b0;
                isLHI           = 1'b0;
                isWWD           = 1'b0;
                isJAL_JRL       = 1'b0;
                isJPR_JRL       = 1'b0;
                sign            = 1'b1;
            end
            `OPCODE_BGZ: begin
                RegDst          = 1'b0;
                Jump            = 1'b0;
                Branch          = 1'b1;
                MemRead         = 1'b0;
                MemtoReg        = 1'b0;
                ALUOp           = `ALU_OP_GZ;
                MemWrite        = 1'b0;
                ALUSrc          = 1'b0;
                RegWrite        = 1'b0;
                isLHI           = 1'b0;
                isWWD           = 1'b0;
                isJAL_JRL       = 1'b0;
                isJPR_JRL       = 1'b0;
                sign            = 1'b1;
            end
            `OPCODE_BLZ: begin
                RegDst          = 1'b0;
                Jump            = 1'b0;
                Branch          = 1'b1;
                MemRead         = 1'b0;
                MemtoReg        = 1'b0;
                ALUOp           = `ALU_OP_LZ;
                MemWrite        = 1'b0;
                ALUSrc          = 1'b0;
                RegWrite        = 1'b0;
                isLHI           = 1'b0;
                isWWD           = 1'b0;
                isJAL_JRL       = 1'b0;
                isJPR_JRL       = 1'b0;
                sign            = 1'b1;
            end
            // J-type
            `OPCODE_JMP: begin
                RegDst          = 1'b0;
                Jump            = 1'b1;
                Branch          = 1'b0;
                MemRead         = 1'b0;
                MemtoReg        = 1'b0;
                ALUOp           = 5'b0;
                MemWrite        = 1'b0;
                ALUSrc          = 1'b0;
                RegWrite        = 1'b0;
                isLHI           = 1'b0;
                isWWD           = 1'b0;
                isJAL_JRL       = 1'b0;
                isJPR_JRL       = 1'b0;
                sign            = 1'b0;
            end
            `OPCODE_JAL: begin
                RegDst          = 1'b0;
                Jump            = 1'b1;
                Branch          = 1'b0;
                MemRead         = 1'b0;
                MemtoReg        = 1'b0;
                ALUOp           = 5'b0;
                MemWrite        = 1'b0;
                ALUSrc          = 1'b0;
                RegWrite        = 1'b1;
                isLHI           = 1'b0;
                isWWD           = 1'b0;
                isJAL_JRL       = 1'b1;
                isJPR_JRL       = 1'b0;
                sign            = 1'b0;
            end
            default: begin
                RegDst          = 1'b0;
                Jump            = 1'b0;
                Branch          = 1'b0;
                MemRead         = 1'b0;
                MemtoReg        = 1'b0;
                ALUOp           = 5'b0;
                MemWrite        = 1'b0;
                ALUSrc          = 1'b0;
                RegWrite        = 1'b0;
                isLHI           = 1'b0;
                isWWD           = 1'b0;
                isJAL_JRL       = 1'b0;
                isJPR_JRL       = 1'b0;
                sign            = 1'b0;
            end
        endcase
    end
end
 
endmodule