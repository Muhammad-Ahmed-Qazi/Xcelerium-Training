//------------------------------------------------------------------------------
// Module: encoder_8to3
// Description:
//   Priority encoder with 8 inputs and 3 outputs. Works on high priority
//   concept, i.e., if multiple inputs are active, output would be according
//   to the most significant input.
//
// Author      : Muhammad Ahmed Qazi
// Date        : 2025-12-18
//------------------------------------------------------------------------------

module encoder #(

	// Parameter declarations
	parameter integer INP_WIDTH = 8,
		parameter integer OUP_WIDTH = 3
		)(

			// Port declarations
			input  [INP_WIDTH - 1: 0] in,
			input                     en,

			output [OUP_WIDTH - 1: 0] out,
			output                    gs,
			output                    e0
			);

			// Internal signals
			reg [OUP_WIDTH - 1: 0] reg_out;
			reg                   reg_gs;
			reg                   reg_e0;

			// Functionality
			always @(*) begin

				// Default assignments
				reg_out = {OUP_WIDTH{1'b0}};
				reg_gs = 1'b0;
				reg_e0 = 1'b0;

				if (en) begin
				if      (in[7]) begin
					reg_out  = 3'b111;
					reg_gs  = 1'b1;
				end
				else if (in[6]) begin
					reg_out  = 3'b110;
					reg_gs  = 1'b1;
				end
				else if (in[5]) begin
					reg_out  = 3'b101;
					reg_gs  = 1'b1;
				end
				else if (in[4]) begin
					reg_out  = 3'b100;
					reg_gs  = 1'b1;
				end
				else if (in[3]) begin
					reg_out  = 3'b011;
					reg_gs  = 1'b1;
				end
				else if (in[2]) begin
					reg_out  = 3'b010;
					reg_gs  = 1'b1;
				end
				else if (in[1]) begin
					reg_out  = 3'b001;
					reg_gs  = 1'b1;
				end
				else if (in[0]) begin
					reg_out  = 3'b000;
					reg_gs  = 1'b1;
				end
				else            begin
					reg_out  = 3'b000;
					reg_e0  = 1'b1;
				end
			end
		end

		assign out = reg_out;
		assign gs = reg_gs;
		assign e0 = reg_e0;

endmodule
