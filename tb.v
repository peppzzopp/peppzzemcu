`timescale 1ns/1ps

module tb_full_adder_32;

    reg  [31:0] a, b;
    reg         cin;
    wire [31:0] sum;
    wire        cout;

    // Instantiate DUT
    ADD dut (
        .a(a),
        .b(b),
        .carry_in(cin),
        .sum(sum),
        .carry_out(cout)
    );

    // Check task

    task check;
        input [31:0] ta, tb;
        input        tcin;
        reg   [32:0] expected;
    begin
        // Drive the DUT inputs
        a   = ta;
        b   = tb;
        cin = tcin;
        #1; // wait for ripple adder to settle
        expected = ta + tb + tcin;
        if ({cout, sum} !== expected) begin
            $display("❌ FAIL: a=%h b=%h cin=%b | expected=%h got=%h", 
                      ta, tb, tcin, expected, {cout,sum});
        end else begin
            $display("✔ PASS: a=%h b=%h cin=%b | result=%h", 
                      ta, tb, tcin, {cout,sum});
        end
    end
    endtask
    integer i;

    initial begin
        $display("Starting 32-bit full adder test...");

        // ---- Directed tests ----
        check(32'h00000000, 32'h00000000, 0);
        check(32'hFFFFFFFF, 32'h00000001, 0);
        check(32'h7FFFFFFF, 32'h00000001, 0);
        check(32'hFFFFFFFF, 32'hFFFFFFFF, 1);

        // ---- Random tests ----
        for (i = 0; i < 20; i = i + 1) begin
            a   = $random;
            b   = $random;
            cin = $random % 2;
            #1;
            check(a, b, cin);
        end

        $display("Test complete.");
        $finish;
    end

endmodule

