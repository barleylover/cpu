`timescale 1ns / 100ps

module ALU 
(
	input   wire    [15:0]          A_i,  //16비트
	input   wire    [15:0]          B_i,
	input   wire    [3:0]           OP_i,	// 연산 선택
	input   wire                    C_i,
	
	output  wire     [15:0]         F_o,
	output  wire                    C_o
);
	
	// TODO : If your module and its pin have different OP_CODE, you should change the mapping.
	localparam  OP_ADD  = 4'b0000,
				OP_SUB  = 4'b0001,
				OP_ID   = 4'b1000,
				OP_NAND = 4'b1001, 
				OP_NOR  = 4'b1010,
				OP_XNOR = 4'b1011,
				OP_NOT  = 4'b1100,
				OP_AND  = 4'b1101, 
				OP_OR   = 4'b1110,
				OP_XOR  = 4'b1111,
				OP_LRS  = 4'b0010,
				OP_ARS  = 4'b0100,
				OP_RR   = 4'b0110,
				OP_LLS  = 4'b0011,
				OP_ALS  = 4'b0101,
				OP_RL   = 4'b0111;
	
	
	// TODO: Implement ALU
	reg [15:0] F;
	reg C;
	assign F_o = F;
	assign C_o = C;
	always @(*) begin
		F=16'b0;
		C=1'b0;
		case(OP_i)
			OP_ADD 	: {C, F} = A_i + B_i + C_i;
			OP_SUB 	: {C, F} = {1'b0, A_i} - {1'b0, B_i} - C_i;
			OP_ID 	: F=A_i;
			OP_NAND : F = ~(A_i&B_i);
			OP_NOR	: F=~(A_i | B_i);
			OP_XNOR : F=~(A_i ^ B_i);
			OP_NOT	: F=~A_i;
			OP_AND 	: F= A_i&B_i;
			OP_OR		: F= A_i|B_i;
			OP_XOR	:	F=A_i ^ B_i;

			OP_LRS	: F={1'b0, A_i[15:1]};		//right shift
			OP_ARS	: F=$signed(A_i) >>> 1;		//산술 rs	= {A_i[15], A_i[15:1]}
			OP_RR		: F={A_i[0], A_i[15:1]};	//회전 rs = (A_i>>1) | (A_i<<15)
			OP_LLS	: F={A_i[14:0], 1'b0};		// = A_i << 1
			OP_ALS	:	F={A_i[14:0], 1'b0};		// = A_i <<< 1
			OP_RL		: F={A_i[14:0], A_i[15]};	// = (A_i<<1) | (A_i>>15);
			default	:	;
		endcase	
	end

endmodule