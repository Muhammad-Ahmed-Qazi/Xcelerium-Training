`timescale 1ns/1ps

module encoder_tb;

    // Testbench signals
    reg  [7:0] in;
    reg        en;
    wire [2:0] out;
    wire       gs, e0;

    // Instantiate DUT
    encoder dut (
        .in  (in),
        .en  (en),
        .out (out),
        .gs  (gs),
        .e0  (e0)
    );

    // Counters
    integer total_tests = 0;
    integer passed_tests = 0;

    // Task to compute expected outputs and check DUT
    task check_encoder;
        input [7:0] test_in;
        input       test_en;
        reg [2:0] expected_out;
        reg expected_gs;
        reg expected_e0;
        integer i;
        reg found;
        begin
            in = test_in;
            en = test_en;
            #1; // small delay for combinational logic

            // Default values
            expected_out = 3'b000;
            expected_gs  = 1'b0;
            expected_e0  = 1'b0;

            found = 0;
            if (test_en) begin
                for (i = 7; i >= 0; i = i - 1) begin
                    if (test_in[i] && !found) begin
                        expected_out = i[2:0];
                        expected_gs  = 1'b1;
                        expected_e0  = 1'b0;
                        found = 1; // stop further updates
                    end
                end
                if (!found) begin
                    // no bits set
                    expected_out = 3'b000;
                    expected_gs  = 1'b0;
                    expected_e0  = 1'b1;
                end
            end else begin
                // encoder disabled
                expected_out = 3'b000;
                expected_gs  = 1'b0;
                expected_e0  = 1'b0;
            end

            // Check DUT outputs
            total_tests = total_tests + 1;
            if (out === expected_out && gs === expected_gs && e0 === expected_e0) begin
                $display("TEST %0d PASS: in=%b en=%b out=%b gs=%b e0=%b", 
                          total_tests, in, en, out, gs, e0);
                passed_tests = passed_tests + 1;
            end else begin
                $display("TEST %0d FAIL: in=%b en=%b out=%b (expected %b) gs=%b (expected %b) e0=%b (expected %b)", 
                          total_tests, in, en, out, expected_out, gs, expected_gs, e0, expected_e0);
            end
        end
    endtask

    // Printing waveform
    initial begin
        $dumpfile("encoder_8to3.vcd");
        $dumpvars(0, encoder_tb);
    end

    // Test sequence
    integer i;
    initial begin
        $display("----- Starting 8-to-3 Encoder Self-Checking Testbench -----");

        // ----- Directed tests: single high bit -----
        for (i = 0; i < 8; i = i + 1) begin
            check_encoder(8'b1 << i, 1'b1);
        end

        // ----- Directed test: all zeros -----
        check_encoder(8'b0000_0000, 1'b1);

        // ----- Directed test: disabled -----
        check_encoder(8'b1111_1111, 1'b0);

        // ----- Random tests: multiple bits high -----
        for (i = 0; i < 20; i = i + 1) begin
            check_encoder($random % 256, 1'b1);
        end

        // ----- Summary -----
        $display("----- Testbench Summary -----");
        $display("Total tests run : %0d", total_tests);
        $display("Tests passed    : %0d", passed_tests);
        $display("Tests failed    : %0d", total_tests - passed_tests);
        $finish;
    end

endmodule
