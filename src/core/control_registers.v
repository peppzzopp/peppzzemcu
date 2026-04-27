module control_register(
    input clock,
    input reset,
    input write_enable,
    input [31:0] input_data,
    output [31:0] output_data
);
    reg [31:0] register;
    always @(posedge clock) begin
        if (reset) begin
            register <= 32'h00000000;
        end else begin
            if (write_enable) begin
                register <= input_data;
            end
        end
    end
    assign output_data = register;
endmodule
