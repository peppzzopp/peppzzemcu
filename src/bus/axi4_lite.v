module axi4_lite(
    /*Master interface(CORE)*/
    /*-Write address*/
    input [31:0]master_waddr,
    input master_wavalid,
    output master_waready,
    /*-Write data*/
    input [31:0]master_wdata,
    input master_wdvalid,
    input [3:0]master_wstrb,
    output master_wdready,
    /*-Write response*/
    output [1:0]master_backw,
    output master_bvalid,
    input master_bready,
    /*-Read address*/
    input [31:0]master_raddr,
    input master_ravalid,
    output master_raready,
    /*-Read data*/
    output [31:0]master_rdata,
    output [1:0]master_rresp,
    output master_rvalid,
    input master_rready,

    /*Slave0 interface(ROM)*/
    /*-Write address*/
    output [31:0]slave0_waddr,
    output slave0_wavalid,
    input slave0_waready,
    /*-Write data*/
    output [31:0]slave0_wdata,
    output slave0_wdvalid,
    output [3:0]slave0_wstrb,
    input slave0_wdready,
    /*-Write response*/
    input [1:0]slave0_backw,
    input slave0_bvalid,
    output slave0_bready,
    /*-Read address*/
    output [31:0]slave0_raddr,
    output slave0_ravalid,
    input slave0_raready,
    /*-Read data*/
    input [31:0]slave0_rdata,
    input [1:0]slave0_rresp,
    input slave0_rvalid,
    output slave0_rready,
    
    /*Slave1 interface(RAM)*/
    /*-Write address*/
    output [31:0]slave1_waddr,
    output slave1_wavalid,
    input slave1_waready,
    /*-Write data*/
    output [31:0]slave1_wdata,
    output slave1_wdvalid,
    output [3:0]slave1_wstrb,
    input slave1_wdready,
    /*-Write response*/
    input [1:0]slave1_backw,
    input slave1_bvalid,
    output slave1_bready,
    /*-Read address*/
    output [31:0]slave1_raddr,
    output slave1_ravalid,
    input slave1_raready,
    /*-Read data*/
    input [31:0]slave1_rdata,
    input [1:0]slave1_rresp,
    input slave1_rvalid,
    output slave1_rready,
    
    /*Slave2 interface(PERIPHERALS)*/
    /*-Write address*/
    output [31:0]slave2_waddr,
    output slave2_wavalid,
    input slave2_waready,
    /*-Write data*/
    output [31:0]slave2_wdata,
    output slave2_wdvalid,
    output [3:0]slave2_wstrb,
    input slave2_wdready,
    /*-Write response*/
    input [1:0]slave2_backw,
    input slave2_bvalid,
    output slave2_bready,
    /*-Read address*/
    output [31:0]slave2_raddr,
    output slave2_ravalid,
    input slave2_raready,
    /*-Read data*/
    input [31:0]slave2_rdata,
    input [1:0]slave2_rresp,
    input slave2_rvalid,
    output slave2_rready
);

    localparam ROM_ADDRESS = 32'h80000000;
    localparam RAM_ADDRESS = 32'h20000000;
    localparam PER_ADDRESS = 32'h30000000;

    wire rom_wsel; wire rom_rsel;
    wire ram_wsel; wire ram_rsel;
    wire per_wsel; wire per_rsel;

    assign rom_wsel = (master_waddr[31:28] == ROM_ADDRESS[31:28]);
    assign rom_rsel = (master_raddr[31:28] == ROM_ADDRESS[31:28]);

    assign ram_wsel = (master_waddr[31:28] == RAM_ADDRESS[31:28]);
    assign ram_rsel = (master_raddr[31:28] == RAM_ADDRESS[31:28]);
    
    assign per_wsel = (master_waddr[31:28] == PER_ADDRESS[31:28]);
    assign per_rsel = (master_raddr[31:28] == PER_ADDRESS[31:28]);

    assign slave0_waddr = master_waddr;
    assign slave0_wavalid = rom_wsel & master_wavalid;
    assign slave1_waddr = master_waddr;
    assign slave1_wavalid = ram_wsel & master_wavalid;
    assign slave2_waddr = master_waddr;
    assign slave2_wavalid = per_wsel & master_wavalid;

    assign slave0_raddr = master_raddr;
    assign slave0_ravalid = rom_rsel & master_ravalid;
    assign slave1_raddr = master_raddr;
    assign slave1_ravalid = ram_rsel & master_ravalid;
    assign slave2_raddr = master_raddr;
    assign slave2_ravalid = per_rsel & master_ravalid;

    assign slave0_wdata = master_wdata;
    assign slave0_wstrb = master_wstrb;
    assign slave0_wdvalid = rom_wsel & master_wdvalid;
    assign slave1_wdata = master_wdata;
    assign slave1_wstrb = master_wstrb;
    assign slave1_wdvalid = ram_wsel & master_wdvalid;
    assign slave2_wdata = master_wdata;
    assign slave2_wstrb = master_wstrb;
    assign slave2_wdvalid = per_wsel & master_wdvalid;

    assign slave0_bready = rom_wsel & master_bready;
    assign slave1_bready = ram_wsel & master_bready;
    assign slave2_bready = per_wsel & master_bready;
 
    assign slave0_rready = rom_rsel & master_rready;
    assign slave1_rready = ram_rsel & master_rready;
    assign slave2_rready = per_rsel & master_rready;
   
    assign master_rdata = ({32{rom_rsel}}&slave0_rdata) | ({32{ram_rsel}}&slave1_rdata) | ({32{per_rsel}}&slave2_rdata);
    assign master_rresp = ({2{rom_rsel}}&slave0_rresp) | ({2{ram_rsel}}&slave1_rresp) | ({2{per_rsel}}&slave2_rresp);
    assign master_rvalid = (rom_rsel&slave0_rvalid) | (ram_rsel&slave1_rvalid) | (per_rsel&slave2_rvalid);
    

    assign master_backw = ({2{rom_wsel}}&slave0_backw) | ({2{ram_wsel}}&slave1_backw) | ({2{per_wsel}}&slave2_backw);
    assign master_bvalid = (rom_wsel&slave0_bvalid) | (ram_wsel&slave1_bvalid) | (per_wsel&slave2_bvalid);

    assign master_waready = (rom_wsel&slave0_waready) | (ram_wsel&slave1_waready) | (per_wsel&slave2_waready);
    assign master_wdready = (rom_wsel&slave0_wdready) | (ram_wsel&slave1_wdready) | (per_wsel&slave2_wdready);
    assign master_raready = (rom_rsel&slave0_raready) | (ram_rsel&slave1_raready) | (per_rsel&slave2_raready);

endmodule
