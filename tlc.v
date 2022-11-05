// Traffic Light Controller 

/* 
INPUTS
	1. clk - Clock
	2. rst - Reset
	3. addr - Address bus used while programming registers by master
	4. data - Data bus to set values of registers by master
	5. valid - Singal from master to indicate master is ready for data transfer

OUTPUTS
	1. ready - Signal from TLC to indicate TLC is also ready for data transfer
	2. state - output signal bus to indicate current light state 
*/
module tlc (clk, rst, addr, data, valid, ready, state);

parameter FREQ = 0.001, // input clock frequency in MHz 

	  ADDR_WIDTH = 3, //Min address bits required for 3 registers is 2. 
	  DATA_WIDTH = 8, // Keep min data width to be 8 to program 3 registers with time delay value in seconds 
		  
	  // Internal addresses of each register
	  // Each registers stores values in seconds that can be configured by Master
	  ADDR_RED = 0, 
	  ADDR_YELLOW = 1,
	  ADDR_GREEN = 2,
	  
	  // States
	  RESET = 2'b00,
	  RED = 2'b01,
	  YELLOW = 2'b10,
	  GREEN = 2'b11;

input clk, rst, valid;
input [ADDR_WIDTH-1 : 0] addr;
input [DATA_WIDTH-1 : 0] data;
output reg ready;
output reg [1 : 0] state; // output state determines light 

//reg [DATA_WIDTH-1 : 0] counter, limit;
integer counter, limit;
reg [1 : 0] nxt_state; 
reg [DATA_WIDTH-1 : 0] TRed;
reg [DATA_WIDTH-1 : 0] TYellow;
reg [DATA_WIDTH-1 : 0] TGreen;

initial begin
	state = RESET;
	nxt_state = RED;
	ready = 0;
	TRed = 0;
	TYellow = 0;
	TGreen = 0;
	counter = 0;
	limit = 1; // It will start from red after one clock cycle
end

// Register configuration logic
always @ (posedge clk) begin
	if (rst == 1) begin
		state = RESET;
		ready = 0;
		counter = 0;
		limit = 1; // It will start from red after one clock cycle if rst = 0
	end
	else begin
		if (valid == 1) begin
			ready = 1;
			case (addr) 
				ADDR_RED: TRed = data;	

				ADDR_YELLOW: TYellow = data;

				ADDR_GREEN: TGreen = data;

				default: begin
					$display("Error writing to register! Invalid address of regiter.");
					ready = 0;
				end
			endcase
		end
		else begin // valid is off
			ready = 0;
		end	
	end
end

// Time counting logic
always @ (posedge clk) begin
	if (counter == limit) begin
		state = nxt_state;
		counter = 0;
	end
	else begin
		counter = counter + 1;
	end
end

// FSM logic
always @ (posedge clk) begin
	case (state)
		RED: begin
			nxt_state = YELLOW;
			limit = FREQ * (10**6) * TRed;
		end
		YELLOW: begin
			nxt_state = GREEN;
			limit = FREQ * (10**6) * TYellow;
		end
		GREEN: begin
			nxt_state = RED;
			limit = FREQ * (10**6) * TGreen;
		end
		RESET: begin
			nxt_state = RED;
			limit = 1; // It will start from red after one clock cycle if rst = 0
        end
		default: begin
			nxt_state = RED;
			limit = 1; // It will start from red after one clock cycle if rst = 0
		end
	endcase
end

endmodule

