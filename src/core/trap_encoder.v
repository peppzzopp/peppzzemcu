module trap_encoder(
    input from_lsu,
    input from_control,
    input sys_call,
    input env_break,
    input timer_interrupt,
    input external_interrupt,
    input is_store,
    input [2:0]state,

    output reg [31:0]trap_cause,
    output trap_trigger
);

    wire interrupt_trigger; wire exception_trigger;
    assign interrupt_trigger = (external_interrupt | timer_interrupt) & (state == 3'b000);
    assign exception_trigger = from_control | from_lsu | sys_call | env_break;
    assign trap_trigger = interrupt_trigger | exception_trigger;
    always @(*) begin
        if (external_interrupt) begin
            trap_cause = 32'h8000000B;
        end
        else if (timer_interrupt) begin
            trap_cause = 32'h80000007;
        end
        else if (from_control) begin
            trap_cause = 32'h00000002;
        end
        else if (from_lsu) begin
            trap_cause = is_store ? 32'h00000006 : 32'h00000004;
        end
        else if (sys_call) begin
            trap_cause = 32'h0000000B;
        end
        else if (env_break) begin
            trap_cause = 32'h00000003;
        end
        else begin
            trap_cause = 32'h00000000;
        end
    end
endmodule
