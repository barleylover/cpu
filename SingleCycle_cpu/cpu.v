`include "opcodes.v"

module CPU_W16_R4 (  // CPU with its word size 16 and 4 registers
    input clk,      // global positive edge triggered clock
    input reset_n,  // global asynchronous negative triggered reset 

    // interface with instruction memory 
    input      [15:0] rd_inst,    // instruction read port
    output reg [15:0] inst_addr,  // instruction address (synchronous to the clock)

    // interface for internal interrupt (for debugging purpose)
    input             ir_ack,  // interrupt acknowledge signal (acknowledge signal from the interrupt handler, triggered when the given interrupt is properly handled)
    output reg        ir_req,  // interrupt request signal (triggered when the internal interrupt occurs, may not be synchronous to the clock)
    output reg [15:0] ir_msg   // interrupt message (message transferred to the interrupt handler, may not be synchronous to the clock)
);

/*******************************************************
 * PART 1: Skeleton Codes
 *******************************************************
 
 Description
   - This part provides skeleton code of the TSC ISA based CPU
   - Useful local parameters are provided
   - Output port that should be defined as a D-FF is declared here (inst_addr -> inst_addr_nxt)
   - ALU is instantiated
   - Register File is instantiated

 Note
   - You can modify the skeleton code to optimize your design
   - You should use the ALU and Register File design implemented in previous lab assignment
   - The address for instruction memory (inst_addr) should be synchronous to the clock
 */

// SECTION: Local Parameters
localparam WORD_SIZE = 16;  // size of each word, address
localparam REG_BITS  = 2;   // the size of register index (4 registers -> 2bit register ID)

// SECTION: Wires and Registers
reg [15:0] inst_addr_nxt;

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        inst_addr <= 'd0; //0으로 초기화
    end else begin
        inst_addr <= inst_addr_nxt;
    end
end

// SECTION: ALU instantiation
reg  [15:0] alu_operand1,  // ALU: first operand (or operand A) 
            alu_operand2;  // ALU: second operand (or operand B)
wire  [3 :0] alu_opcode;    // ALU: opcode (it may be different to the instruction's opcode)
wire [15:0] alu_result;    // ALU: output result
wire        alu_overflow;  // ALU: overflow or carry output

ALU alu_w16_m (
    .A_i(alu_operand1), .B_i(alu_operand2), .OP_i(alu_opcode), .C_i(1'b0), 
    .F_o(alu_result), .C_o(alu_overflow)
);

// SECTION: Register File instantiation
wire                  rf_wr_enable;  // Register File: write enable
reg  [REG_BITS -1:0] rf_rd_reg1;    // Register File: read register 1
reg  [REG_BITS -1:0] rf_rd_reg2;    // Register File: read register 2
reg  [REG_BITS -1:0] rf_wr_reg;     // Register File: write register
wire [WORD_SIZE-1:0] rf_rd_data1;   // Register File: read data 1
wire [WORD_SIZE-1:0] rf_rd_data2;   // Register File: read data 2
reg  [WORD_SIZE-1:0] rf_wr_data;    // Register File: write data

RegisterFile #(
    .WORD_SIZE(WORD_SIZE), .REG_BITS(REG_BITS)
) rf_w16_r4 (
    .clk(clk), .reset_n(reset_n),
    .wr_enable(rf_wr_enable),
    .rd_reg1(rf_rd_reg1), .rd_reg2(rf_rd_reg2), .wr_reg(rf_wr_reg),
    .rd_data1(rf_rd_data1), .rd_data2(rf_rd_data2), .wr_data(rf_wr_data)
);


/*******************************************************
 * PART 2: Instruction Decoder and Control Unit
 *******************************************************
 
 Description
   - This part is for instruction decoder and control unit
   - As you already learned in the class, the CPU converts instruction into the micro-code that
     are directly transferred to the hardware components
   - Instruction Decoder splits an instruction into multiple fields
   - Control Unit generates control signal transferred to the hardware components 
     e.g. ALU, Register File, Instruction Memory

 Note
   - We highly recommend you to implement the Control Unit as a separate module
   - We provided "control_unit.v" to implement the Control Unit
   - You can define the interface of the Control Unit (it may be different to the MIPS micro-architecture)
 */

// SECTION: Instruction Decoder

// ADD YOUR CODE HERE
wire is_jump, alu_src, is_wwd;
// SECTION: Control Unit instantiation

ControlUnit ctrl_unit (
    // FILL OUT THE INTERFACE FOR THE CONTROL UNIT
    .rd_inst(rd_inst),
    .is_jump(is_jump), .RegWrite(rf_wr_enable), .alu_opcode(alu_opcode), .ALU_src(alu_src), .is_wwd(is_wwd)

);


/*******************************************************
 * PART 3: Finite State Machine
 *******************************************************
 
 Description
   - This part is for finite state machine (FSM) that controls the CPU

 Note
   - You may need to create an FSM to control the CPU and properly trigger interrupt
   - Note that the CPU should stop executing instructions until it receives an acknowledge signal
     from the external interrupt handler once it triggers an interrupt
   - If you did not use FSM, ignore this part!
 */

// SECTION: Finite State Machine

// ADD YOUR CODE HERE


/*******************************************************
 * PART 4: Datapath
 *******************************************************
 
 Description
   - This part is for datapath of the CPU
   - The datapath determines how the hardware components are connected to each other
 */

// SECTION: Datapath

// ADD YOUR CODE HERE
  
endmodule