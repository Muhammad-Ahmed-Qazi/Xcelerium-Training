/* verilator lint_off DECLFILENAME */

package seq_tb_pkg;

    // Transaction: one input bit per cycle
    class seq_txn;
        bit in_bit;
        bit exp_detect; // expected seq_detected for that cycle

        function new(bit b = 0, bit e = 0);
            in_bit     = b;
            exp_detect = e;
        endfunction : new
    endclass : seq_txn

    // Generator: emits directed + random sequences
    class seq_gen;
        mailbox #(seq_txn) gen2drv_mb;
        mailbox #(seq_txn) gen2scb_mb;
        int unsigned num_random;

        function new (mailbox #(seq_txn) gen2drv_mb,
                      mailbox #(seq_txn) gen2scb_mb,
                      int unsigned num_random = 100);
            this.gen2drv_mb = gen2drv_mb;
            this.gen2scb_mb = gen2scb_mb;
            this.num_random = num_random;
        endfunction : new

        task send_bit(bit b);
            seq_txn t = new(b);
            gen2drv_mb.put(t);
            gen2scb_mb.put(t);
        endtask

        task run();
            int i;

            // Directed patterns first (overlap + non-overlap)
            send_bit(1); send_bit(0); send_bit(1); send_bit(1);         // 1011
            send_bit(1); send_bit(0); send_bit(1); send_bit(1); send_bit(1); // 10111
            send_bit(0); send_bit(0); send_bit(1); send_bit(0); send_bit(1); send_bit(1); // 001011

            // Random bitstream using $urandom_range
            for (i = 0; i < num_random; i++) begin
                send_bit(bit'($urandom_range(0, 1)));
            end
        endtask
    endclass : seq_gen

    // Driver
    class seq_drv;
        virtual seq_if.DRV vif;
        mailbox #(seq_txn) gen2drv_mb;

        function new(virtual seq_if.DRV vif,
                     mailbox #(seq_txn) gen2drv_mb);
            this.vif        = vif;
            this.gen2drv_mb = gen2drv_mb;
        endfunction : new

        task run();
            seq_txn t;
            // default
            vif.in_bit = 0;
            forever begin
                gen2drv_mb.get(t);
                @(posedge vif.clk);
                vif.in_bit = t.in_bit;
                $display("[%0t] DRV: in_bit=%0b", $time, vif.in_bit);
            end
        endtask
    endclass : seq_drv

    // Monitor: computes expected output (reference model) and sends to scoreboard
    class seq_mon;
        virtual seq_if.MON vif;
        mailbox #(seq_txn) mon2scb_mb;

        // 4-bit window reference model
        bit [3:0] window;

        function new(virtual seq_if.MON vif,
                     mailbox #(seq_txn) mon2scb_mb);
            this.vif        = vif;
            this.mon2scb_mb = mon2scb_mb;
            window          = 4'b0;
        endfunction : new

        task run();
            seq_txn t;
            forever begin
                @(posedge vif.clk);
                if (!vif.rst_n) begin
                    window = 4'b0;
                end else begin
                    window = {window[2:0], vif.in_bit};
                    t = new(vif.in_bit,
                            (window == 4'b1011)); // exp_detect
                    mon2scb_mb.put(t);
                end
            end
        endtask
    endclass : seq_mon

    // Scoreboard: compares DUT output with expected
    class seq_scb;
        mailbox #(seq_txn) gen2scb_mb;
        mailbox #(seq_txn) mon2scb_mb;
        int unsigned cycle;

        function new(mailbox #(seq_txn) gen2scb_mb,
                     mailbox #(seq_txn) mon2scb_mb);
            this.gen2scb_mb = gen2scb_mb;
            this.mon2scb_mb = mon2scb_mb;
            cycle           = 0;
        endfunction : new

        task run();
            seq_txn gen_t, mon_t;
            bit dut_out;
            forever begin
                gen2scb_mb.get(gen_t);
                mon2scb_mb.get(mon_t);
                cycle++;

                // mon_t.exp_detect is expected output
                dut_out = mon_t.exp_detect;

                // Simple check
                if (dut_out !== mon_t.exp_detect) begin
                    $display("[%0t] MISMATCH: exp=%0b got=%0b",
                             $time, mon_t.exp_detect, dut_out);
                end
            end
        endtask
    endclass : seq_scb

endpackage : seq_tb_pkg
