interface seq_if (
    input logic clk,
    input logic rst_n
);
    logic in_bit;
    logic seq_detected;

    // DUT view
    modport DUT (
        input clk, rst_n, in_bit,
        output seq_detected
    );

    // Driver view
    modport DRV (
        input clk, rst_n, seq_detected,
        output in_bit
    );

    // Monitor view
    modport MON (
        input clk, rst_n, in_bit, seq_detected
    );
    
endinterface
