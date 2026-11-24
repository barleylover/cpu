`include "opcodes.v"

module ControlUnit (
    // DEFINE THE INTERFACE OF THE CONTROL UNIT HERE
    input wire  clk, 
    input wire  reset_n,
    input reg   [15:0] rd_inst,
    input reg   [15:0] rs_data, rt_data,
    
    // output reg PCWriteCond,
    output reg  PCWrite,IRWrite, IorD,
    output reg  [1:0] PCSource,
    output reg  MemRead, MemtoReg, MemWrite, RegWrite, RegDst,
    output reg  ALUSrcA, 
    output reg  [1:0] ALUSrcB,
    output reg  [3:0] ALUOp
);

// ADD YOUR CODE HERE
    reg [5:0] funct;
    reg [3:0] opcode;
    
    localparam IF=0, ID=1, EX=2, MEM=3, WB=4; WWD=5;
    reg [3:0] state, state_nxt;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= IF;
        end else begin
            state <= state_nxt;
        end
    end


    always @(*) begin
        funct = rd_inst[5:0];
        opcode = rd_inst[15:12];
        PCWriteCond=0;
        PCSource=0;
        PCWrite=0;
        MemRead=0;
        MemtoReg=0;
        MemWrite=0;
        RegWrite=0;
        RegDst=0;
        IRWrite=0;
        IorD=0;
        ALUSrcA=1; // branch일 때 0
        ALUSrcB=0; // R-type: rd <- rs, rt / pc 업데이트 : pc <- pc+1 <-> branch, jump일때 sign-extended(inst[7:0])
        ALUOp=0;    
        case(opcode)
            `OPCODE_ADI : begin
                ALUOp = `ALU_OP_ADD;
                ALUSrc = 1;
                RegWrite = 1;
                ALUSrcB = 2;
            end
            `OPCODE_ORI :  begin 
                ALUOp = `ALU_OP_OR;
                ALUSrc = 1;
                RegWrite = 1; 
                isORI = 1;
            end
            `OPCODE_LHI :   begin
                ALUOp = `ALU_OP_ADD;
                ALUSrc = 1;
                RegWrite = 1;
                isLHI = 1;
            end
            `OPCODE_LWD :   begin
                MemRead = 1;
                MemtoReg = 1;  //register에 메모리값 전달
                ALUSrc = 1;
                RegWrite = 1;
                ALUSrcB = 2;
                PCSource = 1;
            end
            `OPCODE_SWD :   begin
                MemWrite = 1;
                ALUSrc = 1;
                ALUSrcB = 2;
                PCSource = 1;
            end
            `OPCODE_BNE :   begin
                Branch = 1;
                bcond = (rs_data==rt_data)? 0 : 1;
                ALUSrcA = 0;
                ALUSrcB = 2;
            end
            `OPCODE_BEQ :   begin
                Branch = 1;
                bcond = (rs_data==rt_data)? 1 : 0;
                ALUSrcA = 0;
                ALUSrcB = 2;
            end
            `OPCODE_BGZ :   begin
                Branch = 1;
                bcond = ($signed(rs_data)>0)? 1:0;
                ALUSrcA = 0;
            end
            `OPCODE_BLZ :   begin
                Branch = 1;
                bcond = ($signed(rs_data)<0)? 1:0;
                ALUSrcA = 0;
                ALUSrcB = 2;
            end
            `OPCODE_JMP :   begin
                Jump = 1;
                PCSource = 2;
            end
            `OPCODE_JAL :   begin
                Jump = 1;
                isJAL = 1;
                RegWrite = 1;
                PCSource = 2;
            end
            `OPCODE_RTYPE : begin
                RegDst = 1;
                MemtoReg = 0;  //alu 연산 결과 전달
                RegWrite = 1; 
                case(funct)a
                    `FUNC_ADD : ALUOp = `ALU_OP_ADD;
                    `FUNC_SUB : ALUOp = `ALU_OP_SUB;
                    `FUNC_AND : ALUOp = `ALU_OP_AND;
                    `FUNC_ORR : ALUOp = `ALU_OP_OR;
                    `FUNC_NOT : ALUOp = `ALU_OP_NOT;
                    `FUNC_TCP : begin ALUOp = `ALU_OP_ADD; isTCP=1; end
                    `FUNC_SHL : ALUOp = `ALU_OP_ALS;
                    `FUNC_SHR : ALUOp = `ALU_OP_ARS;
                    `FUNC_JPR : begin ALUOp = `ALU_OP_ID; RegWrite = 0; isJPR=1; end
                    `FUNC_JRL : begin ALUOp = `ALU_OP_ID; isJRL=1; end
                    `FUNC_RWD : ALUOp = `ALU_OP_ID;
                    `FUNC_WWD : begin ALUOp = `ALU_OP_ID; RegWrite = 0; isWWD = 1; end
                endcase
            end
        
            
        endcase

        case (state)
            IF:
                if (opcode==`OPCODE_WWD) begin
                    state_nxt = WWD;
                end else begin 
                    state_nxt = ID;
                end
            ID: state_nxt = EX;
            EX: state_nxt = MEM;
            MEM: 
                if (opcode == `OPCODE_ST || opcode==) begin
                    state_nxt = WB;
                end else begin
                    ALUSrcB = 1;
                    state_nxt = IF;
                end 
            WB: begin ALUSrcB=1; state_nxt = IF; end
            WWD:
                if (ir_ack==0) begin
                    state_nxt = ID;
                end else begin
                    state_nxt = WWD;
                end
        endcase
    end
 
endmodule