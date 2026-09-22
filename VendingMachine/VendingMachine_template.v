module vending_machine #(
	parameter TOT_BITS    = 32,     // Total bits of the money, price, coin value, etc...
	parameter ITEM_BITS   = 8,      // Total bits of the item
	parameter NUM_ITEMS   = 4,      // Total types of items
	parameter COIN_BITS   = 8,      // Total bits of the coin
	parameter NUM_COINS   = 3       // Total types of coins (100, 500, 1000)
)
(
	// Ports Declaration
	input   wire                        clk,                // Clock signal
	input   wire                        reset_n,            // Reset signal (active-low)
	
	input   wire    [NUM_COINS-1:0]     input_coin_i,       // coin is inserted.
	input   wire    [NUM_ITEMS-1:0]     select_item_i,      // item is selected.
	input   wire                        trigger_return_i,   // change-return is triggered 
		
	output  wire    [NUM_ITEMS-1:0]     available_item_o,   // Sign of the item availability
	output  wire    [NUM_ITEMS-1:0]     output_item_o,      // Sign of the item withdrawal
	output  wire    [NUM_COINS-1:0]     return_coin_o,      // Sign of the coin return
	output  wire    [TOT_BITS-1:0]      total_o             // Sign of the current total money
);

	// Net constant values (prefix kk & CamelCase)
	wire [TOT_BITS:0] kkItemPrice [NUM_ITEMS-1:0];	// Price of each item (400, 500, 1000, 2000)
	assign kkItemPrice[0] = 400;
	assign kkItemPrice[1] = 500;
	assign kkItemPrice[2] = 1000;
	assign kkItemPrice[3] = 2000;
	
	wire [TOT_BITS:0] kkCoinValue [NUM_COINS-1:0];	// Value of each coin (100, 500, 1000)
	assign kkCoinValue[0] = 100;
	assign kkCoinValue[1] = 500;
	assign kkCoinValue[2] = 1000;


	// TODO: You may add your own reg variables (state, total, ...)

	
	// Sequential circuit to reset or update the states
	always @(posedge clk) begin
		if (!reset_n) begin
			// TODO: reset all states.
		end
		else begin
			// TODO: update all states.
		end
	end
	
	// Combinational circuit for the next states
	always @(*) begin
		// TODO: current_total_nxt
																	   
		// TODO: num_items_nxt			
		
		// TODO: num_coins_nxt
		
	end
	
	// Combinational circuit for the outputs
	always @(*) begin
		// TODO: o_available_item

		// TODO: o_output_item

		// TODO: o_return_coin

	end
	
endmodule