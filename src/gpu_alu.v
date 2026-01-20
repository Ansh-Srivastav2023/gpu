module gpu_alu (data1, data2, alu_ctrl, result);

    input signed [31:0] data1, data2;
    input [3:0] alu_ctrl;
    output reg signed [31:0] result;

    always @(*) begin
        result = 32'b0;
        
        case (alu_ctrl)
            4'b0000: begin
                result = 32'b0;
            end
            
            4'b0001: begin
                result = data1 + data2;
            end
            4'b0010: begin
                result = data1 - data2;
            end
            4'b0011: begin
                result = data1 * data2;
            end
            4'b0100: begin
                if(data2 == 32'd0)
                    result = 32'd0;
                else
                    result = data1 / data2;
            end
            default: begin
                result = 'b0;
            end
        endcase
    end
endmodule