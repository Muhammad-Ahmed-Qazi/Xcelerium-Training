module seqDetectorMoore(w, clk, z);
    input w, clk;
    output reg z;

    reg [1:0] state, next_state;

    initial begin
        state = 2'b00;
        next_state = 2'b00;
        z = 1'b0;
    end

    always @(state, w) begin
        case (state)
            2'b00: begin
                if (w == 1'b0)
                    next_state = 2'b00;
                else
                    next_state = 2'b01;
                z = 1'b0;
            end
            2'b01: begin
                if (w == 1'b0)
                    next_state = 2'b00;
                else
                    next_state = 2'b10;
                z = 1'b0;
            end
            2'b10: begin
                if (w == 1'b0)
                    next_state = 2'b00;
                else
                    next_state = 2'b10;
                z = 1'b1;
            end
            default: begin
                next_state = 2'b00;
                z = 1'b0;
            end
        endcase
    end

    always @(posedge clk) begin
        state <= next_state;
    end

endmodule