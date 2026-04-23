`timescale 1ns/1ns

module tb;
    reg clk;
    reg rst;
    wire [32*32 -1:0]registers;
    wire [31:0]program_counter;
    wire [31:0]instruction;
    core dut(
        .clock(clk),
        .reset(rst),
        .debug_register_interface(registers),
        .debug_program_counter(program_counter),
        .debug_instruction(instruction)
    );
    always #5 clk = ~clk;

    always@(posedge clk)begin
        $display("0x%08h 0x%08h", program_counter, instruction);
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);
        clk = 0;
        rst = 1;

        repeat (2) @(posedge clk);
        rst = 0;
        #500;
        $finish;
    end

endmodule
