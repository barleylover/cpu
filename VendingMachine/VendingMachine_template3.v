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
	input   wire    [NUM_ITEMS*ITEM_BITS-1:0]     num_items_i,

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
	reg[1:0] state, state_nxt;
	reg [TOT_BITS-1:0] total;
	localparam zero=0, first=1, second=2; 
	reg [TOT_BITS-1:0] current_total_nxt;
	
	reg [NUM_ITEMS-1:0] o_available_item, o_output_item;
	reg [NUM_COINS-1:0] o_return_coin;
	reg [NUM_COINS*COIN_BITS:0] coins;
	reg [NUM_COINS*COIN_BITS:0] num_coins_nxt;
  reg [NUM_ITEMS*ITEM_BITS-1:0] items, num_items_nxt;
	integer i, flag, total_reg, cnt_coin;

	// Sequential circuit to reset or update the states
	always @(posedge clk) begin
		if (!reset_n) begin
			// TODO: reset all states.
			state <= 0;
			total <= 0;
      items <= num_items_i;
			coins <= 0;
		end
		else begin
			// TODO: update all states.
			state <= state_nxt;
			total <= current_total_nxt;
      items <= num_items_nxt;
			coins <= num_coins_nxt;
		end
	end
	
	// Combinational circuit for the next states
	always @(*) begin
		//초기화
  	num_items_nxt = items;
		num_coins_nxt = coins;
		state_nxt = state;
		current_total_nxt = total;
		o_output_item = 0;
		o_return_coin = 0;
		flag = 0;
		for (i=0; i<NUM_ITEMS; i=i+1) begin
			o_available_item[i] = (total >= kkItemPrice[i] && num_items_nxt[ITEM_BITS*i +: ITEM_BITS] > 0);
		end

		case (state)
			zero: begin // 동전 투입, 아이템 선택, 반환 시작
				//동전 투입 -> 동전 총합 업데이트
        if (input_coin_i != 0) begin
					for (i=0; i<NUM_COINS; i=i+1) begin
						current_total_nxt = current_total_nxt + kkCoinValue[i]*input_coin_i[i];
						num_coins_nxt[i*COIN_BITS +: COIN_BITS] = num_coins_nxt[i*COIN_BITS +: COIN_BITS] + input_coin_i[i];
					end
				end
				//아이템 선택 -> item 배출
				else if (select_item_i !=0) begin
					for (i=0; i<NUM_ITEMS; i=i+1) begin
						if (select_item_i[i] && (current_total_nxt >= kkItemPrice[i]) && (num_items_nxt[i*ITEM_BITS +: ITEM_BITS] > 0)) begin
							o_output_item[i]=1;
							current_total_nxt = current_total_nxt - kkItemPrice[i];
              num_items_nxt[i*ITEM_BITS +: ITEM_BITS] = num_items_nxt[i*ITEM_BITS +: ITEM_BITS] - 1;
						end
					end
				end
				//반환 요구 -> first로
				else if (trigger_return_i) begin
					state_nxt = first;
				end
			end
			first: begin // 반환 가능 여부 계산
				total_reg=current_total_nxt;
				for (i=NUM_COINS-1; i>=0; i=i-1) begin
					if (total_reg >= kkCoinValue[i]) begin
						cnt_coin = total_reg/kkCoinValue[i];
						if (cnt_coin <= num_coins_nxt[i*COIN_BITS +: COIN_BITS]) begin
							total_reg = total_reg - cnt_coin*kkCoinValue[i];
						end
						else begin
							total_reg = total_reg - num_coins_nxt[i*COIN_BITS +: COIN_BITS]*kkCoinValue[i];
						end
					end
				end

				if (total_reg==0) begin
					state_nxt = second;
				end
				else begin
					state_nxt = zero;
				end

			end
			second: begin // 반환
				for (i=NUM_COINS-1; i>=0; i=i-1) begin
					if (flag != 1 && current_total_nxt >= kkCoinValue[i] && num_coins_nxt[i*COIN_BITS +: COIN_BITS] > 0) begin
						o_return_coin[i] = 1;
						current_total_nxt = current_total_nxt - kkCoinValue[i];
						num_coins_nxt[i*COIN_BITS +: COIN_BITS] = num_coins_nxt[i*COIN_BITS +: COIN_BITS]-1;
						flag = 1;
					end
				end
				
				if(current_total_nxt==0) begin
					state_nxt = zero;
				end			
				
			end
			default: begin
				state_nxt = zero;
			end
		endcase
		// TODO: current_total_nxt
																	   
		// TODO: num_items_nxt			
		
		// TODO: num_coins_nxt
		
	end
	
	// Combinational circuit for the outputs
		// TODO: o_available_item
	assign available_item_o = o_available_item;
	// TODO: o_output_item
	assign output_item_o = o_output_item;
	// TODO: o_return_coin
	assign return_coin_o = o_return_coin;
	assign total_o = total;
	
endmodule