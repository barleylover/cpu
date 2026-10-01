module RegisterFile #(
    parameter WORD_SIZE = 16,
    parameter REG_BITS  = 2
) (
    input clk,
    input reset_n,

    input wr_enable,

    input [REG_BITS-1:0] rd_reg1,
    input [REG_BITS-1:0] rd_reg2,
    input [REG_BITS-1:0] wr_reg,

    output [WORD_SIZE-1:0] rd_data1,
    output [WORD_SIZE-1:0] rd_data2,
    input  [WORD_SIZE-1:0] wr_data
);

// COPY AND PASTE YOUR REGISTER FILE CODE HERE!
    reg [WORD_SIZE*(2^REG_BITS)-1:0] regist, reg_nxt;
    reg [WORD_SIZE-1:0] rd_data1_o, rd_data2_o;

    always @(negedge clk) begin
        if (!reset_n) begin
            regist <= 0;
        end
        else begin
            regist <= reg_nxt; 
        end
    end

    always @(*) begin
        reg_nxt = regist;
        rd_data1_o = regist[WORD_SIZE*rd_reg1 +: WORD_SIZE];
        rd_data2_o = regist[WORD_SIZE*rd_reg2 +: WORD_SIZE];
        if (wr_enable) begin
            reg_nxt[WORD_SIZE*wr_reg +: WORD_SIZE] = wr_data;
        end
    end

    assign rd_data1 = rd_data1_o;
    assign rd_data2 = rd_data2_o;

endmodule