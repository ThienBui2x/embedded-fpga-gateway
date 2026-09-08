/*
	'db_tick_rising' is just a small one-clock-cycle Pulse,
	hence, no LED signal is visible
*/

module debounce_fsmd
	(
		input wire clk,
		input wire swt,
		output reg db_level, db_tick_rising
	);
	
	// Clock Declaration
	localparam 
			BASE_FREQ = 50_000_000,		// (Hz)
			TIM_FREQ	 = 200;				// (Hz - 20 ms)
		
	// Symbolic State Declaration
	localparam	[1:0]
			zero 	= 2'b00,
			wait1 = 2'b01,
			one	= 2'b10,
			wait0 = 2'b11;
	
	// Signal Declaration
	reg	[1:0] 	state_reg, state_next;
	reg	[31:0]	cnt_curr, cnt_next;
	
	// FSMD State & Data register
	always @ (posedge clk)
		begin
			state_reg <= state_next;
			cnt_curr <= cnt_next;		// Update cnt
		end
		
	// Next-State & Data path logic
	always @*
		begin
			// Default: Use old values
			state_next = state_reg;
			cnt_next = cnt_curr;
			db_level = 1'b0;
			db_tick_rising = 1'b0;
			
			case (state_reg)
				zero:
					begin
						db_level = 1'b0;
						if (swt)
							begin
								state_next = wait1;
								cnt_next = 0;			// Init cnt (once)
							end
					end
				wait1:
					begin
						db_level = 1'b0;
						if (swt)
							if (cnt_curr < BASE_FREQ/TIM_FREQ - 1)
								cnt_next = cnt_curr+1;
							else		// Counting finished
								begin
									state_next = one;
									db_tick_rising = 1'b1;
								end	
						else
							state_next = zero;
					end
				one:
					begin
						db_level = 1'b1;	// Set default for Db_level
						if (~swt)
							begin
								state_next = wait0;
								cnt_next = 0;			// Init cnt (once)
							end
					end
				wait0:
					begin
						db_level = 1'b1;
						if (~swt)
							if (cnt_curr < BASE_FREQ/TIM_FREQ - 1)
								cnt_next = cnt_curr+1;
							else		// Counting finished
								state_next = zero;		
						else
							state_next = one;
					end
			
			default: state_next = zero;
			endcase
		end
		
endmodule