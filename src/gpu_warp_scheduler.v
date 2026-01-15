module gpu_warp_scheduler(  clk, rst, kernel_start, kernel_done, kernel_running, 
                            is_exit, is_end, is_cmp, is_maskrst, is_mask,
                            active_mask, cmp_pass, mask_val);

    input clk, rst;
    input kernel_start;
    input is_exit, is_cmp, is_end, is_maskrst, is_mask;
    input [3:0] cmp_pass, mask_val;
    output reg kernel_running, kernel_done;
    output reg [3:0] active_mask;

    parameter IDL = 2'b00;
    parameter RUN = 2'b01;
    parameter FIN = 2'b10;

    reg [1:0] state = 2'b00;


    always @(posedge clk or negedge rst) begin
        if(~rst) begin
            state           <= IDL;
            active_mask     <= 4'b1111;
            kernel_running  <= 0;
            kernel_done     <= 0;
        end
        else begin
            case(state) 
                IDL: begin
                    state <= IDL;
                    if(kernel_start)
                        state <= RUN;
                end

                RUN: begin
                    if(is_exit || is_end) begin
                        state       <= FIN;
                    end
                    else 
                        state <= RUN;                    
                end

                FIN: begin
                    state <= IDL;
                end
            endcase
        end

    end


    always @(*) begin
        case (state)
            IDL: begin
                active_mask     <= 4'b0000;
                kernel_running  <= 0;
                kernel_done     <= 0;
                if(kernel_start) begin
                    active_mask <= 4'b1111;
                    state       <= RUN;
                end
            end

            RUN: begin
                kernel_running  <= 1'b1;
                kernel_done     <= 1'b0;
                active_mask     <= is_maskrst ? 4'b1111 : active_mask;
                if(is_mask)
                    active_mask <= mask_val;
                else if (is_cmp)
                    active_mask <= active_mask & cmp_pass;
            end

            FIN: begin
                kernel_done     <= 1'b1;
                kernel_running  <= 1'b0;
                active_mask     <= 4'b0000;
            end
            
            default: begin
                kernel_done     <= 1'b1;
                kernel_running  <= 1'b0;
                active_mask     <= 4'b0000;
            end
        endcase
    end
        
endmodule
