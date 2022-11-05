`include "tlc.v"
`timescale 1ns/1ps
module tb_tlc;

parameter FREQ = 0.001, // input clock frequency in MHz 

	  // TLC internal register address
	  ADDR_RED = 0, 
	  ADDR_YELLOW = 1,
	  ADDR_GREEN = 2,
	
	  ADDR_WIDTH = 3, //Min address bits required for 3 registers is 2. 
	  DATA_WIDTH = 8; // Keep min data width to be 8 to program 3 registers with time delay value in seconds 
		  
reg clk, rst, valid;
reg [ADDR_WIDTH-1 : 0] addr;
reg [DATA_WIDTH-1 : 0] data;
wire ready;
wire [1 : 0] state; // output state determines light

real time_period;

tlc # (.FREQ(FREQ), .ADDR_WIDTH(ADDR_WIDTH), .ADDR_RED(ADDR_RED), .ADDR_YELLOW(ADDR_YELLOW), .ADDR_GREEN(ADDR_GREEN), .DATA_WIDTH(DATA_WIDTH)) t0 (.clk(clk), .rst(rst), .addr(addr), .data(data), .valid(valid), .ready(ready), .state(state));

always #(time_period/2.0) clk = ~clk;

initial begin
	// Initializing variables and applying reset
	clk = 0; 
	time_period = (10**3)/FREQ; // Mhz to ns
	rst = 1;
	valid = 0;
	addr = 0;
	data = 0;
    	$monitor("time = %0t secs state=%0d rst=%0d",$time/(10.0**12), state, rst);
	repeat (4) @ (posedge clk);
	
	// Release reset
	rst = 0;
	// Configuring regsiters values and observing output 
	load_register(3, 1, 5);  // Red-> 3s, Yellow-> 1s and Green-> 5s
	repeat (100000) @ (posedge clk);
	rst = 1;
	repeat (100000) @ (posedge clk);
	rst = 0;
	load_register(4, 2, 7);
	repeat (100000) @ (posedge clk);

	$finish;
end

// task to load registers with values for each light delay in seconds
task load_register (input [DATA_WIDTH-1 :0] TRed, TYellow, TGreen); 
begin
	valid = 1;
	
	addr = ADDR_RED;
	data = TRed;
	@(posedge clk);
	addr = ADDR_YELLOW;
	data = TYellow;
	@(posedge clk);
	addr = ADDR_GREEN;
	data = TGreen;
	@(posedge clk);

	valid = 0;
end
endtask

endmodule
