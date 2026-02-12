`timescale 1ns / 1ps

`include "seq_if.sv"
`include "seq_tb_pkg.sv"
`include "seq_detector.sv"

module seq_detector_tb;

    import seq_tb_pkg::*;

    logic clk;
    logic rst_n;

    // Printing waveform
    initial begin
        $dumpfile("seq_detector.vcd");
        $dumpvars(0, seq_detector_tb);
        $dumpvars(0, seq_detector_tb.dut);
        $dumpvars(0, seq_detector_tb.seq_if_inst);
end


    // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

    // Reset
    initial begin
        rst_n = 0;
        repeat (2) @(posedge clk);
        rst_n = 1;
    end

    // Interface
    seq_if seq_if_inst (clk, rst_n);

    // DUT
    seq_detector dut (
        .clk          (clk),
        .rst_n        (rst_n),
        .in_bit       (seq_if_inst.in_bit),
        .seq_detected (seq_if_inst.seq_detected)
    );

    // Virtual interfaces
    virtual seq_if.DRV drv_if = seq_if_inst;
    virtual seq_if.MON mon_if = seq_if_inst;

    // Mailboxes
    mailbox #(seq_txn) gen2drv_mb = new();
    mailbox #(seq_txn) gen2scb_mb = new();
    mailbox #(seq_txn) mon2scb_mb = new();

    // Components
    seq_gen gen;
    seq_drv drv;
    seq_mon mon;
    seq_scb scb;

    initial begin
        @(posedge rst_n);

        gen = new(gen2drv_mb, gen2scb_mb, 50);
        drv = new(drv_if,      gen2drv_mb);
        mon = new(mon_if,      mon2scb_mb);
        scb = new(gen2scb_mb,  mon2scb_mb);

        fork
            gen.run();
            drv.run();
            mon.run();
            scb.run();
        join_none

        #2000;
        $finish;
    end

endmodule : seq_detector_tb
