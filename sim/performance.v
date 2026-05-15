`timescale 1ns/1ps

`include "tb_addrs.vh"

module tb;
    reg clk;
    reg rst;
    
    system dut(
        .clock(clk),
        .reset(~rst)
    );
    
    // 27MHz Clock (18.5185ns half-period)
    always #18.5185 clk = ~clk;
    
    // Internal registers for raw timestamps
    reg [31:0] trap_start;

    // Aggregation Registers
    integer sample_count;
    reg [63:0] total_trap_cycles; // 64-bit to prevent overflow!
    reg [31:0] max_trap_cycles;
    
    // Temporary calculation registers
    reg [31:0] current_trap_cycles;

    always @(posedge clk) begin
        if (dut.master_wavalid && dut.master_waready && dut.master_wdvalid && dut.master_wdready) begin
            
            // ==========================================
            // TRAP OVERHEAD ONLY
            // ==========================================
            if (dut.master_waddr == `TRAP_START) begin
                trap_start <= dut.master_wdata;
            end
            
            if (dut.master_waddr == `TRAP_END) begin
                // Calculate current trap latency
                current_trap_cycles = (dut.master_wdata - trap_start + 33);
                total_trap_cycles = total_trap_cycles + current_trap_cycles;
                
                // Track the Maximum
                if (current_trap_cycles > max_trap_cycles) begin
                    max_trap_cycles = current_trap_cycles;
                end
                
                // Increment sample count based solely on traps
                sample_count = sample_count + 1;
                
                // Print a progress dot every 10 samples
                if (sample_count % 10 == 0) begin
                    $display("Collected %0d samples...", sample_count);
                end

                // Output results when we reach 100 samples
                if (sample_count == 100) begin
                    $display("\n========================================");
                    $display("      OS TRAP PERFORMANCE RESULTS       ");
                    $display("========================================");
                    $display("Samples      : %0d", sample_count);
                    $display("Trap Max     : %0d CPU Cycles", max_trap_cycles);
                    $display("Trap Avg     : %0d CPU Cycles", total_trap_cycles / sample_count);
                    $display("========================================\n");
                    $finish; // End the simulation automatically!
                end
            end
        end
    end

    initial begin
        // Initialize all variables
        clk = 0;
        rst = 1;
        trap_start = 0;
        
        sample_count = 0;
        total_trap_cycles = 0;
        max_trap_cycles = 0;

        repeat (4) @(posedge clk);
        rst = 0;
        
        // 200ms Failsafe (200,000,000,000 ps)
        #20000000000; 
        $display("TIMEOUT: Simulation failed to reach 100 traps.");
        $finish;
    end

endmodule
