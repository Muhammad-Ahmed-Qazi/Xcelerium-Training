module manchesterMealy(w, clk, z);
    input w, clk;
    output z;

    reg z;
    reg [1:0] state, nextstate;

    initial begin
        state = 2'b00;
        nextstate = 2'b00;
        z = 1'b0;
    end

    always @(state, w) begin
        case (state)
            2'b00: begin
                if (w == 1'b0) begin
                    nextstate = 2'b01;
                    z = 1'b0;
                end else begin
                    nextstate = 2'b10;
                    z = 1'b1;
                end
            end
            2'b01: begin
                if (w == 1'b0) begin
                    nextstate = 2'b00;
                    z = 1'b1;
                end else begin
                    nextstate = 2'b10;
                    z = 1'b1;
                end
            end
            2'b10: begin
                if (w == 1'b0) begin
                    nextstate = 2'b01;
                    z = 1'b0;
                end else begin
                    nextstate = 2'b00;
                    z = 1'b0;
                end
            end
            default: begin
                nextstate = 2'b00;
                z = 1'b0;
            end
        endcase
    end

    always @(posedge clk) begin
        state <= nextstate;
    end

endmodule