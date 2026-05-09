`include "core_defines.v"

module core(
    input clock,
    input reset,
    input stall,
    input timer_interrupt,
    input external_interrupt,

    input [63:0]mcycle,
    
    /*Instruction memory port*/
    output [31:0]imem_address,
    input [31:0]imem_data,
    output imem_req,

    /*Data memory port*/
    output [31:0]dmem_address,
    output [31:0]dmem_write_data,
    output dmem_write_enable,
    output dmem_read_enable,
    output [3:0]dmem_byte_enable,
    input [31:0]dmem_read_data
);
    
    wire ir_write; wire pc_write; wire reg_write; wire mem_write; wire ret_write;
    wire [1:0]alu_src_a; wire [1:0]alu_src_b; wire [3:0]alu_op; wire [2:0]reg_src; wire [1:0]zicsr_src;
    wire [6:0]opcode; wire [2:0]func3; wire [6:0]func7; wire pc_src; wire in_memory;
    reg alu_con; wire zicsr_write; wire [11:0]csr;
    wire system_call; wire env_break; wire mret; wire no_instruction; wire trap_trigger;
    wire pc_control; wire [2:0]state; wire final_cycle;
    control control_unit(
        .clock(clock),
        .reset(reset),
        .stall(stall),
        .opcode(opcode),
        .func3(func3),
        .func7(func7),
        .csr(csr),
        .alu_con(alu_con),
        .core_trap(trap_trigger),
        .current_state(state),
        .ir_write(ir_write),
        .pc_write(pc_write),
        .pc_control(pc_control),
        .reg_write(reg_write),
        .mem_write(mem_write),
        .ret_write(ret_write),
        .zicsr_write(zicsr_write),
        .alu_src_a(alu_src_a),
        .alu_src_b(alu_src_b),
        .alu_op(alu_op),
        .reg_src(reg_src),
        .pc_src(pc_src),
        .zicsr_src(zicsr_src),
        .in_fetch(imem_req),
        .in_memory(in_memory),
        .sys_call(system_call),
        .env_break(env_break),
        .mret(mret),
        .not_supported_instruction(no_instruction),
        .final_cycle(final_cycle)
    );

    wire [31:0]alu_output; 
    reg [31:0]alu_input_1; reg [31:0]alu_input_2;
    alu alu_unit(
        .input_1(alu_input_1),
        .input_2(alu_input_2),
        .alu_op(alu_op),
        .alu_output(alu_output)
    );

    reg [31:0]pc_input;
    program_counter pc_unit(
        .reset(reset),
        .clock(clock),
        .write_enable((pc_write & ~stall) | trap_trigger),
        .pc_data(pc_input),
        .pc_output(imem_address)
    );
    
    wire [31:0]instruction;
    control_register ir(
        .clock(clock),
        .reset(reset),
        .write_enable(ir_write & ~stall),
        .input_data(imem_data),
        .output_data(instruction)
    );
    
    wire [31:0]alu_regout;
    control_register alu_out(
        .clock(clock),
        .reset(reset),
        .write_enable(~stall),
        .input_data(alu_output),
        .output_data(alu_regout)
    );
    
    wire [31:0]register_in;
    control_register reg_in(
        .clock(clock),
        .reset(reset),
        .write_enable(~stall),
        .input_data(imem_address),
        .output_data(register_in)
    );
    
    wire [31:0]trap_pc_control;
    control_register trap_pc_control_register(
        .clock(clock),
        .reset(reset),
        .write_enable(pc_control & ~stall),
        .input_data(imem_address),
        .output_data(trap_pc_control)
    );
    wire [31:0]trap_pc_wire;
    assign trap_pc_wire = (state == 3'b000) ? imem_address : trap_pc_control;
    

    wire [31:0]ret_addr_output;
    control_register ret_addr(
        .clock(clock),
        .reset(reset),
        .write_enable(ret_write & ~stall),
        .input_data(imem_address),
        .output_data(ret_addr_output)
    );
    
    wire [31:0]csr_output; wire [31:0]zicsr_output;
    control_register csr_addr(
        .clock(clock),
        .reset(reset),
        .write_enable(~stall),
        .input_data(zicsr_output),
        .output_data(csr_output)
    );
    

    wire [4:0]rs1; wire [4:0]rs2; wire [4:0]rsd;
    wire [31:0]immediate;
    decoder decode_unit(
        .instruction(instruction),
        .opcode(opcode),
        .rs1(rs1),
        .rs2(rs2),
        .rsd(rsd),
        .func3(func3),
        .func7(func7),
        .csr(csr),
        .immediate(immediate)
    );
    
    reg [31:0]register_write_data;
    wire [31:0]register_r1; wire [31:0]register_r2;
    regfile register_unit(
        .reset(reset),
        .clock(clock),
        .write_enable(reg_write & ~stall),
        .read_1(rs1),
        .read_2(rs2),
        .write(rsd),
        .write_data(register_write_data),
        .read_output_1(register_r1),
        .read_output_2(register_r2)
    );

    reg [1:0]lsu_type; reg load_sign; wire address_misaligned;
    wire [31:0]load_data;
    lsu lsu_unit(
        .byte_offset(alu_regout[1:0]),
        .lsu_type(lsu_type),
        .memory_input(dmem_read_data),
        .sign(load_sign),
        .load_data(load_data),
        .rs2(register_r2),
        .byte_enable(dmem_byte_enable),
        .store_data(dmem_write_data),
        .address_misaligned(address_misaligned)
    );
    
    reg [31:0]zicsr_input;
    wire tint_assert; wire eint_assert;
    wire [31:0]ret_address; wire [31:0]vec_address; wire [31:0]trap_cause;
    csr csr_unit(
        .clock(clock),
        .reset(reset),
        .input_data(zicsr_input),
        .address(csr),
        .write_enable(zicsr_write & ~stall),
        .output_data(zicsr_output),
        .trap_pc(trap_pc_wire),
        .trap_cause(trap_cause),
        .trap_trigger(trap_trigger),
        .mret(mret),
        .mcycle(mcycle),
        .final_cycle(),
        .timer_interrupt(timer_interrupt),
        .external_interrupt(external_interrupt),
        .assert_timer_interrupt(tint_assert),
        .assert_external_interrupt(eint_assert),
        .ret_address(ret_address),
        .vec_address(vec_address)
    );
    
    wire lsu_trap; assign lsu_trap = address_misaligned & in_memory;
    trap_encoder trap_en(
        .from_lsu(lsu_trap),
        .from_control(no_instruction),
        .sys_call(system_call),
        .env_break(env_break),
        .timer_interrupt(tint_assert),
        .external_interrupt(eint_assert),
        .is_store(mem_write),
        .state(state),
        .trap_cause(trap_cause),
        .trap_trigger(trap_trigger)
    );

    assign dmem_write_enable = mem_write & ~address_misaligned;
    assign dmem_read_enable = in_memory & ~mem_write;
    assign dmem_address = alu_regout;
    always@(*)begin
        alu_con = |(alu_output);
        casez({trap_trigger,mret,pc_src})
            3'b000: pc_input = {alu_output[31:1],1'b0};
            3'b001: pc_input = alu_regout;
            3'b01x: pc_input = ret_address;
            default: pc_input = vec_address;
        endcase
        case(zicsr_src)
            2'b01: zicsr_input = immediate;
            2'b10: zicsr_input = alu_output;
            default: zicsr_input = register_r1;
        endcase
        case(alu_src_a)
            2'b00: alu_input_1 = register_r1;
            2'b01: alu_input_1 = imem_address;
            2'b10: alu_input_1 = ret_addr_output;
            2'b11: alu_input_1 = immediate;
        endcase
        case(reg_src)
            3'b000: register_write_data = alu_regout;
            3'b001: register_write_data = load_data;
            3'b010: register_write_data = register_in;
            3'b011: register_write_data = immediate;
            default: register_write_data = csr_output;
        endcase
        case(alu_src_b)
            2'b00: alu_input_2 = register_r2;
            2'b01: alu_input_2 = immediate;
            2'b10: alu_input_2 = 32'h00000004;
            2'b11: alu_input_2 = zicsr_output;
        endcase
        load_sign = ~func3[2];
        case(func3[1:0])
            2'b00: lsu_type = 2'b10;
            2'b01: lsu_type = 2'b01;
            2'b10: lsu_type = 2'b00;
            2'b11: lsu_type = 2'b00;
        endcase
    end
endmodule
