module INSTRMEM (
    input  wire [31:0] addr,
    output wire [31:0] instr
);

    reg [31:0] memory [0:1023];

    initial begin
        $readmemh("program.hex", memory);
    end

    assign instr = memory[addr[31:2]];

endmodule

module DATAMEM (
    input  wire        clk,
    input  wire        mem_write,
    input  wire        mem_read,
    input  wire [3:0]  byte_en,     // byte enable: 1111 = word, 0011 = halfword, 0001 = byte
    input  wire [31:0] addr,
    input  wire [31:0] write_data,
    output reg  [31:0] read_data
);

    reg [7:0] memory [0:4095];

    always @(posedge clk) begin
        if (mem_write) begin
            if (byte_en[0]) memory[addr]     <= write_data[7:0];
            if (byte_en[1]) memory[addr+1]   <= write_data[15:8];
            if (byte_en[2]) memory[addr+2]   <= write_data[23:16];
            if (byte_en[3]) memory[addr+3]   <= write_data[31:24];
        end
    end

    always @(*) begin
        if (mem_read) begin
            read_data = { memory[addr+3],
                          memory[addr+2],
                          memory[addr+1],
                          memory[addr] };
        end else begin
            read_data = 32'b0;
        end
    end

endmodule