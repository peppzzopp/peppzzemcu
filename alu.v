////////////////////////////////////////////////////////////////////////////// Full adder 1 bit.
module FU_ADDER(
    input a,
    input b,
    input c,
    output sum,
    output carry
);
    assign sum = a ^ b ^ c;
    assign carry = (a & b) | (b & c) | (c & a);
endmodule

//////////////////////////////////////////////////////////////////////////// 32 bit adder.
module ADD(
    input [31:0]a,
    input [31:0]b,
    input carry_in,
    output [31:0]sum,
    output carry_out
);
    wire [32:0] carry;
    assign carry[0] = carry_in;
    genvar i;
    generate 
        for(i=0; i < 32; i=i+1) begin : adder_ripple
            FU_ADDER FA(
                .a(a[i]),
                .b(b[i]),
                .c(carry[i]),
                .sum(sum[i]),
                .carry(carry[i+1])
            );
        end
    endgenerate
    assign carry_out = carry[32];
endmodule

///////////////////////////////////////////////////////////////////////////// Logic unit.
module NOT(
    input [31:0]a,
    output [31:0] not_a
);
    assign not_a[i] = ~a[i];
endmodule

module XOR(
    input [31:0]a,
    input [31:0]b,
    output [31:0]c
);
    assign c = a ^ b;
endmodule

module AND(
    input [31:0]a,
    input [31:0]b,
    output [31:0]c
);
    assign c = a ^ b;
endmodule

module OR(
    input [31:0]a,
    input [31:0]b,
    output [31:0]c
);
    assign c = a ^ b;
endmodule

///////////////////////////////////////////////////////////////////////////// 32 bit Shifter.
module SHIFT (
    input [31:0]a,
    input [4:0]shift,
    input direction,
    output[31:0]out
);
    case (direction)
        0       : assign out = a << shift;
        default : assign out = a >> shift;
    endcase
endmodule

///////////////////////////////////////////////////////////////////////////// 32 bit Comparator.
module COMPARE (
    input [31:0]a,
    input [31:0]b,
    output [1:0]result
);
endmodule
