module reg_wr_src (is_load, thread_sel, mem_dout,
                    alu_rlt_lane0, alu_rlt_lane1, alu_rlt_lane2, alu_rlt_lane3,
                    result_lane0, result_lane1, result_lane2, result_lane3);

    input is_load;
    input [1:0] thread_sel;
    input signed [31:0] mem_dout, alu_rlt_lane0, alu_rlt_lane1, alu_rlt_lane2, alu_rlt_lane3;

    output signed [31:0] result_lane0, result_lane1, result_lane2, result_lane3;

    assign result_lane0 = is_load ? mem_dout : alu_rlt_lane0;
    assign result_lane1 = is_load ? mem_dout : alu_rlt_lane1;
    assign result_lane2 = is_load ? mem_dout : alu_rlt_lane2;
    assign result_lane3 = is_load ? mem_dout : alu_rlt_lane3;

endmodule