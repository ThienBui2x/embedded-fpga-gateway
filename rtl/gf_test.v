module gf_test 
	#(
		parameter GF_ID = 2,
		parameter WIDTH = 2,
		parameter Q     = 4
	)
	(
		input              clk,
		input              rst_n,
		input              start,
		input              op_mul,
		output reg [WIDTH-1:0] lut_res
	);
	
	// internal sweep counters
	reg [WIDTH-1:0] a;
	reg [WIDTH-1:0] b;
	
	// DUT output
	wire [WIDTH-1:0] dut_result;

	// Instantiate LUT
	gf_lut #(
		.GF_ID(GF_ID),
		.WIDTH(WIDTH),
		.Q(Q)
	) dut (
		.a(a),
		.b(b),
		.op_mul(op_mul),
		.result(dut_result)
	);

	// Reference tables
	reg [WIDTH-1:0] add_ref [0:Q*Q-1];
	reg [WIDTH-1:0] mul_ref [0:Q*Q-1];

	// FSM / counters
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			a       <= 0;
			b       <= 0;
			lut_res <= 0;
		end else begin
			if (start) begin
				// output DUT result
				lut_res <= dut_result;

				// sweep b inside a
				if (b == Q-1) begin
					b <= 0;
					if (a == Q-1)
						a <= 0;   // finished
					else 
						a <= a + 1;
				end else
					b <= b + 1;
			end
		end
	end

endmodule
