package uart_tb_pkg;
    `timescale 1ns/1ps
    `default_nettype none

    // ----------------------------
    // Transaction class
    // ----------------------------
    class UART_Transaction;
        logic [7:0] data;

        function new(logic [7:0] data_in = 8'h00);
            this.data = data_in;
        endfunction

        function string to_string();
            return $sformatf("TX Byte: 0x%02h", data);
        endfunction
    endclass

    // ----------------------------
    // Generator: produces random bytes using $urandom
    // ----------------------------
    class Generator;
        mailbox #(UART_Transaction) tx_mbx;

        function new(mailbox #(UART_Transaction) tx_mbx_in);
            this.tx_mbx = tx_mbx_in;
        endfunction

        task generate_bytes(int n_bytes);
            for (int i=0; i<n_bytes; i++) begin
                logic [7:0] rand_byte = logic'( $urandom_range(0,255) );
                UART_Transaction txn = new(rand_byte);
                tx_mbx.put(txn);
                // small delay to avoid overwhelming DUT
                #1ns;
            end
        endtask
    endclass

    // ----------------------------
    // Driver: takes transactions from generator and drives DUT
    // ----------------------------
    class Driver;
        virtual uart_if.dut vif;
        mailbox #(UART_Transaction) tx_mbx;

        function new(virtual uart_if.dut vif_in, mailbox #(UART_Transaction) tx_mbx_in);
            this.vif = vif_in;
            this.tx_mbx = tx_mbx_in;
        endfunction

        task run();
            UART_Transaction txn;
            forever begin
                tx_mbx.get(txn); // blocking get
                @(posedge vif.clk);
                vif.tx_data_in <= txn.data;
                vif.tx_send    <= 1'b1;
                @(posedge vif.clk);
                vif.tx_send    <= 1'b0;
            end
        endtask
    endclass

    // ----------------------------
    // Monitor: observes RX, pushes received bytes into rx_mbx
    // Also tracks functional coverage
    // ----------------------------
    class UART_Monitor;

        virtual uart_if.dut vif;
        mailbox #(UART_Transaction) rx_mbx;

        // Coverage
        logic [3:0] state_hit;                     // 4 states
        logic [3:0][3:0] state_transitions;       // [prev][next]

        function new(virtual uart_if.dut vif_in, mailbox #(UART_Transaction) rx_mbx_in);
            this.vif = vif_in;
            this.rx_mbx = rx_mbx_in;
            state_hit = '0;
            state_transitions = '0;
        endfunction

        task run();
            UART_Transaction txn;
            logic [1:0] prev_state;
            forever begin
                @(posedge vif.clk);
                
                // track FSM state and transitions (using exposed signal)
                state_hit[vif.rx_state] = 1'b1;
                state_transitions[prev_state][vif.rx_state] = 1'b1;
                prev_state = vif.rx_state;

                // capture received data
                if (vif.rx_valid) begin
                    txn = new(vif.rx_data_out);
                    rx_mbx.put(txn);
                end
            end
        endtask

    endclass

    // ----------------------------
    // Scoreboard: compares expected vs received bytes
    // ----------------------------
    class Scoreboard;
        mailbox #(UART_Transaction) tx_mbx;
        mailbox #(UART_Transaction) rx_mbx;

        function new(mailbox #(UART_Transaction) rx_mbx_in, mailbox #(UART_Transaction) tx_mbx_in);
            this.rx_mbx = rx_mbx_in;
            this.tx_mbx = tx_mbx_in;
        endfunction

        task run();
            UART_Transaction txn;
            UART_Transaction rxn;
            forever begin
                rx_mbx.get(rxn);  // blocking get from monitor
                tx_mbx.get(txn);  // blocking get from generator / driver
                if (rxn.data !== txn.data)
                    $error("[%0t] RX MISMATCH: expected 0x%02h got 0x%02h",
                           $time, txn.data, rxn.data);
                else
                    $display("[%0t] RX OK: 0x%02h", $time, rxn.data);
            end
        endtask
    endclass

endpackage
