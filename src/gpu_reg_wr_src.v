module reg_wr_src (is_load, mem_dout, ld, li, imm,
                    alu_rlt_lane0, alu_rlt_lane1, alu_rlt_lane2, alu_rlt_lane3,
                    result_lane0, result_lane1, result_lane2, result_lane3);

    input is_load, ld, li;
    input signed [15:0] imm;
    input signed [31:0] mem_dout, alu_rlt_lane0, alu_rlt_lane1, alu_rlt_lane2, alu_rlt_lane3;

    output signed [31:0] result_lane0, result_lane1, result_lane2, result_lane3;

    assign result_lane0 = is_load ? ((ld & !li) ? mem_dout : {{16{imm[15]}},imm}) : alu_rlt_lane0;
    assign result_lane1 = is_load ? ((ld & !li) ? mem_dout : {{16{imm[15]}},imm}) : alu_rlt_lane1;
    assign result_lane2 = is_load ? ((ld & !li) ? mem_dout : {{16{imm[15]}},imm}) : alu_rlt_lane2;
    assign result_lane3 = is_load ? ((ld & !li) ? mem_dout : {{16{imm[15]}},imm}) : alu_rlt_lane3;

endmodule