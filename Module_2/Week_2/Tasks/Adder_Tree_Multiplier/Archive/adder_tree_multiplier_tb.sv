`timescale 1ns / 1ps

module tb_adder_tree_multiplier_top;

    parameter DATA_WIDTH = 8;

    reg clk;
    reg rst_n;
    reg EA, EB;
    reg [DATA_WIDTH-1:0] A_in, B_in;
    wire [2*DATA_WIDTH-1:0] P_out;

    // DUT
    adder_tree_multiplier_top #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .EA(EA),
        .EB(EB),
        .A_in(A_in),
        .B_in(B_in),
        .P_out(P_out)
    );

    // Printing waveform
    initial begin
        $dumpfile("adder_tree_multiplier.vcd");
        $dumpvars(0, tb_adder_tree_multiplier_top);
    end

    // Clock
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        EA = 0;
        EB = 0;
        A_in = 0;
        B_in = 0;

        #20 rst_n = 1;

        // Test cases
        repeat (10) begin
            @(negedge clk);
            EA = 1; EB = 1;
            A_in = $random % 256;
            B_in = $random % 256;

            @(negedge clk);
            EA = 0; EB = 0;

            // Wait for output register
            @(posedge clk);

            if (P_out !== A_in * B_in)
                $display("ERROR: A=%0d B=%0d P=%0d (expected %0d)",
                          A_in, B_in, P_out, A_in * B_in);
            else
                $display("PASS : A=%0d B=%0d P=%0d",
                          A_in, B_in, P_out);
        end

        $finish;
    end

endmodule
