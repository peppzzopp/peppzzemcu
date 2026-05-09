module mmio(
    input clock,
    input reset,
    /*Write address*/
    input [31:0]waddr,
    input wavalid,
    output waready,
    /*Write data*/
    input [31:0]wdata,
    input wdvalid,
    input [3:0]wstrb,
    output wdready,
    /*Write response*/
    output [1:0]backw,
    output reg bvalid,
    input bready,
    /*Read address*/
    input [31:0]raddr,
    input ravalid,
    output raready,
    /*Read data*/
    output reg [31:0]rdata,
    output [1:0] rresp,
    output reg rvalid,
    input rready,
    
    /*Interrupts and Zicntr*/
    output timer_interrupt,
    output [63:0]mtime,

    /*Peripherals*/
    output [5:0]gpio_led
);

    assign backw = 2'b00;
    assign rresp = 2'b00;
    assign waready = 1'b1;
    assign wdready = 1'b1;
    assign raready = 1'b1;

    wire write_handshake = wavalid & wdvalid;
    wire read_handshake = ravalid & ~rvalid;

    localparam ADDR_GPIO = 4'h0;
    localparam ADDR_TIMER = 4'h1;

    wire sel_gpio = (waddr[11:8] == ADDR_GPIO);
    wire sel_raddr_gpio = (raddr[11:8] == ADDR_GPIO);
    wire sel_timer = (waddr[11:8] == ADDR_TIMER);
    wire sel_raddr_timer = (raddr[11:8] == ADDR_TIMER);

    wire gpio_write_en = write_handshake & sel_gpio;
    wire timer_write_en = write_handshake & sel_timer;

    wire [31:0]gpio_read_data; wire [31:0]timer_read_data;

    wire [31:0]mmio_read_data = sel_raddr_gpio ? gpio_read_data : (sel_raddr_timer ? timer_read_data : 32'hDEADBEEF);

    always @(posedge clock) begin
        if (reset)
            bvalid <= 1'b0;
        else begin
            if(bvalid & bready) bvalid <= 1'b0;
            if(write_handshake) bvalid <= 1'b1;
        end
    end

    always@(posedge clock) begin
        if(reset) begin
            rvalid <= 1'b0;
            rdata <= 32'b0;
        end else begin
            if(rvalid & rready) rvalid <= 1'b0;
            if(read_handshake) begin
                rvalid <= 1'b1;
                rdata <= mmio_read_data;
            end
        end
    end

    gpio gpio_unit(
        .clock(clock),
        .reset(reset),
        .write_enable(gpio_write_en),
        .input_data(wdata[5:0]),
        .output_data(gpio_read_data[5:0]),
        .led(gpio_led)
    );
    assign gpio_read_data[31:6] = 26'b0;

    timer timer_unit(
        .clock(clock),
        .reset(reset),
        .write_compare(timer_write_en),
        .word_sel(sel_raddr_timer ? raddr[2] : waddr[2]),
        .compare_value(wdata),
        .read_data(timer_read_data),
        .timer_interrupt(timer_interrupt),
        .mtime_pass(mtime)
    );

endmodule
