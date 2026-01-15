module gpu_cmp_unit(R1_lane0, R1_lane1, R1_lane2, R1_lane3, RV_lane0, RV_lane1, RV_lane2, RV_lane3, cmp_lt, cmp_eq, cmp_pass);

    input cmp_lt, cmp_eq;
    input signed [31:0] R1_lane0, R1_lane1, R1_lane2, R1_lane3; //Array A
    input signed [31:0] RV_lane0, RV_lane1, RV_lane2, RV_lane3; //Array B --> imm or rs2 data
    output [3:0] cmp_pass;
    
    assign cmp_pass[0] = cmp_lt ? (R1_lane0<RV_lane0) : cmp_eq ? (R1_lane0==RV_lane0) : 1'b0;
    assign cmp_pass[1] = cmp_lt ? (R1_lane1<RV_lane1) : cmp_eq ? (R1_lane1==RV_lane1) : 1'b0;
    assign cmp_pass[2] = cmp_lt ? (R1_lane2<RV_lane2) : cmp_eq ? (R1_lane2==RV_lane2) : 1'b0;
    assign cmp_pass[3] = cmp_lt ? (R1_lane3<RV_lane3) : cmp_eq ? (R1_lane3==RV_lane3) : 1'b0;

endmodule

module gpu_imm_rs2_dmux (imm, imm_type, R_lane0, R_lane1, R_lane2, R_lane3, RV_lane0, RV_lane1, RV_lane2, RV_lane3);

    input imm_type;
    input signed [15:0] imm;
    input signed [31:0] R_lane0, R_lane1, R_lane2, R_lane3;

    output [31:0] RV_lane0, RV_lane1, RV_lane2, RV_lane3;

    assign RV_lane0 = imm_type ? {{16{imm[15]}}, imm} : R_lane0;
    assign RV_lane1 = imm_type ? {{16{imm[15]}}, imm} : R_lane1;
    assign RV_lane2 = imm_type ? {{16{imm[15]}}, imm} : R_lane2;
    assign RV_lane3 = imm_type ? {{16{imm[15]}}, imm} : R_lane3;

endmodule

module gpu_cmp_unit_top (R1_lane0, R1_lane1, R1_lane2, R1_lane3,
                        imm_type, imm, cmp_lt, cmp_eq,
                        R2_lane0, R2_lane1, R2_lane2, R2_lane3, 
                        RV_lane0, RV_lane1, RV_lane2, RV_lane3,
                        cmp_pass);

    input imm_type, cmp_lt, cmp_eq;
    input signed [15:0] imm;
    input signed [31:0] R1_lane0, R1_lane1, R1_lane2, R1_lane3;
    input signed [31:0] R2_lane0, R2_lane1, R2_lane2, R2_lane3;

    output [3:0] cmp_pass;
    output signed [31:0] RV_lane0, RV_lane1, RV_lane2, RV_lane3;

    gpu_cmp_unit gpu_cmp_unit(.R1_lane0(R1_lane0),
                .R1_lane1(R1_lane1),
                .R1_lane2(R1_lane2),
                .R1_lane3(R1_lane3),
                .RV_lane0(RV_lane0),
                .RV_lane1(RV_lane1),
                .RV_lane2(RV_lane2),
                .RV_lane3(RV_lane3),
                .cmp_lt(cmp_lt),
                .cmp_eq(cmp_eq),
                .cmp_pass(cmp_pass));

    gpu_imm_rs2_dmux gpu_imm_rs2_dmux(.imm(imm),
                .imm_type(imm_type),
                .R_lane0(R2_lane0),
                .R_lane1(R2_lane1),
                .R_lane2(R2_lane2),
                .R_lane3(R2_lane3),
                .RV_lane0(RV_lane0),
                .RV_lane1(RV_lane1),
                .RV_lane2(RV_lane2),
                .RV_lane3(RV_lane3));    

endmodule