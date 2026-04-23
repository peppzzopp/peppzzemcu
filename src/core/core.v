`include "core_defines.v"

module core(
    input clock,
    input reset,
    
    /*Instruction memory port*/
    output [31:0]imem_address,
    input [31:0]imem_data,

    /*Data memory port*/
    output [31:0]dmem_address,
    output [31:0]dmem_write_data,
    output dmem_write_enable,
    output [3:0]dmem_byte_enable,
    input [31:0]dmem_read_data
);
    
    /*Data Memory*/
    reg [31:0]memory_address;
    reg memory_we;
    
    assign dmem_address = memory_address;
    assign dmem_write_enable = memory_we;

    /*Decoder*/
    wire [6:0]opcode; wire [2:0]func3; wire [6:0]func7;
    wire [4:0]rs1; wire [4:0]rs2; wire [4:0]rsd; wire [31:0]immediate;
    decoder decoder_unit(
        .instruction(imem_data),
        .opcode(opcode),
        .rs1(rs1),
        .rs2(rs2),
        .rsd(rsd),
        .func3(func3),
        .func7(func7),
        .immediate(immediate)
    );
    
    /*Program Counter*/
    reg [31:0]pc_data; reg pc_load;
    wire [31:0]pc_plus_4;
    program_counter pc_unit(
        .reset(reset),
        .clock(clock),
        .load(pc_load),
        .pc_data(pc_data),
        .pc_output(imem_address),
        .pc_plus_4(pc_plus_4)
    );
    
    /*Core Registers*/
    reg register_we; reg [31:0] register_write_data;
    wire [31:0]register_r1; wire [31:0]register_r2;
    regfile register_unit(
        .reset(reset),
        .clock(clock),
        .write_enable(register_we),
        .read_1(rs1),
        .read_2(rs2),
        .write(rsd),
        .write_data(register_write_data),
        .read_output_1(register_r1),
        .read_output_2(register_r2)
    );

    /*`ALU*/
    reg [31:0]alu_input_1; reg [31:0]alu_input_2; reg [3:0]alu_op;
    wire [31:0]alu_output;
    alu alu_unit(
        .input_1(alu_input_1),
        .input_2(alu_input_2),
        .alu_op(alu_op),
        .alu_output(alu_output)
    );
    
    /*LSU*/
    reg [1:0]lsu_byte_offset; reg [1:0]lsu_type; reg load_sign;
    wire [31:0]load_data;
    lsu lsu_unit(
        .byte_offset(lsu_byte_offset),
        .lsu_type(lsu_type),
        .memory_input(dmem_read_data),
        .sign(load_sign),
        .load_data(load_data),
        .rs2(register_r2),
        .byte_enable(dmem_byte_enable),
        .store_data(dmem_write_data)
    );

    always@(*)begin
        /*Default signals*/
        pc_load = 1'b0;
        pc_data = 4;

        alu_input_1 = register_r1;
        alu_input_2 = register_r2;
        alu_op = 4'b0000;

        lsu_byte_offset = 2'b00;
        lsu_type = 2'b00;
        load_sign = 1'b0;
        
        register_we = 1'b0;
        register_write_data = 32'h00000000;

        memory_we = 1'b0;
        memory_address = 32'h00000000;

        case(opcode)
            `OP_IMMEDIATE:begin
                alu_input_2 = immediate;
                register_we = 1'b1;
                register_write_data = alu_output;
                case(func3)
                    3'b000:begin
                        alu_op = `ALU_ADD;
                    end
                    3'b010:begin
                        alu_op = `ALU_SLT;
                    end
                    3'b011:begin
                        alu_op = `ALU_SLTU;
                    end
                    3'b100:begin
                        alu_op = `ALU_XOR;
                    end
                    3'b110:begin
                        alu_op = `ALU_OR;
                    end
                    3'b111:begin
                        alu_op = `ALU_AND;
                    end
                    3'b001:begin
                        alu_op = `ALU_SLL;
                    end
                    3'b101:begin
                        alu_op = immediate[10] ? `ALU_SRA : `ALU_SRL;
                    end
                endcase
            end
            `OP_REGISTER:begin
                alu_input_2 = register_r2;
                register_we = 1'b1;
                register_write_data = alu_output;
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
            `OP_JAL:begin
                register_we = 1'b1;
                register_write_data = pc_plus_4;
                pc_data = immediate;
            end
            `OP_JALR:begin
                alu_input_2 = immediate;
                alu_op = `ALU_ADD;
                register_we = 1'b1;
                register_write_data = pc_plus_4;
                pc_load = 1'b1;
                pc_data = {alu_output[31:1], 1'b0};
            end
            `OP_BRANCH:begin
                case(func3)
                    3'b000:begin
                        alu_op = `ALU_XOR;
                        pc_data = (|alu_output) ? 4 : immediate;
                    end
                    3'b001:begin
                        alu_op = `ALU_XOR;
                        pc_data = (|alu_output) ? immediate : 4;
                    end
                    3'b100:begin
                        alu_op = `ALU_SLT;
                        pc_data = (alu_output[0]) ? immediate : 4;
                    end
                    3'b101:begin
                        alu_op = `ALU_SLT;
                        pc_data = (alu_output[0]) ? 4 : immediate;
                    end
                    3'b110:begin
                        alu_op = `ALU_SLTU;
                        pc_data = (alu_output[0]) ? immediate : 4;
                    end
                    3'b111:begin
                        alu_op = `ALU_SLTU;
                        pc_data = (alu_output[0]) ? 4 : immediate;
                    end
                endcase
            end
            `OP_LOAD:begin
                alu_input_2 = immediate;
                alu_op = `ALU_ADD;
                memory_address = {alu_output[31:2], 2'b00};
                lsu_byte_offset = alu_output[1:0];
                register_we = 1'b1;
                register_write_data = load_data;
                case(func3)
                    3'b000: begin
                        lsu_type = 2'b10;
                        load_sign = 1'b1;
                    end
                    3'b001: begin
                        lsu_type = 2'b01;
                        load_sign = 1'b1;
                    end
                    3'b010: begin
                        lsu_type = 2'b00;
                        load_sign = 1'b1;
                    end
                    3'b100: begin
                        lsu_type = 2'b10;
                        load_sign = 1'b0;
                    end
                    3'b101: begin
                        lsu_type = 2'b01;
                        load_sign = 1'b0;
                    end
                endcase
            end
            `OP_STORE:begin
                alu_input_2 = immediate;
                alu_op = `ALU_ADD;
                memory_address = {alu_output[31:2], 2'b00};
                lsu_byte_offset = alu_output[1:0];
                memory_we = 1'b1;
                case(func3)
                    3'b000: lsu_type = 2'b10;
                    3'b001: lsu_type = 2'b01;
                    3'b010: lsu_type = 2'b00;
                endcase
            end
            `OP_LUI:begin
                register_we = 1'b1;
                register_write_data = immediate;
            end
            `OP_AUIPC:begin
                alu_input_1 = imem_address;
                alu_input_2 = immediate;
                alu_op = `ALU_ADD;
                register_we = 1'b1;
                register_write_data = alu_output;
            end
            default:begin
                pc_load = 1'b0;
                pc_data = 4;

                alu_input_1 = register_r1;
                alu_input_2 = register_r2;
                alu_op = 4'b0000;

                lsu_byte_offset = 2'b00;
                lsu_type = 2'b00;
                load_sign = 1'b0;
                
                register_we = 1'b0;
                register_write_data = 32'h00000000;

                memory_we = 1'b0;
                memory_address = 32'h00000000;
            end
        endcase
    end
endmodule
