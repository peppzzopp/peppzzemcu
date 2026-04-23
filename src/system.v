module system(
    input clock,
    input reset
);
    wire [31:0]imem_address; wire [31:0]imem_data;
    wire [31:0]dmem_address; wire [31:0]dmem_write_data; wire [31:0]dmem_read_data;
    wire [3:0]dmem_byte_enable; wire dmem_write_enable;
    core core_unit(
        .clock(clock),
        .reset(reset),
        .imem_address(imem_address),
        .imem_data(imem_data),
        .dmem_address(dmem_address),
        .dmem_write_data(dmem_write_data),
        .dmem_write_enable(dmem_write_enable),
        .dmem_byte_enable(dmem_byte_enable),
        .dmem_read_data(dmem_read_data)
    );
    
    dmem data_memory(
        .clock(clock),
        .reset(reset),
        .memory_write(dmem_write_enable),
        .byte_enable(dmem_byte_enable),
        .memory_address(dmem_address),
        .input_data(dmem_write_data),
        .output_data(dmem_read_data)
    );

    imem instr_memory(
        .instruction_address(imem_address),
        .instruction(imem_data)
    );
endmodule
