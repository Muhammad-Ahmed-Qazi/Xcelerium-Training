//------------------------------------------------------------------------------
// Module: 32-bit Barrel Shifter
// Description:
//   This is a 32-bit Barrel Shifter module that performs
//   logical left and right shifts based on the control signals.
//
// Author      : Muhammad Ahmed Qazi
// Date        : 2025-12-16
//------------------------------------------------------------------------------

module barrel_shifter_32bit #(
	
	// Parameter declarations
	parameter integer DATA_WIDTH = 32,
    parameter integer SHIFT_WIDTH = 5
	)(
	
	// Port declarations
	input   [DATA_WIDTH - 1:0]  data_in,
    input   [SHIFT_WIDTH - 1:0] shift_amount,
    input                       dir,
	
    output  [DATA_WIDTH - 1:0]  data_out
    );

	// Internal signals for stage outputs
    wire [DATA_WIDTH - 1:0] stage0_out;
    wire [DATA_WIDTH - 1:0] stage1_out;
    wire [DATA_WIDTH - 1:0] stage2_out;
    wire [DATA_WIDTH - 1:0] stage3_out;
    wire [DATA_WIDTH - 1:0] stage4_out;

	// Combinatinonal Logic
	
    // Stage 0: Shift by 1
    assign stage0_out = shift_amount[0] ? 
                        (dir ? {data_in[DATA_WIDTH - 2:0], 1'b0} : {1'b0, data_in[DATA_WIDTH - 1:1]}) : 
                        data_in;
    
    // Stage 1: Shift by 2
    assign stage1_out = shift_amount[1] ? 
                        (dir ? {stage0_out[DATA_WIDTH - 3:0], 2'b00} : {2'b00, stage0_out[DATA_WIDTH - 1:2]}) : 
                        stage0_out;

    // Stage 2: Shift by 4
    assign stage2_out = shift_amount[2] ? 
                        (dir ? {stage1_out[DATA_WIDTH - 5:0], 4'b0000} : {4'b0000, stage1_out[DATA_WIDTH - 1:4]}) : 
                        stage1_out;

    // Stage 3: Shift by 8
    assign stage3_out = shift_amount[3] ? 
                        (dir ? {stage2_out[DATA_WIDTH - 9:0], 8'b00000000} : {8'b00000000, stage2_out[DATA_WIDTH - 1:8]}) : 
                        stage2_out;
    
    // Stage 4: Shift by 16
    assign stage4_out = shift_amount[4] ? 
                        (dir ? {stage3_out[DATA_WIDTH - 17:0], 16'b0000000000000000} : {16'b0000000000000000, stage3_out[DATA_WIDTH - 1:16]}) : 
                        stage3_out;
    
    // Final output
    assign data_out = stage4_out;

endmodule


