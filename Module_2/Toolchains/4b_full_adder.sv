module full_adder_4bit (
    input logic [3:0] a,
    input logic [3:0] b,
    input logic cin,
    output logic [3:0] sum,
    output logic cout
);

    logic [4:0] result;
   
    initial begin
  	$dumpfile ("waveforms.vcd");
  	$dumpvars (0, full_adder_4bit);
  	#1;
    end

    assign result = a + b + cin;
    
    assign sum = result[3:0];
    assign cout = result[4];

endmodule
