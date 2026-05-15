`timescale 1ns/1ps

module tb;
    reg clk;
    reg rst;

    system dut(
        .clock(clk),
        .reset(~rst)
    );

    always #18.5185 clk = ~clk;
    reg [31:0]instruction_address;
    
    always@(posedge clk)begin
        if(dut.master.core_unit.control_unit.state == 3'b000) instruction_address <= dut.master.core_unit.imem_address;
        if(dut.master.core_unit.control_unit.state == 3'b010) begin
            $display("0x%08h", instruction_address);
        end
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb);
        clk = 0;
        rst = 1;
        instruction_address = 32'h00000000;

        repeat (4) @(posedge clk);
        rst = 0;
        
        #10000000; 
        $finish;
    end

endmodule
