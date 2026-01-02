package mult_tb_pkg;

    // Global TB parameters
    localparam int DATA_WIDTH = 8;
    localparam int PROD_WIDTH = 2 * DATA_WIDTH;

    // Forward-declare interface types to use as virtual IFs
    typedef virtual mult_if #(.DATA_WIDTH(DATA_WIDTH)).DRV drv_vif_t;
    typedef virtual mult_if #(.DATA_WIDTH(DATA_WIDTH)).MON mon_vif_t;

    // -----------------------------------------------------
    // Transaction
    // -----------------------------------------------------
    class mult_txn;

        rand bit [DATA_WIDTH-1:0] a;
        rand bit [DATA_WIDTH-1:0] b;
             bit [PROD_WIDTH-1:0] prod;

        // Constraint to avoid trivial cases
        constraint non_trivial_c { !(a==0) && (b==0); }

        // Function to calculate expected product
        function void post_randomise();
            prod = a * b;
        endfunction

        function void display(string tag="");
            $display("[%s] txn: a=%0d, b=%0d, prod=%0d", tag, a, b, prod);
        endfunction

    endclass

    // -----------------------------------------------------
    // Generator
    // -----------------------------------------------------
    class mult_gen;
    
        mailbox #(mult_txn) gen2drv_mb;
        mailbox #(mult_txn) gen2scb_mb;
        int unsigned        num_txn;

        function new(mailbox #(mult_txn) gen2drv_mb,
                     mailbox #(mult_txn) gen2scb_mb,
                     int unsigned        num_txn=10);
            this.gen2drv_mb = gen2drv_mb;
            this.gen2scb_mb = gen2scb_mb;
            this.num_txn     = num_txn;
        endfunction

        task run();
            mult_txn t;
            repeat (num_txn) begin
                t = new();
                assert (t.randomize())
                    else $fatal("mult_gen: randomisation failed.");

                gen2drv_mb.put(t);
                gen2scb_mb.put(t); 
            end
        endtask

    endclass

    // -----------------------------------------------------
    // Driver
    // -----------------------------------------------------
    class mult_drv;
            
        drv_vif_t           vif;
        mailbox #(mult_txn) gen2drv_mb;

        function new(drv_vif_t           vif,
                     mailbox #(mult_txn) gen2drv_mb);
            this.vif         = vif;
            this.gen2drv_mb = gen2drv_mb;
        endfunction

        task reset_signals();
            vif.cb.EA       <= 0;
            vif.cb.EB       <= 0;
            vif.cb.start    <= 0;
            vif.cb.A_in     <= '0;
            vif.cb.B_in     <= '0;
        endtask

        task run();
            mult_txn t;
            reset_signals();

            forever begin
                gen2drv_mb.get(t);

                // 1st clk: drive operands and start pulse
                @(vif.cb);
                vif.cb.A_in   <= t.a;
                vif.cb.B_in   <= t.b;
                vif.cb.EA     <= 1;
                vif.cb.EB     <= 1;
                vif.cb.start  <= 1;

                // 2nd clk: de-assert control
                @(vif.cb);
                vif.cb.EA     <= 0;
                vif.cb.EB     <= 0;
                vif.cb.start  <= 0;
            end
        endtask

    endclass

    // -----------------------------------------------------
    // Monitor (with functional coverage)
    // -----------------------------------------------------
    class mult_mon;

        mon_vif_t           vif;
        mailbox #(mult_txn) mon2scb_mb;
        
        // Coverage on observed DUT behaviour
        covergroup cg_mult @(vif.cb);
            cp_a : coverpoint vif.cb.A_in {
                option.auto_bin_max = 16;
            }
            cp_b : coverpoint vif.cb.B_in {
                option.auto_bin_max = 16;
            }
            x_ab : cross cp_a, cp_b;
        endgroup

        function new(mon_vif_t           vif,
                     mailbox #(mult_txn) mon2scb_mb);
            this.vif         = vif;
            this.mon2scb_mb = mon2scb_mb;
            cg_mult = new();
        endfunction

        task run();
            mult_txn t;

            forever begin
                @(vif.cb);
                if (vif.cb.P_out_valid) begin
                    cg_mult.sample();
                    t      = new();
                    // Capture operands as seen at interface and DUT output
                    t.a    = vif.cb.A_in;
                    t.b    = vif.cb.B_in;
                    t.prod = vif.cb.P_out;
                    mon2scb_mb.put(t);
                end
            end
        endtask

    endclass

    // -----------------------------------------------------
    // Scoreboard
    // -----------------------------------------------------
    class mult_scb;

        mailbox #(mult_txn) gen2scb_mb; // expected
        mailbox #(mult_txn) mon2scb_mb; // actual

        function new(mailbox #(mult_txn) gen2scb_mb,
                     mailbox #(mult_txn) mon2scb_mb);
            this.gen2scb_mb = gen2scb_mb;
            this.mon2scb_mb = mon2scb_mb;
        endfunction

        task run();
            mult_txn exp_txn, act_txn;
            int unsigned test_num = 0;

            forever begin
                gen2scb_mb.get(exp_txn);
                mon2scb_mb.get(act_txn);
                test_num++;

                if (act_txn.prod == exp_txn.prod)
                    $display("[PASS] %0d: a=%0d b=%0d exp=%0d got=%0d",
                             test_num, exp_txn.a, exp_txn.b,
                             exp_txn.prod, act_txn.prod);
                else
                    $display("[FAIL] %0d: a=%0d b=%0d exp=%0d got=%0d",
                             test_num, exp_txn.a, exp_txn.b,
                             exp_txn.prod, act_txn.prod);
            end
        endtask

    endclass

endpackage