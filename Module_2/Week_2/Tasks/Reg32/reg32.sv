//------------------------------------------------------------------------------
// Module: reg32
// Description:
//   A synchronous 32-bit register module with active-low
//   reset, load (enable) signals, which parallel loads the
//   the input on load HIGH.
//
// Author      : Muhammad Ahmed Qazi
// Date        : 2025-12-23
// Target      : FPGA
// Clocking    : <clk>, <posedge>
// Reset       : <async>, <active low>
//------------------------------------------------------------------------------

module reg32 #(
    // Parameter declarations
    parameter integer DATA_WIDTH = 32
)(
    // Port declarations
    input wire                      clk,
    input wire                      rst_n,
    input wire                      load,
    input wire [DATA_WIDTH - 1: 0]  d,

    output reg [DATA_WIDTH - 1: 0]  q
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            q <= {DATA_WIDTH{1'b0}};   // reset clears register
        end
        else if (load) begin
            q <= d;                    // load new data
        end
        // else: hold previous value
    end

endmodule