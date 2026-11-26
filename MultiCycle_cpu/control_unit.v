`include "opcodes.v"

module ControlUnit (
    // DEFINE THE INTERFACE OF THE CONTROL UNIT HERE
    input wire  clk, 
    input wire  reset_n,
    input wire  ir_ack_i,
    input wire  [15:0] rd_inst,
    input wire  [15:0] rs_data, rt_data,
    
    output reg  PCWriteCond,
    output reg  PCWrite, IRWrite, IorD,
    output reg  isLHI, isORI, isJRL, isJAL, isTCP, isWWD,
    output reg  [1:0] PCSource,
    output reg  MemRead, MemtoReg, MemWrite, RegWrite, RegDst,
    output reg  ALUSrcA, 
    output reg  [1:0] ALUSrcB,
    output reg  [3:0] ALUOp
);

// ADD YOUR CODE HERE    
    localparam IF=0, ID=1, EX=2, MEM=3, WB=4, WWD=5;
    reg [3:0] state, state_nxt;
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= IF;
        end else begin
            state <= state_nxt;
        end
    end

    wire [5:0] funct;
    wire [3:0] opcode;

    assign funct = rd_inst[5:0];
    assign opcode = rd_inst[15:12];

    always @(*) begin
        PCSource=0; PCWrite=0; PCWriteCond=0;
        MemRead=0; MemtoReg=0; MemWrite=0;
        RegWrite=0; RegDst=0;
        IRWrite=0;
        IorD=0;
        ALUSrcA=0; ALUSrcB=0; ALUOp=0;
        isLHI=0; isORI=0; isJAL=0; isJRL=0; isTCP=0; isWWD=0;
        state_nxt = state;
        if (state==EX) begin
            case(opcode)
                `OPCODE_ADI : begin ALUOp = `ALU_OP_ADD; ALUSrcA=1; ALUSrcB=2; end
                `OPCODE_ORI : begin ALUOp = `ALU_OP_OR; isORI=1; ALUSrcA=1; ALUSrcB=2; end
                `OPCODE_LHI : begin ALUOp = `ALU_OP_ADD; isLHI=1; ALUSrcA=1; ALUSrcB=2; end
                `OPCODE_LWD : begin ALUSrcA=1; ALUSrcB=2; ALUOp=`ALU_OP_ADD; end
                `OPCODE_SWD : begin ALUSrcA=1; ALUSrcB=2; ALUOp=`ALU_OP_ADD; end
                `OPCODE_BNE : begin PCWriteCond=(rs_data==rt_data)? 0 : 1; ALUSrcA=0; ALUSrcB=2; end
                `OPCODE_BEQ : begin PCWriteCond=(rs_data==rt_data)? 1 : 0; ALUSrcA=0; ALUSrcB=2;end
                `OPCODE_BGZ : begin PCWriteCond=($signed(rs_data)>0)? 1:0; ALUSrcA=0; ALUSrcB=2;end
                `OPCODE_BLZ : begin PCWriteCond=($signed(rs_data)<0)? 1:0; ALUSrcA=0; ALUSrcB=2;end
                `OPCODE_RTYPE : begin
                    ALUSrcA = 1; ALUSrcB=0;
                    case(funct)
                        `FUNC_ADD : ALUOp = `ALU_OP_ADD;
                        `FUNC_SUB : ALUOp = `ALU_OP_SUB;
                        `FUNC_AND : ALUOp = `ALU_OP_AND;
                        `FUNC_ORR : ALUOp = `ALU_OP_OR;
                        `FUNC_NOT : ALUOp = `ALU_OP_NOT;
                        `FUNC_TCP : begin ALUOp = `ALU_OP_ADD; isTCP=1; end
                        `FUNC_SHL : ALUOp = `ALU_OP_ALS;
                        `FUNC_SHR : ALUOp = `ALU_OP_ARS;
                        `FUNC_RWD : ALUOp = `ALU_OP_ID;
                    endcase
                end
            endcase
        end

        case (state)
            IF: begin
                PCWrite = 1;
                ALUSrcA = 0; ALUSrcB = 1; ALUOp = `ALU_OP_ADD;
                IorD = 0; IRWrite=1; MemRead=1;
                PCSource = 0;
                state_nxt = ID;
            end
            ID: begin
                case (opcode)
                `OPCODE_RTYPE:
                    if (funct==`FUNC_WWD) begin
                        state_nxt = WWD;
                    end else if (funct==`FUNC_JPR) begin
                        PCSource = 3;
                        PCWrite=1;
                        state_nxt = IF;
                    end else if(funct==`FUNC_JRL) begin
                        PCSource = 3;
                        PCWrite=1;
                        RegWrite=1;
                        state_nxt = IF;
                        isJRL=1;
                    end else begin
                        state_nxt=EX;
                    end
                `OPCODE_JMP: begin
                    state_nxt=IF;
                    PCWrite=1;
                    PCSource=2; 
                end
                `OPCODE_JAL:begin
                    state_nxt=IF;
                    PCWrite=1;
                    RegWrite=1;
                    PCSource=2;
                    isJAL=1;
                end
                default: state_nxt=EX;

                endcase
            end
            EX: 
                if (opcode == `OPCODE_SWD || opcode==`OPCODE_LWD) begin
                    state_nxt = MEM;
                end else if (opcode==`OPCODE_BNE||opcode==`OPCODE_BEQ||opcode==`OPCODE_BGZ||opcode==`OPCODE_BLZ) begin
                    state_nxt = IF;
                end else begin
                    state_nxt = WB;
                end
            MEM:
            begin
                IorD = 1;
                if (opcode==`OPCODE_LWD) begin
                    state_nxt = WB;
                    MemRead = 1;
                end else begin
                    MemWrite = 1;
                    state_nxt = IF;
                end
            end
            WB: 
            begin
                RegWrite = 1;
                RegDst = (opcode==`OPCODE_RTYPE);
                state_nxt = IF;
                MemtoReg = (opcode==`OPCODE_LWD);
            end
            WWD: begin
                isWWD=1;
                if (ir_ack_i) begin
                    isWWD=0;
                    state_nxt = IF;
                end else begin
                    state_nxt = WWD;
                end
            end
            default: state_nxt = state;
        endcase
    end
 
endmodule