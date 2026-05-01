module axi_master(
    input clock,
    input reset,
    /*Write address*/
    output reg [31:0]waddr,
    output reg wavalid,
    input waready,
    /*Write data*/
    output reg [31:0]wdata,
    output reg wdvalid,
    output reg [3:0]wstrb,
    input wdready,
    /*Write response*/
    input [1:0]backw,
    input bvalid,
    output reg bready,
    /*Read address*/
    output reg [31:0]raddr,
    output reg ravalid,
    input raready,
    /*Read data*/
    input [31:0]rdata,
    input [1:0]rresp,
    input rvalid,
    output reg rready
);

    wire [3:0]dmem_strb;
    wire [31:0]imem_address; wire [31:0]imem_data;
    wire [31:0]dmem_address; wire [31:0]dmem_read_data; wire [31:0]dmem_write_data;
    wire dmem_write_enable; wire dmem_read_enable; wire imem_req; wire stall;

    core core_unit(
        .clock(clock),
        .reset(reset),
        .stall(stall),
        .imem_address(imem_address),
        .imem_data(imem_data),
        .imem_req(imem_req),
        .dmem_address(dmem_address),
        .dmem_write_data(dmem_write_data),
        .dmem_write_enable(dmem_write_enable),
        .dmem_read_enable(dmem_read_enable),
        .dmem_byte_enable(dmem_strb),
        .dmem_read_data(dmem_read_data)
    );

    reg [31:0]imem_cap; reg [31:0]dmem_cap;

    reg [3:0]state; reg [3:0]next_state;
    localparam IDLE = 4'h0;
    localparam FETCH_ADDR = 4'h1;
    localparam FETCH_WAIT = 4'h2;
    localparam READ_ADDR = 4'h3;
    localparam READ_WAIT = 4'h4;
    localparam WRITE_ADDR = 4'h5;
    localparam WRITE_DATA = 4'h7;
    localparam WRITE_RESP = 4'h8;
    
    wire active_request = imem_req | dmem_read_enable | dmem_write_enable;
    wire transaction_done = (state == FETCH_WAIT && rvalid) || 
                            (state == READ_WAIT && rvalid) || 
                            (state == WRITE_RESP && bvalid);
    assign stall = active_request & ~transaction_done;
    assign imem_data = ((state == FETCH_WAIT) && rvalid) ? rdata : imem_cap;
    assign dmem_read_data = ((state == READ_WAIT) && rvalid) ? rdata : dmem_cap;
    
    always@(posedge clock)begin
        if(reset) state <= IDLE;
        else state <= next_state;
    end

    always@(posedge clock)begin
        if((state == FETCH_WAIT) && rvalid) imem_cap <= rdata;
        if((state == READ_WAIT) && rvalid) dmem_cap <= rdata;
    end

    always@(*)begin
        waddr = 32'h00000000;
        wavalid = 1'b0;
        wdata = 32'h00000000;
        wdvalid = 1'b0;
        wstrb = 4'h0;
        bready = 1'b0;
        raddr = 32'h00000000;
        ravalid = 1'b0;
        rready = 1'b0;
        
        case(state)
            IDLE:begin
                if(dmem_write_enable) next_state = WRITE_ADDR;
                else if(dmem_read_enable) next_state = READ_ADDR;
                else if(imem_req) next_state = FETCH_ADDR;
                else next_state = IDLE;
            end
            FETCH_ADDR:begin
                raddr = imem_address;
                ravalid = 1'b1;
                if(raready) next_state = FETCH_WAIT;
                else next_state = FETCH_ADDR;
            end
            FETCH_WAIT:begin
                raddr = imem_address;
                rready = 1'b1;
                if(rvalid) next_state = IDLE;
                else next_state = FETCH_WAIT;
            end
            READ_ADDR:begin
                raddr = dmem_address;
                ravalid = 1'b1;
                if(raready) next_state = READ_WAIT;
                else next_state = READ_ADDR;
            end
            READ_WAIT:begin
                raddr = dmem_address;
                rready = 1'b1;
                if(rvalid) next_state = IDLE;
                else next_state = READ_WAIT;
            end
            WRITE_ADDR:begin
                waddr = dmem_address;
                wdata = dmem_write_data;
                wstrb = dmem_strb;
                wavalid = 1'b1;
                wdvalid = 1'b1;
                if(waready && wdready) next_state = WRITE_RESP;
                else next_state = WRITE_ADDR;
            end
            WRITE_RESP:begin
                waddr = dmem_address;
                bready = 1'b1;
                if(bvalid) next_state = IDLE;
                else next_state = WRITE_RESP;
            end
        endcase
    end

endmodule
