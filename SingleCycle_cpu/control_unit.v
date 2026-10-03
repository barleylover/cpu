`include "opcodes.v"

module ControlUnit (
    // DEFINE THE INTERFACE OF THE CONTROL UNIT HERE
    input wire [15:0] rd_inst,

    output wire isJump,
    output wire isStore,
    output wire [3:0] alu_opcode,
    output wire isItype,
    output wire is_wwd
);

// ADD YOUR CODE HERE
  reg [3:0] opcode, alu_op;
  reg [5:0] funct;
  reg store, jump, itype, wwd;

    always @(*) begin
        opcode= rd_inst[15:12];
        funct = rd_inst[5:0];
        alu_op = `ALU_OP_ADD;

        store=1;
        jump=0;
        itype=0;
        wwd = 0;
        case (opcode)
            `OPCODE_RTYPE: begin //R-type
                case(funct)
                `FUNC_ADD: begin
                    alu_op = `ALU_OP_ADD; end
                `FUNC_SUB: begin
                    alu_op = `ALU_OP_SUB; end
                `FUNC_WWD: begin
                    alu_op = `ALU_OP_ID;
                    store = 0;
                    wwd = 1; end
                `FUNC_NOT, `FUNC_TCP: begin
                    alu_op = `ALU_OP_NOT; end
                `FUNC_AND: begin
                    alu_op = `ALU_OP_AND; end
                `FUNC_ORR: begin
                    alu_op = `ALU_OP_OR; end
                `FUNC_SHL: begin
                    alu_op = `ALU_OP_LLS; end
                `FUNC_SHR: begin
                    alu_op = `ALU_OP_ARS; end
                endcase
            end

            //I-type
            `OPCODE_ADI:  begin
                alu_op = `ALU_OP_ADD;
                itype = 1; end
            `OPCODE_ORI: begin
                alu_op = `ALU_OP_OR;
                itype = 1; end
            `OPCODE_LHI: begin
                alu_op = `ALU_OP_ADD;
                itype = 1; end

            //J-type
            9,10: begin jump = 1; store = 0; end
        endcase
    end

    assign isJump = jump;
    assign isStore = store;
    assign alu_opcode = alu_op;
    assign isItype = itype;
    assign is_wwd = wwd;
    
endmodule