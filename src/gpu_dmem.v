module gpu_dmem(clk, is_load, is_store, addr_bus, data_in, mem_dout);

    input clk;
    input is_load, is_store;
    input signed [31:0] data_in;
    input [31:0] addr_bus;

    output signed [31:0] mem_dout;

    reg signed [31:0] dmem [0:1023];

    initial begin
        $readmemh("/media/anx/New_Volume/Importants/Verilog/modifieable_processor/gpu/hex/gpu_dmem.hex", dmem);
    end

    assign mem_dout = is_load ? dmem[addr_bus[11:0]] : 32'bz;
    
    always @(posedge clk) begin
        if(is_store)
            dmem[addr_bus[11:2]] = data_in;
    end

    // initial begin
    //     #20
    //     $display("%h", dmem[0]);
    // end

endmodule


module gpu_dmem_logic (clk, is_load, is_store, thread_sel, data_in, addr_bus, 
                        R00_addr, R10_addr, R20_addr, R30_addr,
                        R0_val, R1_val, R2_val, R3_val);

    input clk, is_load, is_store;
    input signed [31:0] R00_addr, R10_addr, R20_addr, R30_addr;
    input signed [31:0] R0_val, R1_val, R2_val, R3_val;
    input [1:0] thread_sel;

    output signed [31:0] data_in;
    output [31:0] addr_bus;

    assign addr_bus =   (thread_sel == 2'b00) ? R00_addr :
                        (thread_sel == 2'b01) ? R10_addr :
                        (thread_sel == 2'b10) ? R20_addr : R30_addr;
    
    assign data_in  =   (thread_sel == 2'b00) ? R0_val :
                        (thread_sel == 2'b01) ? R1_val :
                        (thread_sel == 2'b10) ? R2_val : R3_val;

endmodule

module gpu_dmem_top (
    input clk,
    input is_load, is_store,
    input [1:0] thread_sel,
    input signed [31:0] R00_addr, R10_addr, R20_addr, R30_addr,
    input signed [31:0] R0_val, R1_val, R2_val, R3_val,

    output signed [31:0] mem_dout
);

    wire signed [31:0] data_in;
    wire [31:0] addr_bus;

    gpu_dmem gpu_dmem(.clk(clk),
            .is_load(is_load),
            .is_store(is_store),
            .addr_bus(addr_bus),
            .data_in(data_in),
            .mem_dout(mem_dout));

    gpu_dmem_logic gpu_dmem_logic(.clk(clk),
            .is_load(is_load),
            .is_store(is_store),
            .thread_sel(thread_sel),
            .data_in(data_in),
            .addr_bus(addr_bus),
            .R00_addr(R00_addr),
            .R10_addr(R10_addr),
            .R20_addr(R20_addr),
            .R30_addr(R30_addr),
            .R0_val(R0_val),
            .R1_val(R1_val),
            .R2_val(R2_val),
            .R3_val(R3_val));

endmodule