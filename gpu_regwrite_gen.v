module gpu_regwrite_gen(regwrite, is_load, is_store, thread_sel, active_mask, regwrite_0, regwrite_1, regwrite_2, regwrite_3);

    input regwrite, is_load, is_store;
    input [1:0] thread_sel;
    input [3:0] active_mask;
    output regwrite_0, regwrite_1, regwrite_2, regwrite_3;

    assign regwrite_0 = (is_load) ? (regwrite & active_mask[0] & (thread_sel == 2'b00)) : (regwrite & active_mask[0]);
    assign regwrite_1 = (is_load) ? (regwrite & active_mask[1] & (thread_sel == 2'b01)) : (regwrite & active_mask[1]);
    assign regwrite_2 = (is_load) ? (regwrite & active_mask[2] & (thread_sel == 2'b10)) : (regwrite & active_mask[2]);
    assign regwrite_3 = (is_load) ? (regwrite & active_mask[3] & (thread_sel == 2'b11)) : (regwrite & active_mask[3]);

endmodule