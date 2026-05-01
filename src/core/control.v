`include "core_defines.v"

module control(
    input clock,
    input reset,
    input stall,
    input [6:0]opcode,
    input [2:0]func3,
    input [6:0]func7,
    input alu_con,
    
    output reg ir_write,
    output reg pc_write,
    output reg reg_write,
    output reg mem_write,
    output reg ret_write,
    
    output reg [1:0]alu_src_a, 
    output reg [1:0]alu_src_b,
    output reg [3:0]alu_op,
    output reg [1:0]reg_src,
    output reg pc_src,
    output reg in_fetch,
    output reg in_memory
);

    parameter FETCH = 3'b000, DECODE = 3'b001, EXECUTE = 3'b010, MEMORY = 3'b011, WRITEBACK = 3'b100;
    reg [2:0] state, next_state;

    always @(posedge clock) begin
        if (reset) state <= FETCH;
        else begin
            if(!stall) state <= next_state;
        end
    end

    always @(*) begin
        case(state)
            FETCH:  next_state = DECODE;
            DECODE: next_state = EXECUTE;
            EXECUTE: begin
                if (opcode == `OP_LOAD || opcode == `OP_STORE)
                    next_state = MEMORY;
                else if (opcode == `OP_BRANCH)
                    next_state = FETCH;
                else
                    next_state = WRITEBACK;
            end
            MEMORY: begin
                if (opcode == `OP_LOAD) next_state = WRITEBACK;
                else next_state = FETCH;
            end
            WRITEBACK: next_state = FETCH;
            default: next_state = FETCH;
        endcase
    end

    always @(*) begin
        ir_write = 1'b0;
        pc_write = 1'b0;
        reg_write = 1'b0;
        mem_write = 1'b0;
        ret_write = 1'b0;
        alu_src_a = 2'b00;
        alu_src_b = 2'b00;
        alu_op = `ALU_ADD;
        reg_src = 2'b00;
        pc_src = 1'b0;
        in_fetch = 1'b0;
        in_memory = 1'b0;

        case(state)
            FETCH: begin
                ir_write = 1'b1;
                pc_write = 1'b1;
                ret_write = 1'b1;
                alu_src_a = 2'b01;
                alu_src_b = 2'b10;
                alu_op = `ALU_ADD;

                in_fetch = 1'b1;
            end
            DECODE: begin
                alu_src_a = 2'b10;
                alu_src_b = 2'b01;
                alu_op = `ALU_ADD;
            end
            EXECUTE: begin
                case(opcode)
                    `OP_REGISTER:begin
                        case(func3)
                            3'b000: alu_op = func7[5] ? `ALU_SUB : `ALU_ADD;
                            3'b001: alu_op = `ALU_SLL;
                            3'b010: alu_op = `ALU_SLT;
                            3'b011: alu_op = `ALU_SLTU;
                            3'b100: alu_op = `ALU_XOR;
                            3'b101: alu_op = func7[5] ? `ALU_SRA : `ALU_SRL;
                            3'b110: alu_op = `ALU_OR;
                            3'b111: alu_op = `ALU_AND;
                        endcase
                    end
                    `OP_IMMEDIATE:begin
                        alu_src_b = 2'b01;
                        case(func3)
                            3'b000: alu_op = `ALU_ADD;
                            3'b001: alu_op = `ALU_SLL;
                            3'b010: alu_op = `ALU_SLT;
                            3'b011: alu_op = `ALU_SLTU;
                            3'b100: alu_op = `ALU_XOR;
                            3'b101: alu_op = func7[5] ? `ALU_SRA : `ALU_SRL;
                            3'b110: alu_op = `ALU_OR;
                            3'b111: alu_op = `ALU_AND;
                        endcase
                    end
                    `OP_BRANCH:begin
                        pc_src = 1'b1;
                        case(func3)
                            3'b000:begin
                                alu_op = `ALU_XOR;
                                pc_write = (alu_con) ? 1'b0 : 1'b1;
                            end
                            3'b001:begin
                                alu_op = `ALU_XOR;
                                pc_write = (alu_con) ? 1'b1 : 1'b0;
                            end
                            3'b100:begin
                                alu_op = `ALU_SLT;
                                pc_write = (alu_con) ? 1'b1 : 1'b0;
                            end
                            3'b101:begin
                                alu_op = `ALU_SLT;
                                pc_write = (alu_con) ? 1'b0 : 1'b1;
                            end
                            3'b110:begin
                                alu_op = `ALU_SLTU;
                                pc_write = (alu_con) ? 1'b1 : 1'b0;
                            end
                            3'b111:begin
                                alu_op = `ALU_SLTU;
                                pc_write = (alu_con) ? 1'b0 : 1'b1;
                            end
                        endcase
                    end
                    `OP_JAL:begin
                        pc_write = 1'b1;
                        pc_src = 1'b1;
                    end
                    `OP_JALR:begin
                        pc_write = 1'b1;
                        pc_src = 1'b0;
                        alu_src_b = 2'b01;
                        alu_op = `ALU_ADD;
                    end
                    `OP_LOAD, `OP_STORE:begin
                        alu_src_b = 2'b01;
                        alu_op = `ALU_ADD;
                    end
                    `OP_LUI:begin
                    end
                    `OP_AUIPC:begin
                        alu_src_a = 2'b10;
                        alu_src_b = 2'b01;
                        alu_op = `ALU_ADD;
                    end
                endcase
            end
            MEMORY: begin
                in_memory = 1'b1;
                if (opcode == `OP_STORE) mem_write = 1'b1;
            end
            WRITEBACK: begin
                reg_write = 1'b1;
                if(opcode == `OP_LOAD) reg_src = 2'b01;
                else if((opcode == `OP_JAL) || (opcode == `OP_JALR)) reg_src = 2'b10;
                else if(opcode == `OP_LUI) reg_src = 2'b11;
                else reg_src = 2'b00;
            end
        endcase
    end
endmodule
