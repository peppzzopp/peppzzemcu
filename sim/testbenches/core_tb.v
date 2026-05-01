`timescale 1ns/1ns

module tb;
    reg clock;
    reg reset;
    integer i;

    system dut(
        .clock(clock),
        .reset(reset)
    );

    always #5 clock = ~clock;

    always @(posedge clock) begin
        $display("------------------------------------------------------------");
        $display("Time:%0t", $time);
        $display("PC:%h", dut.master.core_unit.pc_unit.program_address);
        $display("Instruction:%h", dut.master.core_unit.instruction);
        for(i = 0; i < 32; i = i + 4) begin
            $display("X%02d:%h | X%02d:%h | X%02d:%h | X%02d:%h",
                i,   dut.master.core_unit.register_unit.register_file[i],
                i+1, dut.master.core_unit.register_unit.register_file[i+1],
                i+2, dut.master.core_unit.register_unit.register_file[i+2],
                i+3, dut.master.core_unit.register_unit.register_file[i+3]
            );
        end
        $display("IMEM[0]:%h", dut.rom.mem_array[0]);
        $display("DMEM[0]:%h", dut.ram.mem_array[0]);
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);

        clock = 0;
        reset = 1;

        repeat(2) @(posedge clock);
        reset = 0;

        repeat(100) @(posedge clock);
        $finish;
    end
endmodule
