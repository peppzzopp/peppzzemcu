module regfile(
    input wire clk,rst,reg_write,
    input wire [4:0] rs1,rs2,rsd,
    input wire [31:0] write_data,
    output wire [31:0] read_data_1, read_data_2
);
    reg [31:0] register_file [31:0];
    integer i;
    always @(posedge clk or posedge rst) begin
        if (rst)
            for (i = 0; i < 32; i = i + 1)
                register_file[i] <= 0;
        else if (reg_write & (rsd != 0))
            register_file[rsd] <= write_data;
    end
    assign read_data_1 = (rs1 == 0) ? 0 : register_file[rs1];
    assign read_data_2 = (rs2 == 0) ? 0 : register_file[rs2];
endmodule