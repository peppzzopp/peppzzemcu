`include "core_defines.v"

module adder(
    input [31:0]input_1,
    input [31:0]input_2,
    input carry_in,
    output [31:0]output_sum,
    output carry_out
);
    wire [31:0]second_argument;
    assign second_argument = input_2^{32{carry_in}};
    assign {carry_out,output_sum} = input_1+second_argument+carry_in;
endmodule

module shifter(
    input [31:0]input_1,
    input [4:0]shamt,
    input [1:0]type_of_shift,
    output reg [31:0]output_shift
);
    always@(*)begin
        case(type_of_shift)
            2'b00:begin
                output_shift = input_1 << shamt;
            end
            2'b01:begin
                output_shift = input_1 >> shamt;
            end
            default:begin
                output_shift = $signed(input_1) >>> shamt;
            end
        endcase
    end
endmodule

module bitwise(
    input [31:0]input_1,
    input [31:0]input_2,
    input [1:0]type_of_operation,
    output reg [31:0]output_logic
);
    always@(*)begin
        case(type_of_operation)
            2'b00:begin
                output_logic = input_1 ^ input_2;
            end
            2'b01:begin
                output_logic = input_1 & input_2;
            end
            default:begin
                output_logic = input_1 | input_2;
            end
        endcase
    end
endmodule

module alu(
    input [31:0]input_1,
    input [31:0]input_2,
    input [3:0]alu_op,
    output reg [31:0]alu_output
);
    reg adder_carry_in;
    wire [31:0]adder_output; wire adder_carry_out;
    adder adder_unit(
        .input_1(input_1),
        .input_2(input_2),
        .carry_in(adder_carry_in),
        .output_sum(adder_output),
        .carry_out(adder_carry_out)
    );
    
    wire [31:0]shift_output; reg [1:0]type_of_shift;
    shifter shift_unit(
        .input_1(input_1),
        .shamt(input_2[4:0]),
        .type_of_shift(type_of_shift),
        .output_shift(shift_output)
    );
    
    wire [31:0]logic_output; reg [1:0]type_of_operation;
    bitwise logic_unit(
        .input_1(input_1),
        .input_2(input_2),
        .type_of_operation(type_of_operation),
        .output_logic(logic_output)
    );

    always@(*)begin
        adder_carry_in = 1'b0;
        type_of_shift = 2'b00;
        type_of_operation = 2'b00;
        case(alu_op)
            `ALU_ADD:begin
                alu_output = adder_output;
            end
            `ALU_SUB:begin
                adder_carry_in = 1'b1;
                alu_output = adder_output;
            end
            `ALU_SLT:begin
                adder_carry_in = 1'b1;
                alu_output = (input_1[31]^input_2[31]) ? {{31{1'b0}},input_1[31]} : {{31{1'b0}},~adder_carry_out};
            end
            `ALU_SLTU:begin
                adder_carry_in = 1'b1;
                alu_output = {{31{1'b0}},~adder_carry_out};
            end
            `ALU_XOR:begin
                type_of_operation = 2'b00;
                alu_output = logic_output;
            end
            `ALU_OR:begin
                type_of_operation = 2'b10;
                alu_output = logic_output;
            end
            `ALU_AND:begin
                type_of_operation = 2'b01;
                alu_output = logic_output;
            end
            `ALU_SLL:begin
                type_of_shift = 2'b00;
                alu_output = shift_output;
            end
            `ALU_SRL:begin
                type_of_shift = 2'b01;
                alu_output = shift_output;
            end
            `ALU_SRA:begin
                type_of_shift = 2'b10;
                alu_output = shift_output;
            end
            default:begin
                alu_output = 32'h00000000;
            end
        endcase
    end
endmodule
