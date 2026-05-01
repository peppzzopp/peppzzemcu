module gpio(
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
    output [1:0]rresp,
    output reg rvalid,
    input rready,

    output [5:0]led
);

    reg [5:0]memory;
    
    assign waready = 1'b1;
    assign wdready = 1'b1;
    assign raready = 1'b1;
    assign backw = 2'b00;
    assign rresp = 2'b00;
    
    assign led = memory;

    always@(posedge clock)begin
        if(reset)begin
            memory <= 6'b111111;
            bvalid <= 1'b0;
            rvalid <= 1'b0;
        end 
        else begin
            if(wavalid && wdvalid)begin
                memory <= wdata[5:0];
                bvalid <= 1'b1;
            end else if(bready)begin
                bvalid <= 1'b0;
            end
            if(ravalid)begin
                rdata <= 32'h00000000;
                rvalid <= 1'b1;
            end else if(rready)begin
                rvalid <= 1'b0;
            end
        end
    end
endmodule
