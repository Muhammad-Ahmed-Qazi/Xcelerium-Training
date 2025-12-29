`timescale 1ns/1ps

module reg32_tb;

    logic        clk;
    logic        reset;      // Active-low reset (rst_n)
    logic        load;
    logic [31:0] d;
    logic [31:0] q;

    // DUT
    reg32 dut (
        .clk(clk),
        .rst_n(reset),      // Active-low reset
        .load(load),
        .d(d),
        .q(q)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // -------------------------
    // ASSERTIONS
    // -------------------------

    // Reset behavior (active-low: reset=0 means in reset)
    property reset_behavior;
        @(posedge clk)
            !reset |=> (q == 32'b0);  // Check NEXT cycle after reset goes low
    endproperty

    assert property (reset_behavior)
        else $error("RESET FAILED: q is not zero when reset is active");

    // Load behavior - check one cycle AFTER load
    property load_behavior;
        @(posedge clk)
            (reset && $past(load)) |-> (q == $past(d));  // Check when load was high PREVIOUS cycle
    endproperty

    assert property (load_behavior)
        else $error("LOAD FAILED: q != previous d");

    // Hold behavior - should hold when no load in previous cycle
    property hold_behavior;
        @(posedge clk)
            (reset && $past(!load)) |-> (q == $past(q));  // Check when load was low PREVIOUS cycle
    endproperty

    assert property (hold_behavior)
        else $error("HOLD FAILED: q changed without load in previous cycle");

    // -------------------------
    // Stimulus Generation
    // -------------------------
    initial begin
        clk = 0;
        reset = 0;    // Start with reset active (low)
        load = 0;
        d = 0;

        // Monitor for debugging
        $monitor("Time=%0t: reset_n=%b, load=%b, d=%h, q=%h", 
                 $time, reset, load, d, q);

        // Keep reset active for a while
        #12;
        reset = 1;    // Deassert reset (goes high)

        // Wait one cycle after reset
        @(posedge clk);
        
        // Load first value
        load = 1;
        d = 32'hA5A5A5A5;

        @(posedge clk);
        load = 0;

        // Hold for 3 cycles
        repeat (3) @(posedge clk);

        // Load second value
        load = 1;
        d = 32'h12345678;

        @(posedge clk);
        load = 0;

        // Hold for a few more cycles
        repeat (5) @(posedge clk);

        $finish;
    end

endmodule