module gpu_pc(
    input clk, 
    input rst,
    input pc_stall,       
    input is_branch,
    input branch_taken,
    input signed [15:0] branch_offset, 
    
    output reg signed [31:0] pc
);

    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            pc <= 32'b0;
        end
        else if (pc_stall) begin
            pc <= pc;
        end
        else begin
            if (is_branch & branch_taken) begin
                pc <= pc + {{16{branch_offset[15]}}, branch_offset}; 
            end
            else begin
                pc <= pc + 32'd4; 
            end
        end
    end

endmodule