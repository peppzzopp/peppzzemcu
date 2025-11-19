`timescale 1ns/1ps   // sets simulation time unit and precision

module tb;
    reg a, b, c;         // testbench drives these (inputs to DUT)
    wire s, co;           // output from DUT

    // Instantiate the module under test (DUT)
    FU_ADDER dut (
        .a(a),
        .b(b),
        .c(c),
        .sum(s),
        .carry(co)
    );

    initial begin
        $display("Time\t a b c| s co");
        $display("----------------");
        // Apply all input combinations
        a = 0; b = 0; c = 0; #10;
        $display("%0t\t %b %b %b| %b %b", $time, a, b, c, s, co);

        a = 0; b = 1; #10;
        $display("%0t\t %b %b %b| %b %b", $time, a, b, c, s, co);

        a = 1; b = 0; #10;
        $display("%0t\t %b %b %b| %b %b", $time, a, b, c, s, co);

        a = 1; b = 1; #10;
        $display("%0t\t %b %b %b| %b %b", $time, a, b, c, s, co);

        $finish;  // end simulation
    end
endmodule
