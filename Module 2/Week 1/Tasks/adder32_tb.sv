`timescale 1ns / 1ps

module tb_adder_32bit;

    // Inputs
    reg [31:0] a;
    reg [31:0] b;
    reg        cin;

    // Outputs
    wire [31:0] sum;
    wire        cout;

    // Instantiate the 32-bit CLA
    adder_32bit uut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );
	 
	 // Add this at the beginning of your testbench
	 initial begin
		 // Specify the name of the waveform file
		 $dumpfile("adder_32bit.vcd");

		 // Dump all variables in the testbench hierarchy
		 $dumpvars(0, tb_adder_32bit);
	 end


    // Test procedure
    initial begin
        $display("Time\t a\t\t b\t\t cin\t sum\t\t cout");

        // Test 1: simple addition
        a = 32'h00000001;
        b = 32'h00000001;
        cin = 0;
        #10 $display("%0t\t %h\t %h\t %b\t %h\t %b", $time, a, b, cin, sum, cout);

        // Test 2: carry propagation
        a = 32'hFFFFFFFF;
        b = 32'h00000001;
        cin = 0;
        #10 $display("%0t\t %h\t %h\t %b\t %h\t %b", $time, a, b, cin, sum, cout);

        // Test 3: random vectors
        repeat (5) begin
            a = $random;
            b = $random;
            cin = $random % 2;
            #10 $display("%0t\t %h\t %h\t %b\t %h\t %b", $time, a, b, cin, sum, cout);
        end

        $finish;
    end

endmodule

