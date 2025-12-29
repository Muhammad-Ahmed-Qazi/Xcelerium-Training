`timescale 1ns/1ps

module barrel_shifter_tb;

    // Testbench signals
    reg  [31:0] data_in;
    reg  [4:0]  shift_amount;
    reg         dir;       // 0=left, 1=right
    wire [31:0] data_out;

    // Instantiate DUT
    barrel_shifter_32bit dut (
        .data_in      (data_in),
        .shift_amount (shift_amount),
        .dir          (dir),
        .data_out     (data_out)
    );

    // Counters
    integer total_tests = 0;
    integer passed_tests = 0;

    // Task to compute staged expected output and check DUT
    task check_shift;
        input [31:0] test_data;
        input [4:0]  test_shift;
        input        test_dir;
        reg [31:0] stage0, stage1, stage2, stage3, stage4;
        reg [31:0] expected;
        begin
            data_in      = test_data;
            shift_amount = test_shift;
            dir          = test_dir;
            #1; // small delay for combinational logic

            // Stage 0: shift by 1
            stage0 = test_shift[0] ? (test_dir ? {test_data[30:0], 1'b0} : {1'b0, test_data[31:1]}) : test_data;
            // Stage 1: shift by 2
            stage1 = test_shift[1] ? (test_dir ? {stage0[29:0], 2'b00} : {2'b00, stage0[31:2]}) : stage0;
            // Stage 2: shift by 4
            stage2 = test_shift[2] ? (test_dir ? {stage1[27:0], 4'b0000} : {4'b0000, stage1[31:4]}) : stage1;
            // Stage 3: shift by 8
            stage3 = test_shift[3] ? (test_dir ? {stage2[23:0], 8'b00000000} : {8'b00000000, stage2[31:8]}) : stage2;
            // Stage 4: shift by 16
            stage4 = test_shift[4] ? (test_dir ? {stage3[15:0], 16'b0000000000000000} : {16'b0000000000000000, stage3[31:16]}) : stage3;

            expected = stage4;

            total_tests = total_tests + 1;

            if (data_out === expected) begin
                $display("TEST %0d PASS: data_in=%h shift=%0d dir=%b data_out=%h", 
                          total_tests, data_in, shift_amount, dir, data_out);
                passed_tests = passed_tests + 1;
            end else begin
                $display("TEST %0d FAIL: data_in=%h shift=%0d dir=%b data_out=%h (expected %h)", 
                          total_tests, data_in, shift_amount, dir, data_out, expected);
            end
        end
    endtask

    // Printing waveform
     initial begin
         $dumpfile("barrel_shifter.vcd");
         $dumpvars(0, barrel_shifter_tb);
     end

    integer i;
    reg [31:0] rand_data;
    reg [4:0]  rand_shift;
    reg        rand_dir;

    initial begin
        $display("----- Starting 32-bit Barrel Shifter Self-Checking Testbench -----");

        // ----- Directed tests -----
        check_shift(32'h0000_0001, 1, 0);  // left shift by 1
        check_shift(32'h0000_0001, 1, 1);  // right shift by 1
        check_shift(32'h8000_0000, 31, 0); // left shift max
        check_shift(32'h0000_0001, 31, 1); // right shift max
        check_shift(32'hFFFF_FFFF, 16, 0); // left shift all ones
        check_shift(32'hFFFF_FFFF, 16, 1); // right shift all ones
        check_shift(32'h1234_5678, 4, 0);  // left
        check_shift(32'h1234_5678, 4, 1);  // right

        // ----- Randomized tests -----
        for (i = 0; i < 50; i = i + 1) begin
            rand_data  = $random;
            rand_shift = $random % 32;
            rand_dir   = $random % 2;
            check_shift(rand_data, rand_shift, rand_dir);
        end

        // ----- Summary -----
        $display("----- Testbench Summary -----");
        $display("Total tests run : %0d", total_tests);
        $display("Tests passed    : %0d", passed_tests);
        $display("Tests failed    : %0d", total_tests - passed_tests);
        $finish;
    end

endmodule
