`timescale 1ns / 1ps

module tb_manchesterMealy;

    // Testbench signals
    reg  w;
    reg  clk;
    wire z;

    // Instantiate DUT
    manchesterMealy dut (
        .w(w),
        .clk(clk),
        .z(z)
    );

    // Printing waveform
    initial begin
        $dumpfile("manchesterMealy_tb.vcd");
        $dumpvars(0, tb_manchesterMealy);
    end

    // Clock generation: 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test sequence: 111001
    initial begin
        // Initialize
        w = 1;
        clk = 0;

        // Wait for some time before starting
        #5;

        // Apply bits (one bit per clock cycle)
        w = 1;  #20;   // bit 1
        w = 1;  #20;   // bit 1
        w = 1;  #20;   // bit 1
        w = 0;  #20;   // bit 0
        w = 0;  #20;   // bit 0
        w = 1;  #20;   // bit 1

        // Hold last value
        w = 0;
        #20;

        $finish;
    end

    // Optional monitoring
    initial begin
        $monitor("Time=%0t | clk=%b | w=%b | z=%b | state=%b",
                 $time, clk, w, z, dut.state);
    end

endmodule
