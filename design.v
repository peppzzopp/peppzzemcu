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

module alu(
    input [31:0]input_1,
    input [31:0]input_2,
    input carry_in,
    input [4:0]shamt,
    input direction,
    input a_or_s,
    output carry_out,
    output [31:0]alu_output
);
    wire [31:0]adder_output_sum; wire adder_carry_out;
    adder adder_unit(
        .input_1(input_1),
        .input_2(input_2),
        .carry_in(carry_in),
        .output_sum(adder_output_sum),
        .carry_out(adder_carry_out)
    );
    
    assign carry_out = adder_carry_out;
    wire [31:0]shift_output;
    assign shift_output = (direction) ? ((carry_in) ? (input_1 >>> shamt) : (input_1 >> shamt)) : (input_1 << shamt);
    assign alu_output = (a_or_s) ? adder_output_sum : shift_output;
endmodule

module regfile(
    input [4:0]read_1,
    input [4:0]read_2,
    input [4:0]write,
    input [31:0]write_data,
    input write_enable,
    input reset,
    input clock,
    output [31:0]read_output_1,
    output [31:0]read_output_2,
    output [1023:0]debug_register_interface
);
    reg [31:0]register_file [0:31];
    wire [1023:0]debug_flat;
    integer i;
    always@(posedge clock)begin
        if(reset==1'b1)begin
            for(i=0; i<32; i=i+1)begin
                register_file[i] <= 32'b0;
            end
        end
        else if(write_enable && (write!=0))begin
            register_file[write] <= write_data;
        end
    end
    assign read_output_1 = (read_1 != 5'b0) ? register_file[read_1] : 32'b0;
    assign read_output_2 = (read_2 != 5'b0) ? register_file[read_2] : 32'b0;
    
    genvar j;
    generate
        for(j=0;j<32;j=j+1)begin:debug
            assign debug_flat[j*32 +: 32] = register_file[j];
        end
    endgenerate
    assign debug_register_interface = debug_flat;
endmodule

module program_counter(
    input reset,
    input clock,
    input [31:0]pc_input,
    output [31:0]pc_output
);
    reg [31:0]program_address;

    always@(posedge clock)begin
        if(reset) program_address <= 32'h80000000;
        else program_address <= pc_input;
    end
    assign pc_output = program_address;
endmodule

module dmem(
    input clock,
    input reset,
    input memory_write,
    input [31:0]memory_address,
    input [31:0]input_data,
    output [31:0]output_data
);

    reg [31:0]ram [0:1023];
    integer i;
    
    always@(posedge clock)begin
        if(reset)begin
            for(i=0;i<1024;i=i+1)begin
                ram[i] <= 32'b0;
            end
        end
        else if(memory_write) begin
            ram[memory_address[11:2]] <= input_data;
        end
    end
    assign output_data = ram[memory_address[11:2]];
endmodule

module imem(
    input [31:0]instruction_address,
    output [31:0]instruction
);
    reg [31:0]instruction_memory [0:255];
    integer i; 
    initial begin
        for(i=0;i<256;i=i+1)begin
            instruction_memory[i] = 32'b0;
        end
        $readmemh("instruction_stream.hex",instruction_memory);
    end
    
    assign instruction = instruction_memory[(instruction_address - 32'h80000000) >> 2];
endmodule

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
            7'b1100011: immediate = {{20{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            7'b0100011: immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            7'b1101111: immediate = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            7'b0110111,
            7'b0010111: immediate = {instruction[31:12],{12{1'b0}}};
            default: immediate = {{20{instruction[31]}}, instruction[31:20]};
        endcase
    end
endmodule

module core(
    input clock,
    input reset,
    output [32*32 - 1:0]debug_register_interface,
    output [31:0]debug_program_counter,
    output [31:0]debug_instruction
);
    wire [31:0]instruction;
    wire [6:0]opcode; wire [4:0]rs1; wire [4:0]rs2; wire [4:0]rsd; wire [2:0]func3; wire [6:0]func7; wire [31:0]immediate;
    decoder decode_unit(
        .instruction(instruction),
        .opcode(opcode),
        .rs1(rs1),
        .rs2(rs2),
        .rsd(rsd),
        .func3(func3),
        .func7(func7),
        .immediate(immediate)
    );
    
    reg [31:0]input_1; reg [31:0]input_2; reg carry_in; wire [31:0]alu_output; wire carry_out;
    reg [4:0]shamt; reg direction; reg a_or_s;
    alu arthematic_logic_unit(
        .input_1(input_1),
        .input_2(input_2),
        .carry_in(carry_in),
        .shamt(shamt),
        .direction(direction),
        .a_or_s(a_or_s),
        .carry_out(carry_out),
        .alu_output(alu_output)
    );
    reg [31:0]pc_input; wire [31:0]pc_output;
    program_counter pc(
        .reset(reset),
        .clock(clock),
        .pc_input(pc_input),
        .pc_output(pc_output)
    );
    
    assign debug_program_counter = pc_output;

    reg memory_write; reg [31:0]memory_address; reg [31:0]memory_input_data;
    wire [31:0]memory_output_data;
    dmem data_memory(
        .clock(clock),
        .reset(reset),
        .memory_write(memory_write),
        .memory_address(memory_address),
        .input_data(memory_input_data),
        .output_data(memory_output_data)
    );
    
    imem instruction_memory(
        .instruction_address(pc_output),
        .instruction(instruction)
    );
    assign debug_instruction = instruction; 

    reg write_enable;
    wire [4:0]read_1; wire [4:0]read_2; wire [4:0]write;
    wire [31:0]read_output_1; wire [31:0]read_output_2; reg [31:0]write_data;
    regfile register_unit(
        .read_1(read_1),
        .read_2(read_2),
        .write(write),
        .write_data(write_data),
        .write_enable(write_enable),
        .reset(reset),
        .clock(clock),
        .read_output_1(read_output_1),
        .read_output_2(read_output_2),
        .debug_register_interface(debug_register_interface)
    );
    assign read_1 = rs1;
    assign read_2 = rs2;
    assign write = rsd;

    always@(*)begin
        case(opcode)
            7'b0010011:begin
                case(func3)
                    3'b000:begin
                        input_1 = read_output_1;
                        input_2 = immediate;
                        carry_in = 1'b0;
                        shamt = 5'b0;
                        direction = 1'b0;
                        a_or_s = 1'b1;
                        write_enable = 1'b1;
                        write_data = alu_output;
                        memory_write = 1'b0;
                        pc_input = pc_output + 4;
                    end
                    3'b010:begin
                        input_1 = read_output_1;
                        input_2 = immediate;
                        carry_in = 1'b1;
                        shamt = 5'b0;
                        direction = 1'b0;
                        a_or_s = 1'b1;
                        write_enable = 1'b1;
                        memory_write = 1'b0;
                        write_data = (read_output_1[31]^immediate[31]) ? {{31{1'b0}},read_output_1[31]} : {{31{1'b0}},~carry_out};
                        pc_input = pc_output + 4;
                    end
                    3'b011:begin
                        input_1 = read_output_1;
                        input_2 = immediate;
                        carry_in = 1'b1;
                        shamt = 5'b0;
                        direction = 1'b0;
                        a_or_s = 1'b1;
                        write_enable = 1'b1;
                        memory_write = 1'b0;
                        write_data = {{31{1'b0}},~carry_out};
                        pc_input = pc_output + 4;
                    end
                    3'b100:begin
                        input_1 = read_output_1;
                        input_2 = immediate;
                        carry_in = 1'b1;
                        shamt = 5'b0;
                        direction = 1'b0;
                        a_or_s = 1'b1;
                        write_enable = 1'b1;
                        memory_write = 1'b0;
                        write_data = read_output_1^immediate;
                        pc_input = pc_output + 4;
                    end
                    3'b110:begin
                        input_1 = read_output_1;
                        input_2 = immediate;
                        carry_in = 1'b1;
                        shamt = 5'b0;
                        direction = 1'b0;
                        a_or_s = 1'b1;
                        write_enable = 1'b1;
                        memory_write = 1'b0;
                        write_data = read_output_1|immediate;
                        pc_input = pc_output + 4;
                    end
                    3'b111:begin
                        input_1 = read_output_1;
                        input_2 = immediate;
                        carry_in = 1'b1;
                        shamt = 5'b0;
                        direction = 1'b0;
                        a_or_s = 1'b1;
                        write_enable = 1'b1;
                        memory_write = 1'b0;
                        write_data = read_output_1&immediate;
                        pc_input = pc_output + 4;
                    end
                    3'b001:begin
                        input_1 = read_output_1;
                        input_2 = immediate;
                        carry_in = 1'b0;
                        shamt = immediate[4:0];
                        direction = 1'b0;
                        a_or_s = 1'b0;
                        write_enable = 1'b1;
                        memory_write = 1'b0;
                        write_data = alu_output;
                        pc_input = pc_output + 4;
                    end
                    3'b101:begin
                        input_1 = read_output_1;
                        input_2 = immediate;
                        carry_in =immediate[10];
                        shamt = immediate[4:0];
                        direction = 1'b1;
                        a_or_s = 1'b0;
                        write_enable = 1'b1;
                        memory_write = 1'b0;
                        write_data = alu_output;
                        pc_input = pc_output + 4;
                    end
                endcase
            end
            7'b0110011:begin
                case(func3)
                    3'b000:begin
                        input_1 = read_output_1;
                        input_2 = read_output_2;
                        carry_in = func7[5];
                        shamt = 5'b0;
                        direction = 1'b0;
                        a_or_s = 1'b1;
                        write_enable = 1'b1;
                        memory_write = 1'b0;
                        write_data = alu_output;
                        pc_input = pc_output + 4;
                    end
                    3'b010:begin
                        input_1 = read_output_1;
                        input_2 = read_output_2;
                        carry_in = 1'b1;
                        shamt = 5'b0;
                        direction = 1'b0;
                        a_or_s = 1'b1;
                        write_enable = 1'b1;
                        memory_write = 1'b0;
                        write_data = (read_output_1[31]^read_output_2[31]) ? {{31{1'b0}},read_output_1[31]} : {{31{1'b0}},~carry_out};
                        pc_input = pc_output + 4;
                    end
                    3'b011:begin
                        input_1 = read_output_1;
                        input_2 = read_output_2;
                        carry_in = 1'b1;
                        shamt = 5'b0;
                        direction = 1'b0;
                        a_or_s = 1'b1;
                        write_enable = 1'b1;
                        memory_write = 1'b0;
                        write_data = {{31{1'b0}},~carry_out};
                        pc_input = pc_output + 4;
                    end
                    3'b100:begin
                        input_1 = read_output_1;
                        input_2 = read_output_2;
                        carry_in = 1'b1;
                        shamt = 5'b0;
                        direction = 1'b0;
                        a_or_s = 1'b1;
                        write_enable = 1'b1;
                        memory_write = 1'b0;
                        write_data = read_output_1^read_output_2;
                        pc_input = pc_output + 4;
                    end
                    3'b110:begin
                        input_1 = read_output_1;
                        input_2 = read_output_2;
                        carry_in = 1'b1;
                        shamt = 5'b0;
                        direction = 1'b0;
                        a_or_s = 1'b1;
                        write_enable = 1'b1;
                        memory_write = 1'b0;
                        write_data = read_output_1|read_output_2;
                        pc_input = pc_output + 4;
                    end
                    3'b111:begin
                        input_1 = read_output_1;
                        input_2 = read_output_2;
                        carry_in = 1'b1;
                        shamt = 5'b0;
                        direction = 1'b0;
                        a_or_s = 1'b1;
                        write_enable = 1'b1;
                        memory_write = 1'b0;
                        write_data = read_output_1&read_output_2;
                        pc_input = pc_output + 4;
                    end
                    3'b001:begin
                        input_1 = read_output_1;
                        input_2 = read_output_2;
                        carry_in = 1'b0;
                        shamt = read_output_2[4:0];
                        direction = 1'b0;
                        a_or_s = 1'b0;
                        write_enable = 1'b1;
                        memory_write = 1'b0;
                        write_data = alu_output;
                        pc_input = pc_output + 4;
                    end
                    3'b101:begin
                        input_1 = read_output_1;
                        input_2 = read_output_2;
                        carry_in = func7[5];
                        shamt = read_output_2[4:0];
                        direction = 1'b1;
                        a_or_s = 1'b0;
                        write_enable = 1'b1;
                        memory_write = 1'b0;
                        write_data = alu_output;
                        pc_input = pc_output + 4;
                    end
                endcase
            end
            7'b1101111:begin
                input_1 = read_output_1;
                input_2 = read_output_2;
                carry_in = 1'b1;
                shamt = 5'b0;
                direction = 1'b0;
                a_or_s = 1'b1;
                write_enable = 1'b1;
                memory_write = 1'b0;
                write_data = pc_output + 4;
                pc_input = pc_output + immediate;
            end
            7'b1100111:begin
                input_1 = read_output_1;
                input_2 = read_output_2;
                carry_in = 1'b1;
                shamt = 5'b0;
                direction = 1'b0;
                a_or_s = 1'b1;
                write_enable = 1'b1;
                memory_write = 1'b0;
                write_data = pc_output + 4;
                pc_input = read_output_1 + immediate;
            end
            7'b1100011:begin
                case(func3)
                    3'b000:begin
                        input_1 = read_output_1;
                        input_2 = read_output_2;
                        carry_in = 1'b1;
                        shamt = 5'b0;
                        direction = 1'b0;
                        a_or_s = 1'b1;
                        write_enable = 1'b0;
                        memory_write = 1'b0;
                        write_data = alu_output;
                        pc_input = (alu_output == 32'b0) ? pc_output + immediate : pc_output + 4;
                    end
                    3'b001:begin
                        input_1 = read_output_1;
                        input_2 = read_output_2;
                        carry_in = 1'b1;
                        shamt = 5'b0;
                        direction = 1'b0;
                        a_or_s = 1'b1;
                        write_enable = 1'b0;
                        memory_write = 1'b0;
                        write_data = alu_output;
                        pc_input = (alu_output == 32'b0) ? pc_output + 4 : pc_output + immediate;
                    end
                    3'b100:begin
                        input_1 = read_output_1;
                        input_2 = read_output_2;
                        carry_in = 1'b1;
                        shamt = 5'b0;
                        direction = 1'b0;
                        a_or_s = 1'b1;
                        write_enable = 1'b0;
                        memory_write = 1'b0;
                        write_data = alu_output;
                        pc_input = (read_output_1[31]^read_output_2[31]) ? ((read_output_1[31]) ? (pc_output + immediate) : (pc_output + 4)) : ((carry_out) ? (pc_output + 4) : (pc_output + immediate));
                    end
                    3'b101:begin
                        input_1 = read_output_1;
                        input_2 = read_output_2;
                        carry_in = 1'b1;
                        shamt = 5'b0;
                        direction = 1'b0;
                        a_or_s = 1'b1;
                        write_enable = 1'b0;
                        memory_write = 1'b0;
                        write_data = alu_output;
                        pc_input = (read_output_1[31]^read_output_2[31]) ? ((read_output_1[31]) ? (pc_output + 4) : (pc_output + immediate)) : ((carry_out) ? (pc_output + immediate) : (pc_output + 4));
                    end
                    3'b110:begin
                        input_1 = read_output_1;
                        input_2 = read_output_2;
                        carry_in = 1'b1;
                        shamt = 5'b0;
                        direction = 1'b0;
                        a_or_s = 1'b1;
                        write_enable = 1'b0;
                        memory_write = 1'b0;
                        write_data = alu_output;
                        pc_input = (carry_out) ? (pc_output + 4) : (pc_output + immediate);
                    end
                    3'b111:begin
                        input_1 = read_output_1;
                        input_2 = read_output_2;
                        carry_in = 1'b1;
                        shamt = 5'b0;
                        direction = 1'b0;
                        a_or_s = 1'b1;
                        write_enable = 1'b0;
                        memory_write = 1'b0;
                        write_data = alu_output;
                        pc_input = (carry_out) ? (pc_output + immediate) : (pc_output + 4);
                    end
                endcase
            end
            7'b0000011:begin
                case(func3)
                    3'b000:begin
                        input_1 = read_output_1;
                        input_2 = read_output_2;
                        carry_in = 1'b0;
                        shamt = 5'b0;
                        direction = 1'b0;
                        a_or_s = 1'b1;
                        memory_write = 1'b0;
                        memory_address = read_output_1 + immediate;
                        write_enable = 1'b1;
                        write_data = (memory_address[1]) ? ((memory_address[0]) ? {{24{memory_output_data[31]}},memory_output_data[31:24]} : {{24{memory_output_data[23]}},memory_output_data[23:16]}) : ((memory_address[0]) ? {{24{memory_output_data[15]}},memory_output_data[15:8]} : {{24{memory_output_data[7]}},memory_output_data[7:0]}); 
                        pc_input = pc_output + 4; 
                    end
                    3'b001:begin
                        input_1 = read_output_1;
                        input_2 = read_output_2;
                        carry_in = 1'b0;
                        shamt = 5'b0;
                        direction = 1'b0;
                        a_or_s = 1'b1;
                        memory_write = 1'b0;
                        memory_address = read_output_1 + immediate;
                        write_enable = 1'b1;
                        write_data = (memory_address[1]) ? {{16{memory_output_data[31]}},memory_output_data[31:16]} : {{16{memory_output_data[15]}},memory_output_data[15:0]}; 
                        pc_input = pc_output + 4; 
                    end
                    3'b010:begin
                        input_1 = read_output_1;
                        input_2 = read_output_2;
                        carry_in = 1'b0;
                        shamt = 5'b0;
                        direction = 1'b0;
                        a_or_s = 1'b1;
                        memory_write = 1'b0;
                        memory_address = read_output_1 + immediate;
                        write_enable = 1'b1;
                        write_data = memory_output_data; 
                        pc_input = pc_output + 4; 
                    end
                    3'b100:begin
                        input_1 = read_output_1;
                        input_2 = read_output_2;
                        carry_in = 1'b0;
                        shamt = 5'b0;
                        direction = 1'b0;
                        a_or_s = 1'b1;
                        memory_write = 1'b0;
                        memory_address = read_output_1 + immediate;
                        write_enable = 1'b1;
                        write_data = (memory_address[1]) ? ((memory_address[0]) ? {{24{1'b0}},memory_output_data[31:24]} : {{24{1'b0}},memory_output_data[23:16]}) : ((memory_address[0]) ? {{24{1'b0}},memory_output_data[15:8]} : {{24{1'b0}},memory_output_data[7:0]}); 
                        pc_input = pc_output + 4; 
                    end
                    3'b101:begin
                        input_1 = read_output_1;
                        input_2 = read_output_2;
                        carry_in = 1'b0;
                        shamt = 5'b0;
                        direction = 1'b0;
                        a_or_s = 1'b1;
                        memory_write = 1'b0;
                        memory_address = read_output_1 + immediate;
                        write_enable = 1'b1;
                        write_data = (memory_address[1]) ? {{16{1'b0}},memory_output_data[31:16]} : {{16{1'b0}},memory_output_data[15:0]}; 
                        pc_input = pc_output + 4; 
                    end
                endcase
            end
            7'b0100011:begin
                case(func3)
                    3'b000:begin
                        input_1 = read_output_1;
                        input_2 = read_output_2;
                        carry_in = 1'b0;
                        shamt = 5'b0;
                        direction = 1'b0;
                        a_or_s = 1'b1;
                        write_enable = 1'b0;
                        memory_write = 1'b1;
                        memory_address = read_output_1 + immediate;
                        memory_input_data = (memory_address[1]) ? ((memory_address[0]) ? {read_output_2[7:0],memory_output_data[23:0]} : {memory_output_data[31:24],read_output_2[7:0],memory_output_data[15:0]}) : ((memory_address[0]) ? {memory_output_data[31:16],read_output_2[7:0],memory_output_data[7:0]} : {memory_output_data[31:8],read_output_2[7:0]}); 
                        pc_input = pc_output + 4; 
                    end
                    3'b001:begin
                        input_1 = read_output_1;
                        input_2 = read_output_2;
                        carry_in = 1'b0;
                        shamt = 5'b0;
                        direction = 1'b0;
                        a_or_s = 1'b1;
                        write_enable = 1'b0;
                        memory_write = 1'b1;
                        memory_address = read_output_1 + immediate;
                        memory_input_data = (memory_address[1]) ? {read_output_2[15:0],memory_output_data[15:0]} : {memory_output_data[31:16],read_output_2[15:0]}; 
                        pc_input = pc_output + 4;
                    end
                    3'b010:begin
                        input_1 = read_output_1;
                        input_2 = read_output_2;
                        carry_in = 1'b0;
                        shamt = 5'b0;
                        direction = 1'b0;
                        a_or_s = 1'b1;
                        write_enable = 1'b0;
                        memory_write = 1'b1;
                        memory_address = read_output_1 + immediate;
                        memory_input_data = read_output_2; 
                        pc_input = pc_output + 4; 
                    end
                endcase
            end
            7'b0110111:begin
                input_1 = read_output_1;
                input_2 = read_output_2;
                carry_in = 1'b0;
                shamt = 5'b0;
                direction = 1'b0;
                a_or_s = 1'b1;
                memory_write = 1'b0;
                memory_address = immediate;
                write_enable = 1'b1;
                write_data = immediate;
                pc_input = pc_output + 4;
            end
            7'b0010111:begin
                input_1 = read_output_1;
                input_2 = read_output_2;
                carry_in = 1'b0;
                shamt = 5'b0;
                direction = 1'b0;
                a_or_s = 1'b1;
                memory_write = 1'b0;
                memory_address = immediate;
                write_enable = 1'b1;
                write_data = immediate + pc_output;
                pc_input = pc_output + 4;
            end
            7'b0001111,
            7'b1110011:begin
                pc_input = pc_output + 4;
            end
            default: begin
                input_1 = read_output_1;
                input_2 = read_output_2;
                carry_in = 1'b0;
                shamt = 5'b0;
                direction = 1'b0;
                a_or_s = 1'b1;
                memory_write = 1'b0;
                memory_address = immediate;
                write_enable = 1'b0;
                write_data = immediate + pc_output;
                pc_input = pc_output + 4;
            end
        endcase
    end
endmodule
