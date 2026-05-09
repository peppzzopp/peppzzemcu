module timer(
    input clock,
    input reset,
    input [31:0]compare_value,
    input write_compare,
    input word_sel,
    output [31:0]read_data,

    output timer_interrupt,
    output [63:0]mtime_pass
);

    reg [63:0]mtime;
    reg [63:0]mtimecmp;

    always@(posedge clock)begin
        if(reset)begin
            mtime <= 64'h0000000000000000;
            mtimecmp <= 64'hFFFFFFFFFFFFFFFF;
        end
        else begin
            mtime <= mtime + 1;
            if(write_compare) begin
                if(word_sel) mtimecmp[63:32] <= compare_value;
                else mtimecmp[31:0] <= compare_value;
            end
        end
    end

    assign timer_interrupt = (mtime >= mtimecmp);
    assign mtime_pass = mtime;
    assign read_data = (word_sel) ? mtimecmp[63:32] : mtimecmp[31:0];
endmodule
