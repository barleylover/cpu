`include "opcodes.v"

module CPU_W16_R4 #(
    parameter WORD_SIZE = 16,
    parameter REG_BITS  = 2,
    parameter MEM_SIZE = 256
)
(
    // Global Signals
    input   wire    clk,      // global positive edge triggered clock
    input   wire    reset_n,  // global asynchronous negative triggered reset 

    // Instruction Memory IF (Read-only)
    input   wire    [WORD_SIZE-1:0]     imem_rdata_i,   // instruction read port
    output  wire    [WORD_SIZE-1:0]     imem_raddr_o,   // instruction read address

    // Data Memory IF (Read/Write)
    output  wire    [WORD_SIZE-1:0]     dmem_addr_o,    // data read address
    input   wire    [WORD_SIZE-1:0]     dmem_rdata_i,   // data read port
    output  wire    [WORD_SIZE-1:0]     dmem_wdata_o,   // data write port
    output  wire                        dmem_read_o,    // data read enable
    output  wire                        dmem_write_o,    // data write enable
    
    // Interrupt Handler IF (for debugging purpose)
    input   wire                        ir_ack_i,       // triggered when the given interrupt is properly handled
    output  wire                        ir_req_o,       // triggered when the internal interrupt occurs
    input   wire    [WORD_SIZE-1:0]     ir_msg_i,       // message transfer from interrupt handler (for RWD, not used)
    output  wire    [WORD_SIZE-1:0]     ir_msg_o       // message transfer to interrupt handler
);

/********************************************************
    Wire Variable Declaration
********************************************************
    Instruction Decoder IF
    - Instruction Opcode Signal
    - Instruction RS Signal
    - Instruction RT Signal
    - Instruction RD Signal
    - Instruction Function Code Signal
    - Instruction Immediate Signal
    - Instruction Target Address Signal
    
    Register File IF
    - Register Write Enable Signal
    - Register Read Address 1 Signal
    - Register Read Address 2 Signal
    - Register Write Address Signal
    - Register Read Data 1 Signal
    - Register Read Data 2 Signal
    - Register Write Data Signal
    - etc.
    
    ALU IF
    - ALU Operand 1 Signal
    - ALU Operand 2 Signal
    - ALU Operation Signal
    - ALU Result Signal
    - ALU Overflow Signal           (Maybe not used)
    - ALU Branch Condition Signal   (need to implemenet for branch inst.)
    
    Control Unit IF
    - Instruction Opcode Signal
    - Instruction Function Code Signal
    - Register Write Destination Select Signal
    - Register Write Enable Signal
    - Register Write Data Source Select Signal
    - ALU Operand 2 Source Select Signal
    - ALU Operation Signal
    - Memory Read Signal
    - Memory Write Signal
    - Jump Enable Signal
    - Branch Enable Signal
    - Jump Target Address Select Signal
    - Internal Interrupt Trap Enable Signal
    - Internal Interrupt Acknowledge Signal
    - etc.
    
    Program Counter IF
    - Program Counter Source Select Signals (ex. PC_SRC1, PC_SRC2, ...)
    - Next Address Signal
    - Jump Target Address Signal
    - Branch Target Address Signal
    - etc.
********************************************************/
    
    // Instruction Decoder IF
    reg [WORD_SIZE-1:0] imem_raddr, imem_raddr_nxt;

    // Register File IF
    reg                  rf_wr_enable;  // Register File: write enable
    reg  [REG_BITS -1:0] rf_rd_reg1;    // Register File: read register 1
    reg  [REG_BITS -1:0] rf_rd_reg2;    // Register File: read register 2
    reg  [REG_BITS -1:0] rf_wr_reg;     // Register File: write register
    wire [WORD_SIZE-1:0] rf_rd_data1;   // Register File: read data 1
    wire [WORD_SIZE-1:0] rf_rd_data2;   // Register File: read data 2
    reg  [WORD_SIZE-1:0] rf_wr_data;    // Register File: write data


    // ALU IF
    reg  [15:0] alu_operand1,  // ALU: first operand (or operand A) 
                alu_operand2;  // ALU: second operand (or operand B)
    reg  [3 :0] alu_opcode;    // ALU: opcode (it may be different to the instruction's opcode)
    wire [15:0] alu_result;    // ALU: output result
    wire        alu_overflow;  // ALU: overflow or carry output

 
    // Control Unit IF    
    wire    isLHI, 
            isORI, 
            isWWD, 
            isTCP,
            isJAL,
            isJPR,
            isJRL,
            bcond;
    wire [3:0] ALUOp;
    wire    RegDst, 
            Jump, 
            Branch, 
            MemRead, 
            MemtoReg, 
            MemWrite, 
            ALUSrc, 
            RegWrite;



    // Program Counter IF
    reg ir_req;
    reg [WORD_SIZE-1:0] inst;


/********************************************************
    Reg Variable Declaration
********************************************************
    State Signal
    - Interrupt Handling State Signals (ex. IDLE, ACTIVE, ...) 
    - Program Counter Signal
    - etc.
 
    State Dependent Signals
    - Data Memory Control Signals (if interrupted, read/write is disabled)
    - Interrupt Handler Control Signals (interrupt request is based with interrupt state)
    - etc.
********************************************************/

    // Program Counter, Interrupt Handle State


    // Part1: Instruction Memory Datapath

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            imem_raddr <= 16'b0;
        end else begin 
            imem_raddr <= imem_raddr_nxt;
        end
    end

    assign imem_raddr_o = imem_raddr;


    // Part2: Register File Datapath
    always @(*) begin
        rf_rd_reg1 = imem_rdata_i[11:10];
        rf_rd_reg2 = imem_rdata_i[9:8];
        
        if (isJAL || isJRL) begin
            rf_wr_reg = 2;
        end else if (RegDst) begin
            rf_wr_reg = imem_rdata_i[7:6];    
        end else begin
            rf_wr_reg = imem_rdata_i[9:8];
        end
        if (MemtoReg) begin
            rf_wr_data = dmem_rdata_i;
        end else if (isJAL || isJRL) begin
            rf_wr_data = imem_raddr+1;
        end else begin
            rf_wr_data = alu_result;
        end
        rf_wr_enable = RegWrite;
    end
    
    // Register File 
    RegisterFile #(
        .WORD_SIZE(WORD_SIZE), .REG_BITS(REG_BITS)
    ) rf_w16_r4 (
       .clk(clk), .reset_n(reset_n),
       .wr_enable(rf_wr_enable),
      .rd_reg1(rf_rd_reg1), .rd_reg2(rf_rd_reg2), .wr_reg(rf_wr_reg),
      .rd_data1(rf_rd_data1), .rd_data2(rf_rd_data2), .wr_data(rf_wr_data)
    );

    // Part3: ALU Datapath
    always @(*) begin
        if (isLHI) begin
            alu_operand1 = 0;
        end else if (isTCP) begin
            alu_operand1 = ~rf_rd_data1;
        end else begin
            alu_operand1 = rf_rd_data1;
        end

        if (ALUSrc) begin
            if (isLHI) begin
                alu_operand2 = {imem_rdata_i[7:0], 8'b0};
            end else if(isORI) begin
                alu_operand2 = {8'b0, imem_rdata_i[7:0]};
            end else begin
                alu_operand2 = {{8{imem_rdata_i[7]}}, imem_rdata_i[7:0]};
            end
        end else if (isTCP) begin
            alu_operand2 = 16'b1;
        end else begin
            alu_operand2 = rf_rd_data2;
        end
        alu_opcode = ALUOp;
    end

    // Arithmetic Logic Unit
    ALU alu_w16_m (
        .A_i(alu_operand1), .B_i(alu_operand2), .OP_i(alu_opcode), .C_i(1'b0), 
        .F_o(alu_result), .C_o(alu_overflow)
    );


    // Part4: Control Unit Datapath

    // Control Unit 
    ControlUnit ctrl_unit (
    // FILL OUT THE INTERFACE FOR THE CONTROL UNIT
        .rd_inst(imem_rdata_i),
        .rs_data(rf_rd_data1), .rt_data(rf_rd_data2),
        .RegDst(RegDst), .Jump(Jump), .Branch(Branch), .MemRead(MemRead), .MemtoReg(MemtoReg), .MemWrite(MemWrite), .ALUSrc(ALUSrc), .RegWrite(RegWrite),
        .ALUOp(ALUOp),
        .isORI(isORI), .isLHI(isLHI), .isWWD(isWWD), .isTCP(isTCP), 
        .isJAL(isJAL), .isJPR(isJPR), .isJRL(isJRL),
        .bcond(bcond));
    
    assign dmem_addr_o = alu_result;
    assign dmem_wdata_o = rf_rd_data2;
    assign dmem_read_o = MemRead;
    assign dmem_write_o = MemWrite;
    
    // Part5: Program Counter Datapath
    always @(*) begin
        inst = imem_raddr + 1;
        ir_req = 0;
        if (isWWD && !ir_ack_i) begin   //WWD state
            imem_raddr_nxt = imem_raddr;
            ir_req = 1;
        end else if (Branch && bcond) begin     // 
            imem_raddr_nxt = inst + {{8{imem_rdata_i[7]}}, imem_rdata_i[7:0]};
        end else if (Jump) begin
            imem_raddr_nxt = {imem_raddr[15:12], imem_rdata_i[11:0]};
        end else if (isJPR || isJRL) begin
            imem_raddr_nxt = rf_rd_data1;
        end else begin imem_raddr_nxt = inst; end
    end
    
    assign ir_req_o = ir_req;
    assign ir_msg_o = rf_rd_data1;

    // Part6: Program Counter & Interrupt Handler with FSM
    // - program counter, data memory, interrupt handler is dependant with interrupt state
    // - interrupt occured, program counter update is 
    // - interrupt occured, data memory read/write is disabled
    // - Instruction Memory Model (Read-only / Single Port)
    //      - 16-bit aligned memory
    //      - you need to update imem_addr +1 to PC up (not +2)
    //      - no jump/branch, imem_addr_nxt = imem_addr + 1
    //      - branch, imem_addr_nxt = imem_addr + imm_value
    //      - jump, imem_addr_nxt = target address
    // - Example
    //      - imem_rdata = 16'h2001; BGZ $0, 1        -> if ($0 > 0) pc=pc+1
    //          - 16'h2001 = 16'b0010_0000_0000_0001
    //      - imem_rdata = 16'h908b; JMP 0x8b(139)    -> pc='d139
    //          - 16'h908b = 16'b1001_0000_1000_1011

endmodule