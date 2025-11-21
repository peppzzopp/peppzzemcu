module DECODER(
    input  wire [31:0] instruction,
    output wire [6:0]  opcode,
    output wire [2:0]  funct3,
    output wire [6:0]  funct7,
    output wire [4:0]  rs1,
    output wire [4:0]  rs2,
    output wire [4:0]  rd,
    output reg  [31:0] imm
);

    // Basic fields
    assign opcode = instruction[6:0];
    assign funct3 = instruction[14:12];
    assign funct7 = instruction[31:25];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign rd     = instruction[11:7];

    always @(*) begin
        case (opcode)

            // I-type: loads, ALU-immediate, JALR, ECALL/EBREAK
            7'b0000011,   // LOAD
            7'b0010011,   // ALU immediate
            7'b1100111,   // JALR
            7'b1110011:   // SYSTEM
                imm = {{20{instruction[31]}}, instruction[31:20]};

            // S-type: stores
            7'b0100011:
                imm = {{20{instruction[31]}},
                       instruction[31:25],
                       instruction[11:7]};

            // B-type: branches
            7'b1100011:
                imm = {{19{instruction[31]}},
                       instruction[31],
                       instruction[7],
                       instruction[30:25],
                       instruction[11:8],
                       1'b0};

            // U-type: LUI, AUIPC
            7'b0110111,   // LUI
            7'b0010111:   // AUIPC
                imm = {instruction[31:12], 12'b0};

            // J-type: JAL
            7'b1101111:
                imm = {{11{instruction[31]}},
                       instruction[31],
                       instruction[19:12],
                       instruction[20],
                       instruction[30:21],
                       1'b0};

            // FENCE, FENCE.I  (special I-type)
            7'b0001111:
                imm = {20'b0, instruction[31:20]};

            default:
                imm = 32'b0;
        endcase
    end

endmodule
