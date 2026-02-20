`timescale 1ns/1ns

module tb;
    reg clock;
    reg reset;
    wire [31:0]debug_instruction;
    wire [32*32 - 1:0]debug_register_interface;
    wire [31:0]debug_program_counter;

    core core_1(
        .clock(clock),
        .reset(reset),
        .debug_register_interface(debug_register_interface),
        .debug_program_counter(debug_program_counter),
        .debug_instruction(debug_instruction)
    );

    integer i;
    always #5 clock = ~clock;
    always@(posedge clock)begin
        $display("----------------------------------------------------------------------"); 
        $display("Time:%0t", $time);
        $display("PC:%h", debug_program_counter);
        $display("Instruction:%h",debug_instruction);
        for (i = 0; i < 32; i = i + 4) begin
            $display("X%02d:%10d | X%02d:%10d | X%02d:%10d | X%02d:%10d",
                i,     debug_register_interface[32*i     +: 32],
                i + 1, debug_register_interface[32*(i+1) +: 32],
                i + 2, debug_register_interface[32*(i+2) +: 32],
                i + 3, debug_register_interface[32*(i+3) +: 32]
            );
        end
    end
    
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);
    
        clock = 0;
        reset = 1;
    
        repeat (2) @(posedge clock);
        reset = 0;
        #100;
        $finish;
    end
endmodule
