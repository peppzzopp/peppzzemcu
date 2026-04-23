`timescale 1ns/1ns

module tb;

    reg  [31:0] input_1;
    reg  [31:0] input_2;
    reg         carry_in;

    wire [31:0] output_sum;
    wire        carry_out;

    // Instantiate DUT
    adder uut (
        .input_1(input_1),
        .input_2(input_2),
        .carry_in(carry_in),
        .output_sum(output_sum),
        .carry_out(carry_out)
    );

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0,tb);
        // Test case 1
        input_1 = 32'h00000001;
        input_2 = 32'h00000001;
        carry_in = 0;
        #10;
        $display("Time=%0t | A=%h B=%h Cin=%b | Sum=%h Cout=%b",
              $time, input_1, input_2, carry_in, output_sum, carry_out);

        // Test case 2
        input_1 = 32'hFFFFFFFF;
        input_2 = 32'h00000001;
        carry_in = 0;
        #10;
        $display("Time=%0t | A=%h B=%h Cin=%b | Sum=%h Cout=%b",
              $time, input_1, input_2, carry_in, output_sum, carry_out);
        
        // Test case 3
        input_1 = 32'hAAAAAAAA;
        input_2 = 32'h55555555;
        carry_in = 1;
        #10;
        $display("Time=%0t | A=%h B=%h Cin=%b | Sum=%h Cout=%b",
              $time, input_1, input_2, carry_in, output_sum, carry_out);
        
        $finish;
    end

endmodule

