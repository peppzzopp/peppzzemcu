module alu(
    input wire [31:0] operand_1,
    input wire [31:0] operand_2,
    input wire carry_in_direction, operation,
    input wire [4:0] shift,
    output wire [31:0] result,
    output Neg, Zer, Pos
);
    wire [31:0] addition_result;
    wire addition_result_carry;
    wire [31:0] shift_result;
    ADD add_subtract(
        .a(operand_1),
        .b(operand_2),
        .carry_in(carry_in_direction),
        .sum(addition_result),
        .carry_out(addition_result_carry)
    );
    SHIFT shifter(
        .a(operand_1),
        .shift(shift),
        .direction(carry_in_direction),
        .out(shift_result)
    );

    case (operation)
        0 : begin 
            assign result = addition_result;
        end
        default : begin 
            assign result = shift_result;
        end
    endcase
endmodule