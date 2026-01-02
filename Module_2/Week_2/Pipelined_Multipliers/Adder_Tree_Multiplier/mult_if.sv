interface mult_if #(
    // Parameter declarations
    parameter DATA_WIDTH = 8
)(
    // Interface ports
    input logic clk,
    input logic rst_n
);

    // DUT pins
    logic                      EA;
    logic                      EB;
    logic                      start;
    logic [DATA_WIDTH-1:0]     A_in;
    logic [DATA_WIDTH-1:0]     B_in;
    logic [2*DATA_WIDTH-1:0]   P_out;
    logic                      P_out_valid;

    // ------------------------------------------------
    // Clocking block
    // ------------------------------------------------
    clocking cb @(posedge clk);
        // Sample slightly after clock edge, drive at clock edge
        default input #1step output #0;
        output EA, EB, start, A_in, B_in;
        input  P_out, P_out_valid;
    endclocking

    // ------------------------------------------------
    // Modports
    // ------------------------------------------------
    // RTL DUT view: directions from DUT perspective
    modport DUT (
        input  clk, rst_n, EA, EB, start, A_in, B_in,
        output P_out, P_out_valid
    );

    // Driver view: TB drives inputs, reads outputs, uses cb
    modport DRV (
        input clk, rst_n, P_out, P_out_valid,
        output EA, EB, start, A_in, B_in,
        clocking cb
    );
    
    // Monitor view: TB reads outputs, uses cb
    modport MON (
        input clk, rst_n, EA, EB, start, A_in, B_in, P_out, P_out_valid,
        clocking cb
    );

endinterface