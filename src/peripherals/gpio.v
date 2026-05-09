module gpio(
    input clock,
    input reset,
    input write_enable,
    input [5:0]input_data,
    output [5:0]output_data,

    output [5:0]led
);

    reg [5:0]port;
    assign led = port;

    always@(posedge clock)begin
        if(reset)begin
            port <= 6'b111111;
        end 
        else begin
            if(write_enable)begin
                port <= input_data;
            end
        end
    end
    assign output_data = port;
    
endmodule
