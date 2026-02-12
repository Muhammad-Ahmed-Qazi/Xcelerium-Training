`timescale 1ns/1ps

module tb_seq_detector;

    logic clk;
    logic rst_n;
    logic in_bit;
    logic seq_detected;

    // DUT
    seq_detector dut (
        .clk         (clk),
        .rst_n       (rst_n),
        .in_bit      (in_bit),
        .seq_detected(seq_detected)
    );

    // Printing waveform
    initial begin
        $dumpfile("seq_detector.vcd");
        $dumpvars(0, tb_seq_detector);
    end

    // Clock: 10 ns period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Reset
    initial begin
        rst_n = 0;
        in_bit = 0;
        repeat (2) @(posedge clk);
        rst_n = 1;
    end

    // Simple reference model for 1011 detection (overlapping)
    logic [3:0] shift_reg;
    logic       exp_detect;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            shift_reg  <= 4'b0;
            exp_detect <= 1'b0;
        end else begin
            shift_reg  <= {shift_reg[2:0], in_bit};
            exp_detect <= (shift_reg == 4'b1011);
        end
    end

    // Stimulus: several patterns, including overlapping
    task apply_pattern(input logic [31:0] bits, input int len, input string name);
        int i;
        $display("\n=== Pattern %s (length=%0d) ===", name, len);
        for (i = 0; i < len; i++) begin
            // drive from MSB downwards so 32'b1011 means ...00001011
            in_bit = bits[len-1 - i];
            @(posedge clk);
            $display("t=%0t ns, bit=%0d, exp=%0b, dut=%0b",
                    $time, in_bit, exp_detect, seq_detected);
        end
    endtask

    initial begin
        @(posedge rst_n);

        // 1) Single hit: 1011
        apply_pattern(32'b1011, 4, "single_1011");

        // 2) Overlap: 10111 -> should detect at bit 4 and 5
        apply_pattern(32'b10111, 5, "overlap_10111");

        // 3) Another overlap: 1011011
        apply_pattern(32'b1011011, 7, "overlap_1011011");

        // 4) Mixed noise + valid sequences
        apply_pattern(32'b00101101011, 11, "mixed");

        #20;
        $finish;
    end

endmodule
