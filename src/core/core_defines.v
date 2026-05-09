/* ALU operations */
`define ALU_ADD  4'h0
`define ALU_SUB  4'h1
`define ALU_SLT  4'h2
`define ALU_SLTU 4'h3
`define ALU_XOR  4'h4
`define ALU_OR   4'h5
`define ALU_AND  4'h6
`define ALU_CLE  4'h7
`define ALU_SLL  4'h8
`define ALU_SRL  4'h9
`define ALU_SRA  4'hA

/* OPCODES */
`define  OP_IMMEDIATE 7'b0010011
`define  OP_REGISTER 7'b0110011
`define  OP_JAL 7'b1101111
`define  OP_JALR 7'b1100111
`define  OP_BRANCH 7'b1100011
`define  OP_LOAD 7'b0000011
`define  OP_STORE 7'b0100011
`define  OP_LUI 7'b0110111
`define  OP_AUIPC 7'b0010111
`define  OP_FENCE 7'b0001111
`define  OP_SYSTEM 7'b1110011
