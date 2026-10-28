`include "opcodes.v"

module CPU_W16_R4 #(
    parameter WORD_SIZE = 16,
    parameter REG_BITS  = 2
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
    output  wire                        dmem_write_o    // data write enable
    
    // Interrupt Handler IF (for debugging purpose)
    input   wire                        ir_ack_i,       // triggered when the given interrupt is properly handled
    output  wire                        ir_req_o,       // triggered when the internal interrupt occurs
    input   wire    [WORD_SIZE-1:0]     ir_msg_i,       // message transfer from interrupt handler (for RWD, not used)
    output  wire    [WORD_SIZE-1:0]     ir_msg_o,       // message transfer to interrupt handler
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
    // Fill here 
    // Fill here
    // Fill here

    // Register File IF
    // Fill here 
    // Fill here
    // Fill here


    // ALU IF
    // Fill here
    // Fill here
    // Fill here

 
    // Control Unit IF    
    // Fill here 
    // Fill here
    // Fill here


    // Program Counter IF
    // Fill here
    // Fill here
    // Fill here



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
    
    Register bucket for pipeline datapath
    - IFID Register
    - IDEX Register 
    - EXMEM Register
    - MEMWB Register

********************************************************/

    // Program Counter, Interrupt Handle State
    // Fill here
    // Fill here
    // Fill here
    
    // Register bucket for pipeline datapath
    // Fill here
    // Fill here
    // Fill here

    // IFID Pipeline (Instruction Fetch->Instruction Decode)
    // Fill here 
    // Fill here 
    // Fill here 

    // Part1: Instruction Memory Datapath
    // Fill here 
    // Fill here 
    // Fill here 

    // Part2: Register File Datapath
    // Fill here
    // Fill here
    // Fill here
    
    // Register File 
    RegisterFile #(
        .WORD_SIZE  (WORD_SIZE), 
        .REG_BITS   (REG_BITS)
    ) rf_w16_r4 (
        // Fill here
        // Fill here
        // Fill here
    );

    // IDEX Pipeline (Instruction Decode->Execution)
    // Fill here 
    // Fill here 
    // Fill here 

    // Part3: ALU Datapath
    // Fill here
    // Fill here
    // Fill here
    
    // Arithmetic Logic Unit
    ALU alu_w16_m (
        // Fill here
        // Fill here
        // Fill here
    );

    // EXMEM Pipeline (Execution->Memory)
    // Fill here 
    // Fill here 
    // Fill here 

    // Part4: Data Memory Datapath
    // Fill here 
    // Fill here 
    // Fill here 

      
    // MEMWB Pipeline (Memory->Writeback)
    // Fill here 
    // Fill here 
    // Fill here 


    // Part5: Control Unit Datapath
    // Fill here
    // Fill here
    // Fill here
    
    // Control Unit 
    ControlUnit ctrl_unit (
        // Fill here
        // Fill here
        // Fill here
    );

    // Part6: Program Counter Datapath
    // Fill here
    // Fill here
    // Fill here
    
    
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
    // Fill here 
    // Fill here
    // Fill here
    

endmodule