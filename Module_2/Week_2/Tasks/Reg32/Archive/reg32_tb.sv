module reg32_tb;

    reg         clk;
    reg         rst_n;
    reg         load;
    reg [31:0]  d;
    wire [31:0] q;

    // Instantiate DUT
    reg32 dut (
        .clk   (clk),
        .rst_n (rst_n),
        .load  (load),
        .d     (d),
        .q     (q)
    );

    // Printing waveform
    initial begin
        $dumpfile("reg32.vcd");
        $dumpvars(0, reg32_tb);
    end

    // Clock generation: 10 ns period
    always #5 clk = ~clk;

    initial begin
        // Initial values
        clk  = 0;
        rst_n = 0;
        load = 0;
        d    = 32'h00000000;

        // Apply reset
        #12;
        rst_n = 1;
        $display("Reset released, q = %h (expected 0)", q);

        // Load value
        @(posedge clk);
        load = 1;
        d    = 32'hA5A5A5A5;

        @(posedge clk);
        $display("After load, q = %h (expected A5A5A5A5)", q);

        // Hold value
        load = 0;
        d    = 32'hFFFFFFFF;

        @(posedge clk);
        $display("Hold test, q = %h (expected A5A5A5A5)", q);

        // Reset again
        rst_n = 0;
        @(posedge clk);
        $display("After reset, q = %h (expected 0)", q);

        $display("Testbench completed.");
        $finish;
    end

endmodule
