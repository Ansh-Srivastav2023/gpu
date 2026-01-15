module gpu_lsu (
    input  wire       clk,
    input  wire       rst,
    input  wire       is_load,
    input  wire       is_store,

    output            pc_stall,
    output reg [1:0]  thread_sel
);

    reg [2:0] count;

    assign pc_stall = ~rst ? 0 : ((is_load | is_store) && thread_sel<2'b11);

    always @(posedge clk or negedge rst) begin
        if(~rst) begin
            thread_sel <= 2'b00;
        end

        else if((is_load | is_store) && thread_sel<2'b11 && pc_stall) begin
            thread_sel <= thread_sel + 1'b1;
        end

        else begin
            thread_sel <= 0;
        end
        
    end

endmodule
