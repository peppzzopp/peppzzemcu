`include "core_defines.v"

module decoder(
    input [31:0]instruction,
    output [6:0]opcode,
    output [4:0]rs1,
    output [4:0]rs2,
    output [4:0]rsd,
    output [2:0]func3,
    output [6:0]func7,
    output reg [31:0]immediate
);
    assign opcode = instruction[6:0];
    assign func3 = instruction[14:12];
    assign rs1 = instruction[19:15];
    assign rs2 = instruction[24:20];
    assign rsd = instruction[11:7];
    assign func7 = instruction[31:25];

    // Immediate construction.
    always@(*)begin
        case(instruction[6:0])
            `OP_BRANCH: immediate = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            `OP_STORE: immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            `OP_JAL: immediate = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            `OP_LUI,
            `OP_AUIPC: immediate = {instruction[31:12],{12{1'b0}}};
            default: immediate = {{20{instruction[31]}}, instruction[31:20]};
        endcase
    end
endmodule
