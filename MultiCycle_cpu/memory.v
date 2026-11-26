module Memory #(
    parameter WORD_SIZE = 16,
    parameter MEM_SIZE  = 256
)(
    input   wire                     clk,         
    input   wire                     mem_read_i,   
    input   wire                     mem_write_i,  
    input   wire [WORD_SIZE-1:0]     mem_addr_i,       
    input   wire [WORD_SIZE-1:0]     mem_wdata_i,  
    output  wire [WORD_SIZE-1:0]     mem_rdata_o   
);
    
    // Data Memory (Read/Write)
    reg [WORD_SIZE-1:0] data_mem [0:MEM_SIZE-1];
        
    // Memory Initialize
    integer i;
    initial begin
        for (i = 0; i < MEM_SIZE; i = i + 1) begin
            data_mem[i] = {WORD_SIZE{1'b0}};
        end
        // Initialize some data for program4
        data_mem[1] = 16'h0001;
        data_mem[2] = 16'hffff;
    end

    // Read Operation
    reg [WORD_SIZE-1:0] mem_rdata;
    always @(*) begin
        if (mem_read_i) begin
            mem_rdata = data_mem[mem_addr_i];  
        end else begin
            mem_rdata = {WORD_SIZE{1'b0}}; // read disabled, return 0
        end
    end

    // Write Operation
    always @(posedge clk) begin
        if (mem_write_i) begin
            data_mem[mem_addr_i] = mem_wdata_i;
        end
    end
    
    assign mem_rdata_o = mem_rdata;

endmodule