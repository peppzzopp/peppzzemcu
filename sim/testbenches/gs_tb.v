`timescale 1ns/1ns

module tb;
    reg clk;
    reg rst;

    system dut(
        .clock(clk),
        .reset(rst)
    );

    always #5 clk = ~clk;
    reg [31:0]instruction_address;
    reg [31:0]instruction;
    
    always@(posedge clk)begin
        if(dut.master.core_unit.control_unit.state == 3'b000) instruction_address <= dut.master.core_unit.imem_address;
        if(dut.master.core_unit.control_unit.state == 3'b001) instruction <= dut.master.core_unit.instruction;
        if(dut.master.core_unit.control_unit.state == 3'b010) begin
            $display("0x%08h 0x%08h", instruction_address, instruction);
        end
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);
        clk = 0;
        rst = 1;
        instruction_address = 32'h00000000;
        instruction = 32'h00000000;

        repeat (4) @(posedge clk);
        rst = 0;
        
        #10000; 
        $finish;
    end

endmodule
