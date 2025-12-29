`timescale 1ns/1ps

module adder32_tb;

    // Testbench signals
    reg  [31:0] a, b;
    reg         cin;
    wire [31:0] sum;
    wire        cout;

    // Instantiate DUT
    adder_32bit dut (
        .a   (a),
        .b   (b),
        .cin (cin),
        .sum (sum),
        .cout(cout)
    );

    // Counters
    integer total_tests = 0;
    integer passed_tests = 0;

    // Task to apply test and check result
    task check_adder;
        input [31:0] test_a, test_b;
        input        test_cin;
        reg   [31:0] expected_sum;
        reg          expected_cout;
        begin
            a = test_a;
            b = test_b;
            cin = test_cin;
            #1; // small delay for combinational logic to settle
            
            {expected_cout, expected_sum} = test_a + test_b + test_cin;
            
            total_tests = total_tests + 1;
            
            if (sum === expected_sum && cout === expected_cout) begin
                $display("TEST %0d PASS: a=%h b=%h cin=%b sum=%h cout=%b", 
                          total_tests, a, b, cin, sum, cout);
                passed_tests = passed_tests + 1;
            end else begin
                $display("TEST %0d FAIL: a=%h b=%h cin=%b sum=%h (expected %h) cout=%b (expected %b)", 
                          total_tests, a, b, cin, sum, expected_sum, cout, expected_cout);
            end
        end
    endtask

    // Printing waveform
	 initial begin
		 $dumpfile("adder_32.vcd");
		 $dumpvars(0, adder32_tb);
	 end

    // Test sequence
    integer i;
    initial begin
        $display("----- Starting 32-bit Adder Self-Checking Testbench -----");
        
        // ----- Directed tests -----
        check_adder(32'h0000_0000, 32'h0000_0000, 1'b0); // 0 + 0
        check_adder(32'hFFFF_FFFF, 32'hFFFF_FFFF, 1'b0); // max + max
        check_adder(32'h8000_0000, 32'h8000_0000, 1'b0); // overflow
        check_adder(32'h1234_5678, 32'h8765_4321, 1'b1); // mixed + carry

        // ----- Random tests -----
        for (i = 0; i < 50; i = i + 1) begin
            check_adder($random, $random, $random % 2);
        end

        // ----- Summary -----
        $display("----- Testbench Summary -----");
        $display("Total tests run : %0d", total_tests);
        $display("Tests passed    : %0d", passed_tests);
        $display("Tests failed    : %0d", total_tests - passed_tests);
        $finish;
    end

endmodule
