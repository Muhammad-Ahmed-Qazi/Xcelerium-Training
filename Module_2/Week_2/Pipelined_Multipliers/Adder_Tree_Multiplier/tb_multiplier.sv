`timescale 1ns/1ps

`include "mult_if.sv"
`include "mult_tb_pkg.sv"

module tb_multiplier;

    import mult_tb_pkg::*;

    // ------------------------------------------------
    // Clock and reset
    // ------------------------------------------------
    logic clk;
    logic rst_n;

    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    initial begin
        rst_n = 0;
        repeat (3) @(posedge clk);
        rst_n = 1;
    end

    // ------------------------------------------------
    // Interface instance
    // ------------------------------------------------
    mult_if #(.DATA_WIDTH(DATA_WIDTH)) mif (
        .clk    (clk),
        .rst_n  (rst_n)
    );

    // -----------------------------------------------------
    // DUT instantiation
    // -----------------------------------------------------
`ifdef ARRAY_MULT
    array_multiplier #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .EA         (mif.EA),
        .EB         (mif.EB),
        .start      (mif.start),
        .A_in       (mif.A_in),
        .B_in       (mif.B_in),
        .P_out      (mif.P_out),
        .P_out_valid(mif.P_out_valid)
    );
`else
    adder_tree_multiplier #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .EA         (mif.EA),
        .EB         (mif.EB),
        .start      (mif.start),
        .A_in       (mif.A_in),
        .B_in       (mif.B_in),
        .P_out      (mif.P_out),
        .P_out_valid(mif.P_out_valid)
    );
`endif

    // -----------------------------------------------------
    // Mailboxes and TB components
    // -----------------------------------------------------
    mailbox #(mult_txn) gen2drv_mb = new();
    mailbox #(mult_txn) gen2scb_mb = new();
    mailbox #(mult_txn) mon2scb_mb = new();

    mult_gen    gen;
    mult_drv    drv;
    mult_mon    mon;
    mult_scb    scb;

    // Bind virutal intefaces using modports
    drv_vif_t drv_vif = mif;
    mon_vif_t mon_vif = mif;

    // Printing waveform
    initial begin
        $dumpfile("tb_multiplier.vcd");
        $dumpvars(0, tb_multiplier);
    end
    
    initial begin
        // Wait for reset de-assertion
        @(posedge rst_n);

        gen = new(gen2drv_mb, gen2scb_mb, 100);
        drv = new(drv_vif, gen2drv_mb);
        mon = new(mon_vif, mon2scb_mb);
        scb = new(gen2scb_mb, mon2scb_mb);

        fork
            gen.run();
            drv.run();
            mon.run();
            scb.run();
        join

        // Finish simulation
        #20000;
        $display("Simulation completed.");
        $finish;
    end

endmodule