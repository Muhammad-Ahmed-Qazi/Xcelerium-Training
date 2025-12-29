`timescale 1ns/1ps

module counter_tb;

    localparam int W = 8;

    // -------------------------
    // Signals
    // -------------------------
    logic clk;
    logic rst_n;
    logic en;
    logic up_dn;
    logic [W-1:0] count;

    // Reference model
    logic [W-1:0] ref_count;

    // -------------------------
    // DUT
    // -------------------------
    counter #(.COUNT_WIDTH(W)) dut (
        .clk   (clk),
        .rst_n (rst_n),
        .en    (en),
        .up_dn (up_dn),
        .count (count)
    );

    // -------------------------
    // Printing waveform
    // -------------------------
    initial begin
        $dumpfile("counter.vcd");
        $dumpvars(0, counter_tb);
    end

    // -------------------------
    // Clock
    // -------------------------
    always #5 clk <= ~clk;

    // -------------------------
    // Reset task
    // -------------------------
    task apply_reset;
    begin
        rst_n = 0;
        en = 0;
        up_dn = 0;
        ref_count = 0;
        repeat (2) @(posedge clk);
        rst_n = 1;
    end
    endtask

    // -------------------------
    // Driver tasks
    // -------------------------
    task count_up;
    begin
        @(posedge clk);
        en = 1;
        up_dn = 1;
    end
    endtask

    task count_down;
    begin
        @(posedge clk);
        en = 1;
        up_dn = 0;
    end
    endtask

    task hold;
    begin
        @(posedge clk);
        en = 0;
    end
    endtask

    // -------------------------
    // Reference model
    // -------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            ref_count <= 0;
        else if (en) begin
            if (up_dn)
                ref_count <= ref_count + 1;
            else
                ref_count <= ref_count - 1;
        end
    end

    // -------------------------
    // Monitor + checker
    // -------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            $display("T=%0t | RESET | count=%0d (expected 0)",
                    $time, count);
        end
        else if (count === ref_count) begin
            $display("T=%0t | PASS | en=%b up_dn=%b | count=%0d",
                    $time, en, up_dn, count);
        end
        else begin
            $display("T=%0t | FAIL | en=%b up_dn=%b | DUT=%0d REF=%0d Δ=%0d",
                    $time, en, up_dn, count, ref_count,
                    count - ref_count);
            $error("COUNTER MISMATCH");
        end
    end


    // -------------------------
    // Test sequence
    // -------------------------
    initial begin
        clk = 0;
        apply_reset();

        repeat (5) count_up();
        repeat (3) hold();
        repeat (2) count_down();

        #20;
        $finish;
    end

endmodule
