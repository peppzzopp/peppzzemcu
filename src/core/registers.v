module regfile(
    input reset,
    input clock,
    input write_enable,
    input [4:0]read_1,
    input [4:0]read_2,
    input [4:0]write,
    input [31:0]write_data,
    output [31:0]read_output_1,
    output [31:0]read_output_2
);
    reg [31:0]register_file [0:31];
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
    
endmodule

module program_counter#(
    parameter RESET_ADDR = 32'h80000000
)(
    input reset,
    input clock,
    input load,
    input [31:0]pc_data,
    output [31:0]pc_output,
    output [31:0]pc_plus_4
);
    reg [31:0]program_address;

    always@(posedge clock)begin
        $display("PC_SAMPLE @%0t: pc=%h load=%b pc_data=%h",
            $time, program_address, load, pc_data);
        if(reset) program_address <= RESET_ADDR;
        else begin
            if(load) program_address <= pc_data;
            else program_address <= program_address + pc_data;
        end
    end
    assign pc_output = program_address;
    assign pc_plus_4 = program_address + 4;
endmodule

