//------------------------------------------------------------------------------
// Module: shift_reg
// Description:
//   This module implements a parameterisable bi-directional serial
//   shift register with active-low reset and enable control, capable
//   of shifting left or right on each rising clock edge while
//   inserting serial input data.
//
// Author      : Muhammad Ahmed Qazi
// Date        : 2025-12-24
// Target      : FPGA
// Clocking    : <clk>, <posedge>
// Reset       : <async>, <active low>
//------------------------------------------------------------------------------

`timescale 1ns/1ps
module shift_reg #(
    // Parameter declaration
    parameter integer DATA_WIDTH = 16
)(
    // Port declarations
    input  wire                     clk,        // Clock input
    input  wire                     rst_n,      // Active-low reset
    input  wire                     shift_en,   // Enable signal
    input  wire                     dir,        // Direction: 0 for left, 1 for right
    input  wire                     d_in,       // Serial input data

    output reg  [DATA_WIDTH-1:0]    q_out       // Parallel output data
);
    // Sequential process block
    always @(posedge clk or negedge rst_n) begin
        if (~rst_n)
            q_out <= {DATA_WIDTH{1'b0}};
        else if (shift_en) begin
            if (dir == 1'b0) // Shift left
                q_out <= {q_out[DATA_WIDTH-2:0], d_in};
            else // Shift right
                q_out <= {d_in, q_out[DATA_WIDTH-1:1]};
        end
        // else: retain current value
    end

endmodule
