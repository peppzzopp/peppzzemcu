module alu(
    input wire [31:0] operand_1,
    input wire [31:0] operand_2,
    input wire is_sub,shift_direction, operation,
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
        .carry_in(is_sub),
        .sum(addition_result),
        .carry_out(addition_result_carry)
    );
    SHIFT shifter(
        .a(operand_1),
        .shift(shift),
        .direction(shift_direction),
        .out(shift_result)
    );
    always @(*) begin
        case (operation)
            1'b0: begin
                result = addition_result;
            end

            default: begin
                result = shift_result;
            end
        endcase

        Zer = (result == 32'b0);
        Neg = result[31];
        Pos = ~result[31];
    end
endmodule
