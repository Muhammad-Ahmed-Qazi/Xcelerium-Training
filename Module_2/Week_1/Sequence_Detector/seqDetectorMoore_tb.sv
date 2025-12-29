`timescale 1ns / 1ps

module seqDetectorMoore_tb;

    reg  w;
    reg  clk;
    wire z;

    // Instantiate DUT
    seqDetectorMoore dut (
        .w   (w),
        .clk (clk),
        .z   (z)
    );

    // Test vector
    reg [11:0] stimulus = 12'b010110111000;
    integer i;

    // Printing waveform
    initial begin
        $dumpfile("seqDetectorMoore_tb.vcd");
        $dumpvars(0, seqDetectorMoore_tb);
    end

    // Clock generation: 10 ns period
    always #5 clk = ~clk;

    initial begin
        // Initial values
        clk = 0;
        w   = 0;

        $display("Time\tclk\tw\tz");
        $display("------------------------");

        // Apply stimulus bit-by-bit
        for (i = 11; i >= 0; i = i - 1) begin
            @(negedge clk);
            w = stimulus[i];
            @(posedge clk);
            $display("%0t\t%b\t%b\t%b", $time, clk, w, z);
        end

        #10;
        $finish;
    end

endmodule
