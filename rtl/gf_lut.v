module gf_lut 
	#(
		parameter GF_ID = 2,
		parameter WIDTH = 2,
		parameter Q     = 4
	)(
		input  wire [WIDTH-1:0] a,
		input  wire [WIDTH-1:0] b,
		input  wire             op_mul,
		output wire [WIDTH-1:0] result
	);
	
	reg [WIDTH-1:0] add_lut [0:Q*Q-1];
	reg [WIDTH-1:0] mul_lut [0:Q*Q-1];

generate
	if (GF_ID == 2) begin
		initial begin
			`include "lut/GF2_0_LUT_Table.vh"
		end
	end else if (GF_ID == 3) begin
		initial begin
			`include "lut/GF3_0_LUT_Table.vh"
		end
	end else if (GF_ID == 4) begin
		initial begin
			`include "lut/GF4_1_1_1_LUT_Table.vh"
		end
	end else begin
		initial $error("Unsupported GF_ID = %0d", GF_ID);
	end
endgenerate


	function [WIDTH-1:0] add;
		input [WIDTH-1:0] a_in;
		input [WIDTH-1:0] b_in;
		begin
			add = add_lut[a_in*Q + b_in];
		end
	endfunction	
	
	function [WIDTH-1:0] mul;
		input [WIDTH-1:0] a_in;
		input [WIDTH-1:0] b_in;
		begin
			mul = mul_lut[a_in*Q + b_in];
		end
	endfunction

	assign result = op_mul ? mul(a, b) : add(a, b);	
	
endmodule

module gf_2 
    (
        input  wire     a,
        input  wire     b,
        input  wire     op_mul,
        output wire     result
    );  
    // Instantiate the common GF LUT engine
    gf_lut #( .GF_ID(2), .WIDTH(1), .Q(2) ) 
             core (.a(a), .b(b), .op_mul(op_mul), .result(result) );            
endmodule

module gf_3 
    (
        input  wire [1:0] a,
        input  wire [1:0] b,
        input  wire    	  op_mul,
        output wire [1:0] result
    );  
    // Instantiate the common GF LUT engine
    gf_lut #( .GF_ID(3), .WIDTH(2), .Q(3) ) 
             core (.a(a), .b(b), .op_mul(op_mul), .result(result) );            
endmodule

module gf_4 
    (
        input  wire [1:0] a,
        input  wire [1:0] b,
        input  wire    	  op_mul,
        output wire [1:0] result
    );  
    // Instantiate the common GF LUT engine
    gf_lut #( .GF_ID(4), .WIDTH(2), .Q(4) ) 
             core (.a(a), .b(b), .op_mul(op_mul), .result(result) );            
endmodule
