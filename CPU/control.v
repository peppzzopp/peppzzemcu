module CU(
    input clk,rst,
    input wire [6:0]  opcode,
    input wire [2:0]  funct3,
    input wire [6:0]  funct7,
    input wire [4:0]  rs1,
    input wire [4:0]  rs2,
    input wire [4:0]  rd,
    input wire [31:0] imm,
    output wire is_sub,shift_direction, operation,
    output wire [4:0] shift,
);
endmodule