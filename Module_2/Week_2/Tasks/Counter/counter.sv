//------------------------------------------------------------------------------
// Module: counter
// Description:
//   A synchronous parameterisable counter module with active-low
//   reset, enable, and up/down signals. The counter increments
//   when up_dn is HIGH and decrements when LOW.
//
// Author      : Muhammad Ahmed Qazi
// Date        : 2025-12-23
// Target      : FPGA
// Clocking    : <clk>, <posedge>
// Reset       : <async>, <active low>
//------------------------------------------------------------------------------

`timescale 1ns/1ps
module counter #(
    // Parameter declarations
    parameter integer COUNT_WIDTH = 16
)(
    // Port declarations
    input wire clk,
    input wire                      rst_n,
    input wire                      en,
    input wire                      up_dn,

    output reg [COUNT_WIDTH - 1: 0] count
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            count <= {COUNT_WIDTH{1'b0}};
        else if (en) begin
            if (up_dn) 
                count <= count + 1;       // increment
                // count <= count + {{(COUNT_WIDTH-1){1'b0}}, 1'b1};
            else 
                count <= count - 1;       // decrement
                // count <= count - {{(COUNT_WIDTH-1){1'b0}}, 1'b1};
        end
        // else: hold previous value
    end

endmodule
