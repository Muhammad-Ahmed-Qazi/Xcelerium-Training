`timescale 1ns/1ps

module shift_reg_tb;

    // -------------------------
    // Parameters
    // -------------------------
    localparam int DATA_WIDTH = 8;

    // -------------------------
    // Signals
    // -------------------------
    logic clk;
    logic rst_n;
    logic shift_en;
    logic dir;
    logic d_in;
    logic [DATA_WIDTH-1:0] q_out;

    // Reference model
    logic [DATA_WIDTH-1:0] ref_q;

    // -------------------------
    // DUT instantiation (Layer 1)
    // -------------------------
    shift_reg #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk      (clk),
        .rst_n    (rst_n),
        .shift_en (shift_en),
        .dir      (dir),
        .d_in     (d_in),
        .q_out    (q_out)
    );

    // -------------------------
    // Clock generator (Layer 2)
    // -------------------------
    always #5 clk <= ~clk;

    // -------------------------
    // Pringing waveform
    // -------------------------
    initial begin
        $dumpfile("shift_reg.vcd");
        $dumpvars(0, shift_reg_tb);
    end

    // -------------------------
    // Reset task (Layer 2)
    // -------------------------
    task apply_reset;
    begin
        rst_n    = 0;
        shift_en = 0;
        dir      = 0;
        d_in     = 0;
        ref_q    = 0;
        repeat (2) @(posedge clk);
        rst_n = 1;
    end
    endtask

    // -------------------------
    // Driver tasks (Layer 3)
    // -------------------------
    task shift_left(input logic din);
    begin
        @(posedge clk);
        shift_en = 1;
        dir = 0;
        d_in = din;
    end
    endtask

    task shift_right(input logic din);
    begin
        @(posedge clk);
        shift_en = 1;
        dir = 1;
        d_in = din;
    end
    endtask

    task hold;
    begin
        @(posedge clk);
        shift_en = 0;
    end
    endtask

    // -------------------------
    // Reference model (Layer 5)
    // -------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            ref_q <= '0;
        else if (shift_en) begin
            if (dir == 0)
                ref_q <= {ref_q[DATA_WIDTH-2:0], d_in};
            else
                ref_q <= {d_in, ref_q[DATA_WIDTH-1:1]};
        end
    end

    // -------------------------
    // Monitor + checker (Layer 4 + 5)
    // -------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            $display("T=%0t | RESET | q_out=%b (expected 0)",
                    $time, q_out);
        end
        else if (q_out === ref_q) begin
            $display("T=%0t | PASS | en=%b dir=%b din=%b | q_out=%b",
                    $time, shift_en, dir, d_in, q_out);
        end
        else begin
            $display("T=%0t | FAIL | en=%b dir=%b din=%b | DUT=%b REF=%b",
                    $time, shift_en, dir, d_in, q_out, ref_q);
            $error("SHIFT REGISTER MISMATCH");
        end
    end


    // -------------------------
    // Test scenario (Layer 6)
    // -------------------------
    initial begin
        clk = 0;
        apply_reset();

        // Shift left: 1 0 1 1
        shift_left(1);
        shift_left(0);
        shift_left(1);
        shift_left(1);

        hold();
        hold();

        // Shift right: 1 1 0
        shift_right(1);
        shift_right(1);
        shift_right(0);

        #20;
        $finish;
    end

    // Printing waveform
    initial begin
        $dumpfile("shift_reg.vcd");
        $dumpvars(0, shift_reg_tb);
    end

endmodule
