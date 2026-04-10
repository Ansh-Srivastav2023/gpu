module thread_RV_dmux (RV_lane0, RV_lane1, RV_lane2, RV_lane3, thread_sel, is_load, is_store, RVx_lane0, RVx_lane1, RVx_lane2, RVx_lane3);

    input is_load, is_store;
    input [1:0] thread_sel;
    input signed [31:0] RV_lane0, RV_lane1, RV_lane2, RV_lane3;

    output signed [31:0] RVx_lane0, RVx_lane1, RVx_lane2, RVx_lane3;

    assign RVx_lane0 = (is_load | is_store) ? {{30{1'b0}}, thread_sel} + RV_lane0 : RV_lane0;
    assign RVx_lane1 = (is_load | is_store) ? {{30{1'b0}}, thread_sel} + RV_lane1 : RV_lane1;
    assign RVx_lane2 = (is_load | is_store) ? {{30{1'b0}}, thread_sel} + RV_lane2 : RV_lane2;
    assign RVx_lane3 = (is_load | is_store) ? {{30{1'b0}}, thread_sel} + RV_lane3 : RV_lane3;
endmodule