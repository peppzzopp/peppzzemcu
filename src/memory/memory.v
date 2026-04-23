module dmem(
    input clock,
    input reset,
    input memory_write,
    input [3:0]byte_enable,
    input [31:0]memory_address,
    input [31:0]input_data,
    output [31:0]output_data
);

    reg [31:0]ram [0:1023];
    integer i;
    
    always @(posedge clock) begin
        if(reset) begin
            for(i=0; i<1024; i=i+1)
                ram[i] <= 32'b0;
        end
        else if(memory_write) begin
            if(byte_enable[0]) ram[memory_address[11:2]][7:0]   <= input_data[7:0];
            if(byte_enable[1]) ram[memory_address[11:2]][15:8]  <= input_data[15:8];
            if(byte_enable[2]) ram[memory_address[11:2]][23:16] <= input_data[23:16];
            if(byte_enable[3]) ram[memory_address[11:2]][31:24] <= input_data[31:24];
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
