`timescale 1ns/1ps

module tb_shift_reg;

    localparam DATA_WIDTH = 8;

    reg clk;
    reg rst_n;
    reg shift_en;
    reg dir;
    reg d_in;

    wire [DATA_WIDTH-1:0] q_out;

    // DUT
    shift_reg #(.DATA_WIDTH(DATA_WIDTH)) dut (
        .clk(clk),
        .rst_n(rst_n),
        .shift_en(shift_en),
        .dir(dir),
        .d_in(d_in),
        .q_out(q_out)
    );

    // Printing waveform
    initial begin
        $dumpfile("shift_reg.vcd");
        $dumpvars(0, tb_shift_reg);
    end

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;
        shift_en = 0;
        dir = 0;
        d_in = 0;

        // Apply reset
        #12 rst_n = 1;

        // Left shift test
        shift_en = 1;
        dir = 0;   // left
        d_in = 1;  #10;
        d_in = 0;  #10;
        d_in = 1;  #10;

        // Hold
        shift_en = 0;
        #20;

        // Right shift test
        shift_en = 1;
        dir = 1;   // right
        d_in = 1;  #10;
        d_in = 0;  #10;

        #20;
        $finish;
    end

endmodule
