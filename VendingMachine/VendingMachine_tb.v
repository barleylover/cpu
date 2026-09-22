`timescale 100ps / 100ps

module vending_machine_tb;

	parameter CLK_PERIOD  = 100;

	parameter TOT_BITS    = 32;
	parameter ITEM_BITS   = 8;
	parameter NUM_ITEMS   = 4;
	parameter COIN_BITS   = 8;
	parameter NUM_COINS   = 3;

	//Internal signal declaration
	reg     clk;
	reg     reset_n;
	
	reg     [NUM_COINS-1:0]     input_coin_i;
	reg     [NUM_ITEMS-1:0]     select_item_i;
	reg                         trigger_return_i;
	
	wire    [NUM_ITEMS-1:0]     available_item_o;
	wire    [NUM_ITEMS-1:0]     output_item_o;
	wire    [NUM_COINS-1:0]     return_coin_o;
	wire    [TOT_BITS-1:0]      total_o;

	// Unit Under Test port map
	vending_machine #(
		.TOT_BITS           (TOT_BITS),
		.ITEM_BITS          (ITEM_BITS),
		.NUM_ITEMS          (NUM_ITEMS),
		.COIN_BITS          (COIN_BITS),
		.NUM_COINS          (NUM_COINS)
	) 
	UUT (
		.clk                (clk),
		.reset_n            (reset_n),
		.input_coin_i       (input_coin_i),
		.select_item_i      (select_item_i),
		.trigger_return_i   (trigger_return_i),
		.available_item_o   (available_item_o),
		.output_item_o      (output_item_o),
		.return_coin_o      (return_coin_o),
		.total_o    (total_o)
	);

	// clock generation
	initial begin : CLOCK_GENERATOR
		clk     = 1'b0;
		forever #(CLK_PERIOD/2) clk = ~clk; // a clock cycle: # 100, a half cycle: # 50
	end

	// Test-bench
	initial begin
		$dumpfile("vcd/vending_machine.vcd");
		$dumpvars(0, UUT);
		
		// Initialize input signals
		input_coin_i     = {NUM_COINS{1'b0}};
		select_item_i    = {NUM_ITEMS{1'b0}};
		trigger_return_i    = 1'b0;
		reset_n             = 1'b0;
		repeat (3) @(posedge clk); // Wait until the output signals are stable.
		reset_n             = 1'b1;
		repeat (3) @(posedge clk); // Wait until the output signals are stable.
	    #(CLK_PERIOD/2)     // Pushing signal after half cycle
		
		// Test cases
		$display("---------------------------------------------------");
        $display("Command Start");
        $display("---------------------------------------------------");
		Insert100Coin();
		Insert100Coin();
		Insert100Coin();
		Insert100Coin();
		Insert100Coin();	

		Insert500Coin();
		Insert500Coin();    // 1500

		Insert1000Coin();
		Insert1000Coin();
		Insert1000Coin();
		Insert1000Coin();   // 5500

		Select1stItem();
		Select1stItem();    // 4700

		Select2ndItem();
		Select2ndItem();    // 3700
		
		Select3rdItem();    // 2700
		Select4thItem();    // 700	
	
		Insert100Coin();
		Insert100Coin();
		Insert100Coin();
		Insert100Coin();    // 1100
		
		Insert500Coin();
		Insert500Coin();
		Insert500Coin();    // 2600
		
		Insert1000Coin(); 
		Insert1000Coin();
		Insert1000Coin();   // 5600
	
		TriggerReturn();    // 0 (1000 x 5 + 500 x 1)
	
		$display("---------------------------------------------------");
        $display("Command completed");
        $display("---------------------------------------------------");
		#10000 
		$finish(0);	  
	end

// User's Action
task Insert100Coin;
begin
	#CLK_PERIOD input_coin_i[0]     = 1;
	#CLK_PERIOD input_coin_i[0]     = 0;	// After one cycle, deactivate the signal
	$display("Insert 100 Coin, Total: %d", total_o);
end
endtask

task Insert500Coin;
begin
	#CLK_PERIOD input_coin_i[1]     = 1;
	#CLK_PERIOD input_coin_i[1]     = 0;	// After one cycle, deactivate the signal
	$display("Insert 500 Coin, Total: %d", total_o);
end
endtask		

task Insert1000Coin;
begin
	#CLK_PERIOD input_coin_i[2]     = 1;
	#CLK_PERIOD input_coin_i[2]     = 0;	// After one cycle, deactivate the signal
	$display("Insert 1000 Coin, Total: %d", total_o);
end
endtask

task Select1stItem;
begin
	#CLK_PERIOD select_item_i[0]    = 1;
	#CLK_PERIOD select_item_i[0]    = 0;	// After one cycle, deactivate the signal
	$display("Select 1st Item, Total: %d, Item: %b", total_o, output_item_o);
end
endtask

task Select2ndItem;
begin
	#CLK_PERIOD select_item_i[1]    = 1;
	#CLK_PERIOD select_item_i[1]    = 0;	// After one cycle, deactivate the signal
	$display("Select 2nd Item, Total: %d, Item: %b", total_o, output_item_o);
end
endtask

task Select3rdItem;
begin
	#CLK_PERIOD select_item_i[2]    = 1;
	#CLK_PERIOD select_item_i[2]    = 0;	// After one cycle, deactivate the signal
	$display("Select 3rd Item, Total: %d, Item: %b", total_o, output_item_o);
end
endtask

task Select4thItem;
begin
	#CLK_PERIOD select_item_i[3]    = 1;
	#CLK_PERIOD select_item_i[3]    = 0;   // After one cycle, deactivate the signal
	$display("Select 4th Item, Total: %d, Item: %b", total_o, output_item_o);
end
endtask

task TriggerReturn;
begin
	#CLK_PERIOD trigger_return_i    = 1;
	#CLK_PERIOD trigger_return_i    = 0;
	$display("Trigger Return\n");
end
endtask

endmodule
