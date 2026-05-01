module system(
    input clock,
    input reset,

    output [5:0]led
);
    wire [31:0]master_waddr; wire master_wavalid; wire master_waready;
    wire [31:0]master_wdata; wire master_wdvalid; wire [3:0]master_wstrb; wire master_wdready;
    wire [1:0]master_backw; wire master_bvalid; wire master_bready;
    wire [31:0]master_raddr; wire master_ravalid; wire master_raready;
    wire [31:0]master_rdata; wire [1:0]master_rresp; wire master_rvalid; wire master_rready;
    
    wire [31:0]slave0_waddr; wire slave0_wavalid; wire slave0_waready;
    wire [31:0]slave0_wdata; wire slave0_wdvalid; wire [3:0]slave0_wstrb; wire slave0_wdready;
    wire [1:0]slave0_backw; wire slave0_bvalid; wire slave0_bready;
    wire [31:0]slave0_raddr; wire slave0_ravalid; wire slave0_raready;
    wire [31:0]slave0_rdata; wire [1:0]slave0_rresp; wire slave0_rvalid; wire slave0_rready;
    
    wire [31:0]slave1_waddr; wire slave1_wavalid; wire slave1_waready;
    wire [31:0]slave1_wdata; wire slave1_wdvalid; wire [3:0]slave1_wstrb; wire slave1_wdready;
    wire [1:0]slave1_backw; wire slave1_bvalid; wire slave1_bready;
    wire [31:0]slave1_raddr; wire slave1_ravalid; wire slave1_raready;
    wire [31:0]slave1_rdata; wire [1:0]slave1_rresp; wire slave1_rvalid; wire slave1_rready;
    
    wire [31:0]slave2_waddr; wire slave2_wavalid; wire slave2_waready;
    wire [31:0]slave2_wdata; wire slave2_wdvalid; wire [3:0]slave2_wstrb; wire slave2_wdready;
    wire [1:0]slave2_backw; wire slave2_bvalid; wire slave2_bready;
    wire [31:0]slave2_raddr; wire slave2_ravalid; wire slave2_raready;
    wire [31:0]slave2_rdata; wire [1:0]slave2_rresp; wire slave2_rvalid; wire slave2_rready;

    axi4_lite interconnect(
        .master_waddr(master_waddr),
        .master_wavalid(master_wavalid),
        .master_waready(master_waready),
        .master_wdata(master_wdata),
        .master_wdvalid(master_wdvalid),
        .master_wstrb(master_wstrb),
        .master_wdready(master_wdready),
        .master_backw(master_backw),
        .master_bvalid(master_bvalid),
        .master_bready(master_bready),
        .master_raddr(master_raddr),
        .master_ravalid(master_ravalid),
        .master_raready(master_raready),
        .master_rdata(master_rdata),
        .master_rresp(master_rresp),
        .master_rvalid(master_rvalid),
        .master_rready(master_rready),
        
        .slave0_waddr(slave0_waddr),
        .slave0_wavalid(slave0_wavalid),
        .slave0_waready(slave0_waready),
        .slave0_wdata(slave0_wdata),
        .slave0_wdvalid(slave0_wdvalid),
        .slave0_wstrb(slave0_wstrb),
        .slave0_wdready(slave0_wdready),
        .slave0_backw(slave0_backw),
        .slave0_bvalid(slave0_bvalid),
        .slave0_bready(slave0_bready),
        .slave0_raddr(slave0_raddr),
        .slave0_ravalid(slave0_ravalid),
        .slave0_raready(slave0_raready),
        .slave0_rdata(slave0_rdata),
        .slave0_rresp(slave0_rresp),
        .slave0_rvalid(slave0_rvalid),
        .slave0_rready(slave0_rready),
        
        .slave1_waddr(slave1_waddr),
        .slave1_wavalid(slave1_wavalid),
        .slave1_waready(slave1_waready),
        .slave1_wdata(slave1_wdata),
        .slave1_wdvalid(slave1_wdvalid),
        .slave1_wstrb(slave1_wstrb),
        .slave1_wdready(slave1_wdready),
        .slave1_backw(slave1_backw),
        .slave1_bvalid(slave1_bvalid),
        .slave1_bready(slave1_bready),
        .slave1_raddr(slave1_raddr),
        .slave1_ravalid(slave1_ravalid),
        .slave1_raready(slave1_raready),
        .slave1_rdata(slave1_rdata),
        .slave1_rresp(slave1_rresp),
        .slave1_rvalid(slave1_rvalid),
        .slave1_rready(slave1_rready),
        
        .slave2_waddr(slave2_waddr),
        .slave2_wavalid(slave2_wavalid),
        .slave2_waready(slave2_waready),
        .slave2_wdata(slave2_wdata),
        .slave2_wdvalid(slave2_wdvalid),
        .slave2_wstrb(slave2_wstrb),
        .slave2_wdready(slave2_wdready),
        .slave2_backw(slave2_backw),
        .slave2_bvalid(slave2_bvalid),
        .slave2_bready(slave2_bready),
        .slave2_raddr(slave2_raddr),
        .slave2_ravalid(slave2_ravalid),
        .slave2_raready(slave2_raready),
        .slave2_rdata(slave2_rdata),
        .slave2_rresp(slave2_rresp),
        .slave2_rvalid(slave2_rvalid),
        .slave2_rready(slave2_rready)
    );

    axi_master master(
        .clock(clock),
        .reset(~reset),
        .waddr(master_waddr),
        .wavalid(master_wavalid),
        .waready(master_waready),
        .wdata(master_wdata),
        .wdvalid(master_wdvalid),
        .wstrb(master_wstrb),
        .wdready(master_wdready),
        .backw(master_backw),
        .bvalid(master_bvalid),
        .bready(master_bready),
        .raddr(master_raddr),
        .ravalid(master_ravalid),
        .raready(master_raready),
        .rdata(master_rdata),
        .rresp(master_rresp),
        .rvalid(master_rvalid),
        .rready(master_rready)
    );
    
    memory#(.MEM_SIZE(32'h00000400), .IS_ROM(1), .BASE_ADDR(32'h80000000)) rom(
        .clock(clock),
        .reset(~reset),
        .waddr(slave0_waddr),
        .wavalid(slave0_wavalid),
        .waready(slave0_waready),
        .wdata(slave0_wdata),
        .wdvalid(slave0_wdvalid),
        .wstrb(slave0_wstrb),
        .wdready(slave0_wdready),
        .backw(slave0_backw),
        .bvalid(slave0_bvalid),
        .bready(slave0_bready),
        .raddr(slave0_raddr),
        .ravalid(slave0_ravalid),
        .raready(slave0_raready),
        .rdata(slave0_rdata),
        .rresp(slave0_rresp),
        .rvalid(slave0_rvalid),
        .rready(slave0_rready)
    );
    
    memory#(.MEM_SIZE(32'h00002000), .IS_ROM(0), .BASE_ADDR(32'h20000000)) ram(
        .clock(clock),
        .reset(~reset),
        .waddr(slave1_waddr),
        .wavalid(slave1_wavalid),
        .waready(slave1_waready),
        .wdata(slave1_wdata),
        .wdvalid(slave1_wdvalid),
        .wstrb(slave1_wstrb),
        .wdready(slave1_wdready),
        .backw(slave1_backw),
        .bvalid(slave1_bvalid),
        .bready(slave1_bready),
        .raddr(slave1_raddr),
        .ravalid(slave1_ravalid),
        .raready(slave1_raready),
        .rdata(slave1_rdata),
        .rresp(slave1_rresp),
        .rvalid(slave1_rvalid),
        .rready(slave1_rready)
    );

    gpio led_unit(
        .clock(clock),
        .reset(~reset),
        .waddr(slave2_waddr),
        .wavalid(slave2_wavalid),
        .waready(slave2_waready),
        .wdata(slave2_wdata),
        .wdvalid(slave2_wdvalid),
        .wstrb(slave2_wstrb),
        .wdready(slave2_wdready),
        .backw(slave2_backw),
        .bvalid(slave2_bvalid),
        .bready(slave2_bready),
        .raddr(slave2_raddr),
        .ravalid(slave2_ravalid),
        .raready(slave2_raready),
        .rdata(slave2_rdata),
        .rresp(slave2_rresp),
        .rvalid(slave2_rvalid),
        .rready(slave2_rready),

        .led(led)
    );
endmodule
