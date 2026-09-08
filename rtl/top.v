module top 
	#(
		parameter GF_ID = 4,
		parameter WIDTH = 2,
		parameter Q		 = 4
	)
	(
		input  wire        CLOCK_50,
		input  wire [1:0]  KEY,
		input  wire 		 SWT,
		output wire [7:0]  LED
	);
	
	// ------------------------------------------------------------
	// Raw button signals (DE0-Nano buttons are active-low)
	// ------------------------------------------------------------
	wire key_start_raw = ~KEY[1];   // KEY1 pressed = 1
	wire key_rst_raw   = ~KEY[0];   // KEY0 pressed = 1	

	// ------------------------------------------------------------
	// Debounce KEY1 → start pulse
	// ------------------------------------------------------------
	wire start_level;
	wire start_pulse;

	debounce_fsmd db_start (
		.clk(CLOCK_50),
		.swt(key_start_raw),
		.db_level(start_level),
		.db_tick_rising(start_pulse)
	);	
	
	// ------------------------------------------------------------
	// Debounce KEY0 → stable reset level
	// ------------------------------------------------------------
	wire rst_level;
	wire rst_pulse;     // available if needed

	debounce_fsmd db_reset (
		.clk(CLOCK_50),
		.swt(key_rst_raw),
		.db_level(rst_level),
		.db_tick_rising(rst_pulse)
	);	

	// ------------------------------------------------------------
	// Convert debounced reset to active-low rst_n
	// ------------------------------------------------------------
	wire rst_n = ~rst_level;   // pressed → rst_level=1 → rst_n=0 → RESET	
	
	// ------------------------------------------------------------
	// Connect debounced signals to GF tester
	// ------------------------------------------------------------
	wire start  = start_pulse; // one-shot start pulse
	wire op_mul = SWT;         // mode select
	wire [WIDTH-1:0] lut_res;
	
	gf_test #(
		.GF_ID(GF_ID),
		.WIDTH(WIDTH),
		.Q(Q)
	) tester (
		.clk(CLOCK_50),
		.rst_n(rst_n),
		.start(start),
		.op_mul(op_mul),
		.lut_res(lut_res)
	);
	
	// LED mapping
	assign LED = {{(8-WIDTH){1'b0}}, lut_res};

endmodule	