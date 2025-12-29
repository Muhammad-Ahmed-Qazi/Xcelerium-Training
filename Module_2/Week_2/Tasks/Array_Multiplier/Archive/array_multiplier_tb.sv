`timescale 1ns / 1ps

module tb_array_multiplier_top;

    parameter N = 4;

    // Clock & reset
    reg clk;
    reg rst_n;

    // Inputs
    reg              EA;
    reg              EB;
    reg  [N-1:0]     A_in;
    reg  [N-1:0]     B_in;

    // Output
    wire [2*N-1:0]   P_out;

    // Shadow registers for checking
    reg [N-1:0] A_chk;
    reg [N-1:0] B_chk;

    // DUT
    array_multiplier_top #(
        .DATA_WIDTH(N)
    ) dut (
        .clk   (clk),
        .rst_n (rst_n),
        .EA    (EA),
        .EB    (EB),
        .A_in  (A_in),
        .B_in  (B_in),
        .P_out (P_out)
    );

    // Clock generation (10 ns period)
    always #5 clk = ~clk;

    // Dump waves
    initial begin
        $dumpfile("array_multiplier_top.vcd");
        $dumpvars(0, tb_array_multiplier_top);
    end

    // Stimulus
    initial begin
        clk = 0;
        rst_n = 0;
        EA = 0;
        EB = 0;
        A_in = 0;
        B_in = 0;
        A_chk = 0;
        B_chk = 0;

        // Apply reset
        #12;
        rst_n = 1;

        // Apply test vectors
        apply_inputs(0, 0);
        apply_inputs(1, 1);
        apply_inputs(3, 2);
        apply_inputs(4, 3);
        apply_inputs(7, 5);
        apply_inputs({N{1'b1}}, 1);
        apply_inputs({N{1'b1}}, {N{1'b1}});

        // Random tests
        repeat (10) begin
            apply_inputs($random % (1<<N), $random % (1<<N));
        end

        #20;
        $finish;
    end

    // Task to apply inputs cleanly
    task apply_inputs(input [N-1:0] a, input [N-1:0] b);
        begin
            @(negedge clk);
            A_in <= a;
            B_in <= b;
            EA   <= 1'b1;
            EB   <= 1'b1;

            // Save expected values
            A_chk <= a;
            B_chk <= b;

            @(negedge clk);
            EA <= 1'b0;
            EB <= 1'b0;

            // Wait for output register to update
            @(posedge clk);

            // Check result
            if (P_out !== A_chk * B_chk)
                $display("ERROR: A=%0d B=%0d | P=%0d (expected %0d)",
                         A_chk, B_chk, P_out, A_chk * B_chk);
            else
                $display("PASS : A=%0d B=%0d | P=%0d",
                         A_chk, B_chk, P_out);
        end
    endtask

endmodule
