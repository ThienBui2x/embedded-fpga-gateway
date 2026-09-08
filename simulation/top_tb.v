`timescale 1ns/1ps

module top_tb;

    reg CLOCK_50;
    reg [1:0] KEY;
    reg       SWT;

    wire [7:0] LED;

    // DUT
    top dut (
        .CLOCK_50(CLOCK_50),
        .KEY(KEY),
        .SWT(SWT),
        .LED(LED)
    );

    // Clock generation: 50 MHz ? 20 ns period
    initial begin
        CLOCK_50 = 0;
        forever #10 CLOCK_50 = ~CLOCK_50;
    end

    // Stimulus
    initial begin
        // init
        KEY = 2'b11;   // KEY0=1 (rst_n), KEY1=1 (start inactive)
        SWT = 0;       // ADD mode

        // Apply reset
        #50  KEY[0] = 0;   // rst_n = 0
        #50  KEY[0] = 1;   // rst_n = 1

        // --- ADD sweep: 16 cycles = 16 * 20ns = 320ns ---
        #20  KEY[1] = 0;   // start = 1
        #320 KEY[1] = 1;   // start = 0, a/b stop at last value

        // Reset a and b (KEY0 = 0 then 1)
        #20  KEY[0] = 0;   // rst_n = 0 ? a = 0, b = 0
        #40  KEY[0] = 1;   // rst_n = 1

        // --- Switch to MUL mode ---
        #40  SWT = 1;      // op_mul = 1

        // MUL sweep: again 16 cycles
        #20  KEY[1] = 0;   // start = 1
        #320 KEY[1] = 1;   // start = 0

        #200 $stop;
    end

endmodule
