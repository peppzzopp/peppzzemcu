module csr(
    input clock,
    input reset,

    /*Zicsr*/
    input [31:0]input_data,
    input [11:0]address,
    input write_enable,
    output reg [31:0]output_data,

    /*Hardware*/
    input [31:0]trap_pc,
    input [31:0]trap_cause,
    input trap_trigger,
    input mret,

    /*Hardware passthrough for mtime*/
    input [63:0]mcycle,
    input final_cycle,

    /*Interrupts*/
    input timer_interrupt,
    input external_interrupt,
    
    /*Output to core*/
    output assert_timer_interrupt,
    output assert_external_interrupt,
    output [31:0]ret_address,
    output [31:0]vec_address
);

    /*mstatus bits*/
    reg mstatus_mie;
    reg mstatus_mpie;
    
    /*mie bits*/
    reg mie_mtie;
    reg mie_meie;

    // 32-bit registers
    reg [31:0] mtvec;
    reg [31:0] mscratch;
    reg [31:0] mepc;
    reg [31:0] mcause;

    reg[63:0]instret;
    
    /*Output to core*/
    assign assert_timer_interrupt = mstatus_mie & (mie_mtie & timer_interrupt);
    assign assert_external_interrupt = mstatus_mie & (mie_meie & external_interrupt);
    assign ret_address = mepc;
    assign vec_address = mtvec;
    
    always@(*)begin
        output_data = 32'h00000000;
        case(address)
            12'h300: output_data = {24'b0, mstatus_mpie, 3'b0, mstatus_mie, 3'b0};
            12'h304: output_data = {20'b0, mie_meie, 3'b0, mie_mtie, 7'b0};
            12'h305: output_data = mtvec;
            12'h340: output_data = mscratch;
            12'h341: output_data = mepc;
            12'h342: output_data = mcause;
            12'h344: output_data = {20'b0, external_interrupt, 3'b0, timer_interrupt, 7'b0};
            12'hB00: output_data = mcycle[31:0];
            12'hB02: output_data = instret[31:0];
            12'hB80: output_data = mcycle[63:32];
            12'hB82: output_data = instret[63:32];
        endcase
    end

    always@(posedge clock)begin
        if(reset)begin
            mstatus_mie <= 1'b0;
            mstatus_mpie <= 1'b0;
            mie_mtie <= 1'b0;
            mie_meie <= 1'b0;
            mtvec <= 32'h00000000;
            mscratch <= 32'h00000000;
            mepc <= 32'h00000000;
            mcause <= 32'h00000000;
            instret <= 64'h0000000000000000;
        end
        else begin
            if(trap_trigger)begin
                mepc <= trap_pc;
                mcause <= trap_cause;

                mstatus_mpie <= mstatus_mie;
                mstatus_mie  <= 1'b0;
            end
            else if(mret)begin
                mstatus_mie  <= mstatus_mpie;
                mstatus_mpie <= 1'b1;
            end
            else if(write_enable)begin
                case(address)
                    12'h300: begin
                        mstatus_mie  <= input_data[3];
                        mstatus_mpie <= input_data[7];
                    end
                    12'h304: begin
                        mie_mtie <= input_data[7];
                        mie_meie <= input_data[11];
                    end
                    12'h305: mtvec    <= {input_data[31:2], 2'b00};
                    12'h340: mscratch <= input_data;
                    12'h341: mepc     <= input_data;
                    12'h342: mcause   <= input_data;
                endcase
            end
            if(final_cycle) instret <= instret + 1;
        end
    end
endmodule
