`include "opcodes.v"

module ControlUnit (
    // DEFINE THE INTERFACE OF THE CONTROL UNIT HERE
    input wire [15:0] inst_addr,
    input ir_ack,   // immediate 여부
    input wire [REG_BITS-1:0] rf_rd_reg1,
    input wire [REG_BITS-1:0] rf_rd_reg2,
    input wire [REG_BITS-1:0] rf_wr_reg,
    output wire branch,
    output wire RegWrite,
    output wire [3:0] alu_opcode,
    output wire ALU_src
    output ir_req;
);

// ADD YOUR CODE HERE
    reg [3:0] opcode;
    reg [1:0] rd_reg1=0;
    reg [1:0] rd_reg2=0;
    reg [1:0] wr_reg=0;
    reg wr_enable=0;
    reg branch_o=0;
    reg alu_src=0;
    reg [3:0] alu_op = `ALU_OP_ADD;
    reg [5:0] funct = inst_addr[5:0];
    reg [7:0] imm = inst_addr[7:0];
    wire ir_req_o=0;

    always @(*) begin
        opcode = inst_addr[15:12];
        wr_enable = 1;
        if (opcode == 15) begin     //R-type
            rd_reg1 = inst_addr[11:10];
            rd_reg2 = inst_addr[9:8];
            wr_reg = inst_addr[7:6];

            if (funct==`FUNC_ADD) begin
                alu_op = `ALU_OP_ADD;
            end else if (funct==`FUNC_SUB) begin
                alu_op = `ALU_OP_SUB;
            end else if (func==`FUNC_WWD) begin
                alu_op = `ALU_OP_ID;
                ir_req_o = 1;
            end else if (funct==`FUNC_NOT || funct==`FUNC_TCP) begin
                alu_op = `ALU_OP_NOT;
            end else if (funct==`FUNC_AND) begin
                alu_op = `ALU_OP_AND;
            end else if (funct==`FUNC_ORR) begin
                alu_op = `ALU_OP_OR;
            end else if (funct==`FUNC_SHL) begin
                alu_op = `ALU_OP_LLS;
            end else if (funct==`FUNC_SHR) begin
                alu_op = `ALU_OP_ARS;
            end
        end else if (!ir_ack) begin     //I-type
            rd_reg1 = inst_addr[11:10];
            wr_reg = inst_addr[9:8];
            if (funct==`FUNC_ADI) begin
                alu_op = `ALU_OP_ADD;
                alu_src = 1;
            end else if(funct==`FUNC_ORI) begin
                alu_op = `ALU_OP_OR;
                alu_src = 1;
            end else if(funct==`FUNC_LHI) begin
                alu_op = `ALU_OP_LHI;
                alu_src = 1;
            end else if(funct==`FUNC_RWD) begin
                alu_op = `ALU_OP_RWD
            if (0<=opcode<=3) begin
                branch_o = 1; //branch경우
            end
        end else if (opcode==9 || opcode==10) begin                  //J-type
            wr_enable = 0;
            branch_o = 1;
        end
    end
    assign rf_rd_reg1 = rd_reg1;
    assign rf_rd_reg2 = rd_reg2;
    assign rf_wr_reg = wr_reg;
    assign branch = branch_o;
    assign RegWrite = wr_enable;
    assign alu_opcode = alu_op;
    assign ALU_src = alu_src;
    assign ir_req = ir_req_o;
    assign ir_msg = ir_msg_o;
endmodule