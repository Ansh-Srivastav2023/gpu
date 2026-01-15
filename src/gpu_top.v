// `include "gpu_alu.v"
// `include "gpu_register.v"
// `include "gpu_warp_scheduler.v"
// `include "gpu_cmp_unit.v"
// `include "gpu_decoder.v"
// `include "gpu_instr_mem.v"
// `include "gpu_lsu.v"
// `include "gpu_pc.v"
// `include "gpu_dmem.v"
// `include "gpu_reg_wr_src.v"
// `include "thread_RV_dmux.v"
// `include "gpu_regwrite_gen.v"

module gpu_top (clk, rst, kernel_start, kernel_done);

    input clk, rst, kernel_start;
    output kernel_done;

    // Commons
    wire pc_stall;
    wire regwrite;
    wire kernel_running;
    wire is_alu, is_load, is_store, is_cmp, is_branch, is_exit, is_end, is_maskrst, is_move, is_mask; //instruction class

    wire cmp_lt, cmp_eq, ld, li, imm_type, branch_taken;
    wire regwrite_0, regwrite_1, regwrite_2, regwrite_3;

    wire [1:0] thread_sel;
    wire [3:0] opcode, alu_ctrl;
    wire [3:0] rs1, rs2, rd;
    wire [3:0] active_mask, cmp_pass;
    wire [31:0] instruction;
    wire signed [31:0] mem_dout;
    wire signed [15:0] imm;
    wire signed [31:0] pc;

    // wire [31:0] R0_lane0, R0_lane1, R0_lane2, R0_lane3;
    wire signed [31:0] alu_rlt_lane0, alu_rlt_lane1, alu_rlt_lane2, alu_rlt_lane3;
    wire signed [31:0] result_lane0, result_lane1, result_lane2, result_lane3;
    wire signed [31:0] R1_lane0, R1_lane1, R1_lane2, R1_lane3;
    wire signed [31:0] R2_lane0, R2_lane1, R2_lane2, R2_lane3;
    wire signed [31:0] R3_lane0, R3_lane1, R3_lane2, R3_lane3;
    wire signed [31:0] RV_lane0, RV_lane1, RV_lane2, RV_lane3;
    wire signed [31:0] RVx_lane0, RVx_lane1, RVx_lane2, RVx_lane3;
    
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    gpu_regwrite_gen regwrite_gen(.regwrite(regwrite),
                        .is_load(is_load),
                        .is_store(is_store),
                        .thread_sel(thread_sel),
                        .active_mask(active_mask),
                        .regwrite_0(regwrite_0),
                        .regwrite_1(regwrite_1),
                        .regwrite_2(regwrite_2),
                        .regwrite_3(regwrite_3));

    thread_RV_dmux thread_RV_dmux(.RV_lane0(RV_lane0),
                        .RV_lane1(RV_lane1),
                        .RV_lane2(RV_lane2),
                        .RV_lane3(RV_lane3),
                        .thread_sel(thread_sel),
                        .is_load(is_load),
                        .is_store(is_store),
                        .RVx_lane0(RVx_lane0),
                        .RVx_lane1(RVx_lane1),
                        .RVx_lane2(RVx_lane2),
                        .RVx_lane3(RVx_lane3));

    gpu_pc gpu_pc(.clk(clk), .rst(rst), .pc(pc), .pc_stall(pc_stall), .is_branch(is_branch), .branch_taken(branch_taken), .branch_offset(imm));

    reg_wr_src reg_wr_src (.is_load(is_load), .ld(ld), .li(li), .imm(imm),
                        .thread_sel(thread_sel),
                        .mem_dout(mem_dout),
                        .alu_rlt_lane0(alu_rlt_lane0),
                        .alu_rlt_lane1(alu_rlt_lane1),
                        .alu_rlt_lane2(alu_rlt_lane2),
                        .alu_rlt_lane3(alu_rlt_lane3),
                        .result_lane0(result_lane0),
                        .result_lane1(result_lane1),
                        .result_lane2(result_lane2),
                        .result_lane3(result_lane3));

    gpu_instr_mem gpu_inmem(.instruction(instruction), .pc(pc));

    gpu_warp_scheduler gpu_warp_sche(.clk(clk),
                        .rst(rst),
                        .kernel_start(kernel_start),
                        .kernel_running(kernel_running),
                        .kernel_done(kernel_done),
                        .is_exit(is_exit),
                        .is_cmp(is_cmp),
                        .is_end(is_end),
                        .is_mask(is_mask),
                        .is_maskrst(is_maskrst),
                        .active_mask(active_mask),
                        .cmp_pass(cmp_pass), .mask_val(imm[3:0]));

    gpu_lsu gpu_lsu (.clk(clk), .rst(rst), 
                        .is_store(is_store), 
                        .is_load(is_load), 
                        .pc_stall(pc_stall),
                        .thread_sel(thread_sel));


    gpu_alu alu_lane_0(.data1(R1_lane0),
                        .data2(is_move ? 32'b0 : RVx_lane0),
                        .alu_ctrl(alu_ctrl),
                        .result(alu_rlt_lane0));
    gpu_reg0 gpu_reg_0(.clk(clk), 
                        .rst(rst), 
                        .regwrite(regwrite_0), 
                        .write_data(result_lane0),
                        .rs1(rs1), .rs2(rs2),
                        .rd(rd), .R1(R1_lane0), .R2(R2_lane0));

    
    gpu_alu alu_lane_1(.data1(R1_lane1), 
                        .data2(is_move ? 32'b0 : RVx_lane1), 
                        .alu_ctrl(alu_ctrl), 
                        .result(alu_rlt_lane1));
    gpu_reg1 gpu_reg_1(.clk(clk), 
                        .rst(rst), 
                        .regwrite(regwrite_1), 
                        .write_data(result_lane1), 
                        .rs1(rs1), .rs2(rs2), 
                        .rd(rd), .R1(R1_lane1), .R2(R2_lane1));

    
    gpu_alu alu_lane_2(.data1(R1_lane2), 
                        .data2(is_move ? 32'b0 : RVx_lane2), 
                        .alu_ctrl(alu_ctrl), 
                        .result(alu_rlt_lane2));
    gpu_reg2 gpu_reg_2(.clk(clk), 
                        .rst(rst), 
                        .regwrite(regwrite_2), 
                        .write_data(result_lane2), 
                        .rs1(rs1), .rs2(rs2), 
                        .rd(rd), .R1(R1_lane2), .R2(R2_lane2));

    
    gpu_alu alu_lane_3(.data1(R1_lane3), 
                        .data2(is_move ? 32'b0 : RVx_lane3), 
                        .alu_ctrl(alu_ctrl), 
                        .result(alu_rlt_lane3));
    gpu_reg3 gpu_reg_3(.clk(clk), 
                        .rst(rst), 
                        .regwrite(regwrite_3), 
                        .write_data(result_lane3), 
                        .rs1(rs1), .rs2(rs2), 
                        .rd(rd), .R1(R1_lane3), .R2(R2_lane3));


    gpu_cmp_unit_top gpu_cmp_unit (
                        .R1_lane0(R1_lane0),
                        .R1_lane1(R1_lane1),
                        .R1_lane2(R1_lane2),
                        .R1_lane3(R1_lane3),
                        .imm_type(imm_type),
                        .imm(imm),
                        .cmp_lt(cmp_lt),
                        .cmp_eq(cmp_eq),
                        .R2_lane0(R2_lane0),
                        .R2_lane1(R2_lane1),
                        .R2_lane2(R2_lane2),
                        .R2_lane3(R2_lane3),
                        .RV_lane0(RV_lane0),
                        .RV_lane1(RV_lane1),
                        .RV_lane2(RV_lane2),
                        .RV_lane3(RV_lane3),
                        .cmp_pass(cmp_pass));


    gpu_decoder gpu_decoder (.opcode(instruction[31:28]), 
                        .rd_cmptype(instruction[27:24]), 
                        .rs1_raw(instruction[23:20]), 
                        .rs2_raw(instruction[19:16]), 
                        .imm_raw(instruction[15:0]), 
                        .active_mask(active_mask),
                        .imm_type(imm_type), 
                        .cmp_lt(cmp_lt),
                        .cmp_eq(cmp_eq),
                        .ld(ld),
                        .li(li),
                        .regwrite(regwrite),
                        .branch_taken(branch_taken),
                        .alu_ctrl(alu_ctrl),
                        .is_alu(is_alu), .is_load(is_load), .is_exit(is_exit), .is_move(is_move),
                        .is_store(is_store), .is_branch(is_branch), .is_end(is_end), 
                        .is_cmp(is_cmp), .is_maskrst(is_maskrst), .is_mask(is_mask),
                        .rs1(rs1), .rs2(rs2), .imm(imm), .rd(rd));


    gpu_dmem_top gpu_dmem_top (.clk(clk),
                        .is_load(is_load),
                        .is_store(is_store),
                        .thread_sel(thread_sel),
                        .R00_addr(alu_rlt_lane0),
                        .R10_addr(alu_rlt_lane1),
                        .R20_addr(alu_rlt_lane2),
                        .R30_addr(alu_rlt_lane3),
                        .R0_val(R2_lane0),
                        .R1_val(R2_lane1),
                        .R2_val(R2_lane2),
                        .R3_val(R3_lane3),
                        .mem_dout(mem_dout));

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end

endmodule


// module tb;
//     reg clk, rst, kernel_start;
//     wire kernel_done;
//     gpu_top dut(.clk(clk), .rst(rst), .kernel_done(kernel_done), .kernel_start(kernel_start));

//     always #5 clk = ~clk;

//     initial begin
//         clk= 1'b1;
//         rst= 1'b0;
//         kernel_start = 1'b0;

//         #5
//         kernel_start = 1'b1;

//         #7 rst = ~rst;

//         wait(dut.instruction == 32'hc0000000);
//         #10 $finish;
//     end

// endmodule