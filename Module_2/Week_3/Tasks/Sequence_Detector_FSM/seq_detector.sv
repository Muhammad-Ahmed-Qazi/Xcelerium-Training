`timescale 1ns/1ps

module seq_detector (
    input  logic clk,
    input  logic rst_n,
    input  logic in_bit,
    output logic seq_detected
);

    // State encoding
    typedef enum logic [2:0] { 
        S0,     // no match yet
        S1,     // saw '1'
        S2,     // saw '10'
        S3,     // saw '101'
        S4      // saw '1011'
    } state_t;

    state_t current_state, next_state;

    // State register (Sequential)one 
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            current_state <= S0;
        else
            current_state <= next_state;
    end

    // Next-state logic (Combinational)
    always_comb begin
        next_state = current_state;     // default
        
        unique case (current_state)
            S0: next_state = in_bit ? S1: S0;
            S1: next_state = in_bit ? S1: S2;
            S2: next_state = in_bit ? S3: S0;
            S3: next_state = in_bit ? S4: S2;
            S4: next_state = in_bit ? S0: S2;
        endcase
    end

    // Mealy output logic (Combinational)
    always_comb begin
        seq_detected = (current_state == S4) ? 1'b1 : 1'b0;
    end

endmodule
