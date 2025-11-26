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
    output wire [3:0] byte_en
);
    parameter START     = 32'h00000000;
    parameter ADDI      = 32'h00000001;
    parameter ANDI      = 32'h00000002;
    parameter ORI       = 32'h00000003;
    parameter XORI      = 32'h00000004;
    parameter SLTI      = 32'h00000005;
    parameter SLTIU     = 32'h00000006;
    parameter SLLI      = 32'h00000007;
    parameter SRLI      = 32'h00000008;
    parameter SRAI      = 32'h00000009;
    parameter LUI       = 32'h0000000A;
    parameter ADD       = 32'h0000000B;
    parameter AND       = 32'h0000000C;
    parameter OR        = 32'h0000000D;
    parameter XOR       = 32'h0000000E;
    parameter SLT       = 32'h0000000F;
    parameter SLTU      = 32'h00000010;
    parameter SLL       = 32'h00000011;
    parameter SRL       = 32'h00000012;
    parameter SRA       = 32'h00000013;
    parameter JAL       = 32'h00000014;
    parameter JALR      = 32'h00000015;
    parameter BEQ       = 32'h00000016;
    parameter BNE       = 32'h00000017;
    parameter BLT       = 32'h00000018;
    parameter BLTU      = 32'h00000019;
    parameter BGE       = 32'h0000001A;
    parameter BGEU      = 32'h0000001B;
    parameter LB        = 32'h0000001C;
    parameter LH        = 32'h0000001D;
    parameter LW        = 32'h0000001E;
    parameter LBU       = 32'h0000001F;
    parameter LHU       = 32'h00000020;
    parameter SB        = 32'h00000021;
    parameter SH        = 32'h00000022;
    parameter SW        = 32'h00000023;
    parameter FENCE     = 32'h00000024;
    parameter ECALL     = 32'h00000025;
    parameter EBREAK    = 32'h00000026;

    reg [32:0] state;
    reg [32:0] next_state;

    always@ (posedge clk or posedge rst)begin
        if (rst) state <= START;
        else state <= next_state;
    end

    always@ (*)begin
        case (state)
            START : begin
                case ()
            end
        endcase
    end

endmodule