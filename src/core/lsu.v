module lsu(
    /*Common interface*/
    input [1:0]byte_offset,
    input [1:0]lsu_type,
    /*Load interface*/
    input [31:0]memory_input,
    input sign,
    output reg [31:0]load_data,
    /*Store interface*/
    input [31:0]rs2,
    output reg [3:0]byte_enable,
    output reg [31:0]store_data,

    output reg address_misaligned
);
    reg [7:0]  required_byte;
    reg [15:0] required_half_word;

    always @(*) begin
        required_byte = 8'b0;
        required_half_word = 16'b0;
        load_data = 32'b0;
        store_data = 32'b0;
        byte_enable = 4'b0000;
        address_misaligned = 1'b0;

        case(byte_offset)
            2'b00: begin
                required_byte = memory_input[7:0];
                required_half_word = memory_input[15:0];
            end
            2'b01: begin
                required_byte = memory_input[15:8];
                required_half_word = memory_input[15:0];
            end
            2'b10: begin
                required_byte = memory_input[23:16];
                required_half_word = memory_input[31:16];
            end
            2'b11: begin
                required_byte = memory_input[31:24];
                required_half_word = memory_input[31:16];
            end
        endcase

        case(lsu_type)
            2'b00: begin
                address_misaligned = |byte_offset;
                load_data = memory_input;
                store_data = rs2;
                byte_enable = 4'b1111;
            end
            2'b01: begin
                address_misaligned = byte_offset[0];
                load_data = sign ? {{16{required_half_word[15]}}, required_half_word}
                                   : {{16{1'b0}}, required_half_word};
                store_data = byte_offset[1] ? {rs2[15:0], 16'b0}
                                             : {16'b0, rs2[15:0]};
                byte_enable = byte_offset[1] ? 4'b1100 : 4'b0011;
            end
            2'b10: begin
                load_data = sign ? {{24{required_byte[7]}}, required_byte}
                                   : {{24{1'b0}}, required_byte};
                store_data = {24'h000000,rs2[7:0]} << {byte_offset, 3'b0};
                byte_enable = 4'b0001 << byte_offset;
            end
            default: begin
                load_data = 32'b0;
                store_data = 32'b0;
                byte_enable = 4'b0000;
            end
        endcase
    end
endmodule
