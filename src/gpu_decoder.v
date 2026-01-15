module instr_class_decoder(
    input [3:0] opcode,
    output reg is_alu,
    output reg is_load,
    output reg is_store,
    output reg is_cmp,
    output reg is_branch,
    output reg is_exit,
    output reg is_end,
    output reg is_move,
    output reg is_mask,
    output reg is_maskrst
);
    always @(*) begin
        // Defaults
        is_alu = 0; is_load = 0; is_store = 0; is_cmp = 0; is_move = 0;
        is_branch = 0; is_exit = 0; is_end = 0; is_maskrst = 0; is_mask = 0;

        case (opcode)
            // ADD, SUB, MUL, DIV(new), ADDI, MOV
            4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101: is_alu = 1; 
            4'b0110: is_move    = 1;
            4'b0111: is_load    = 1; 
            4'b1000: is_store   = 1; 
            4'b1001: is_cmp     = 1; 
            4'b1010: is_branch  = 1; 
            4'b1011: is_exit    = 1; 
            4'b1100: is_end     = 1;
            4'b1110: is_mask    = 1;
            4'b1101: is_maskrst = 1;
            default: ; // NOP or undefined
        endcase
    end
endmodule


module alu_ctrl_decoder(
    input [3:0] opcode,
    output reg [3:0] alu_ctrl
);
    always @(*) begin
        case(opcode)
            4'b0001, 4'b0111, 4'b0101, 4'b0110, 4'b1000: alu_ctrl = 4'b0001; // ADD
            4'b0010: alu_ctrl = 4'b0010; // SUB
            4'b0011: alu_ctrl = 4'b0011; // MUL
            4'b0100: alu_ctrl = 4'b0100; // DIV 
            default: alu_ctrl = 4'b0000; 
        endcase
    end
endmodule


module immediate_decoder(
    input [3:0] opcode,
    input [15:0] imm_in,
    output reg imm_type,
    output reg [15:0] imm_val
);
    always @(*) begin
        imm_val = imm_in; // Pass through the value
        
        case(opcode)
            4'b0101, // ADDI 
            4'b0111, // LOAD 
            4'b1000, // STORE 
            4'b1001, // CMP 
            4'b1010, // BRANCH 
            4'b1011: // EXIT 
                imm_type = 1'b1;
            default: 
                imm_type = 1'b0;
        endcase
    end
endmodule


module cmp_ctrl_decoder(
    input [3:0] opcode,
    input [3:0] rd_cmptype,
    input [3:0] rs2_ldtype,
    output reg cmp_lt,
    output reg cmp_eq,
    output reg ld, li
);
    always @(*) begin
        cmp_lt = 0;
        cmp_eq = 0;
        ld = 0; 
        li = 0;
        
        if (opcode == 4'b1001) begin 
            case (rd_cmptype)
                4'b0001: cmp_lt = 1'b1;
                4'b0010: cmp_eq = 1'b1;

                default: begin 
                    cmp_lt = 0; cmp_eq = 0; 
                end
            endcase
        end

        if(opcode ==  4'b0111) begin
            case (rs2_ldtype)
                4'b0001: ld = 1'b1;
                4'b0010: li = 1'b1;
                default: begin
                    ld = 0; li = 0;
                end
            endcase
        end
    end
endmodule


module wb_ctrl_decoder(
    input [3:0] opcode,
    input [3:0] active_mask,
    output reg regwrite,
    output reg branch_taken,
    output reg exit_instr
);
    always @(*) begin
        // Defaults
        regwrite = 0; branch_taken = 0; exit_instr = 0;

        case(opcode)
            // ALU Ops (ADD, SUB, MUL, DIV, ADDI, MOV) + LOAD(0111)
            4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111: 
                regwrite = 1'b1; 
            
            4'b1010: branch_taken= |active_mask; // BRANCH 
            4'b1011: exit_instr  = 1'b1; // EXIT 
            default: ;
        endcase
    end
endmodule


module gpu_decoder(
    input [3:0] opcode, 
    input [3:0] rd_cmptype, 
    input [3:0] rs1_raw, 
    input [3:0] rs2_raw,
    input [15:0] imm_raw,
    input [3:0] active_mask,

    output imm_type,      
    output cmp_lt, 
    output cmp_eq,
    output ld,
    output li,
    output regwrite, 
    output branch_taken, is_alu, is_branch, is_cmp, is_end, is_load, is_store, is_exit, is_maskrst, is_move, is_mask,
    output [3:0] alu_ctrl,
    output [3:0] rs1, rs2,
    output [15:0] imm,
    output [3:0] rd
);

    wire [15:0] imm_val_internal; 

    assign imm = imm_raw;
    assign rd  = rd_cmptype;
    assign rs1 = rs1_raw;
    assign rs2 = rs2_raw;

    // 1. Instruction Class Decoder
    instr_class_decoder inst_class_inst (
        .opcode(opcode),
        .is_alu(is_alu), .is_load(is_load), .is_store(is_store), .is_move(is_move),
        .is_cmp(is_cmp), .is_branch(is_branch), .is_exit(is_exit), .is_end(is_end), .is_maskrst(is_maskrst), .is_mask(is_mask)
    );

    // 2. ALU Control Decoder
    alu_ctrl_decoder alu_ctrl_inst (
        .opcode(opcode),
        .alu_ctrl(alu_ctrl)
    );

    // 3. Immediate Decoder
    immediate_decoder imm_dec_inst (
        .opcode(opcode),
        .imm_in(imm_raw),
        .imm_type(imm_type),
        .imm_val(imm_val_internal)
    );

    // 4. Compare Control Decoder
    cmp_ctrl_decoder cmp_dec_inst (
        .opcode(opcode),
        .rd_cmptype(rd_cmptype),
        .rs2_ldtype(rs2_raw),
        .cmp_lt(cmp_lt),
        .cmp_eq(cmp_eq), .ld(ld), .li(li)
    );

    // 5. Writeback & Control Decoder
    wire wb_exit_wire; 
    
    wb_ctrl_decoder wb_ctrl_inst (
        .opcode(opcode),
        .regwrite(regwrite),
        .branch_taken(branch_taken),
        .exit_instr(wb_exit_wire),
        .active_mask(active_mask)
    );

endmodule


// initial decoder

// module gpu_decoder(opcode, rd_cmptype, rs1, rs2, imm, cmp_lt, cmp_eq, regwrite, alu_ctrl, imm_type, kernel_done, branch);

//     input [3:0] opcode, rd_cmptype, rs1, rs2;
//     input [15:0] imm;

//     output reg imm_type; // 1 = imm value
//     output reg cmp_lt, regwrite, cmp_eq, exit_instr, kernel_done, branch;
//     output reg [3:0] alu_ctrl;

//     always @(*) begin
//         cmp_lt      = 0;
//         cmp_eq      = 0;
//         branch      = 1'b0;
//         imm_type    = 1'b0;
//         regwrite   = 1'b0;
//         exit_instr  = 1'b0;
//         kernel_done = 1'b0;
//         alu_ctrl    = 4'b0000;

//         case(opcode)
//             4'b0000: begin //NOP
//                 cmp_lt      = 0;
//                 cmp_eq      = 0;
//                 branch      = 1'b0;
//                 imm_type    = 1'b0;
//                 regwrite   = 1'b0;
//                 exit_instr  = 1'b0;
//                 kernel_done = 1'b0;
//                 alu_ctrl    = 4'b0000;
//             end

//             4'b0001: begin //ADD
//                 cmp_lt      = 0;
//                 cmp_eq      = 0;
//                 branch      = 1'b0;
//                 imm_type    = 1'b0;
//                 regwrite   = 1'b1;
//                 exit_instr  = 1'b0;
//                 kernel_done = 1'b0;
//                 alu_ctrl    = 4'b0000;
//             end

//             4'b0010: begin //SUB
//                 cmp_lt      = 0;
//                 cmp_eq      = 0;
//                 branch      = 1'b0;
//                 imm_type    = 1'b0;
//                 regwrite   = 1'b1;
//                 exit_instr  = 1'b0;
//                 kernel_done = 1'b0;
//                 alu_ctrl    = 4'b0001;                
//             end

//             4'b0011: begin //MUL
//                 cmp_lt      = 0;
//                 cmp_eq      = 0;
//                 branch      = 1'b0;
//                 imm_type    = 1'b0;
//                 regwrite   = 1'b1;
//                 exit_instr  = 1'b0;
//                 kernel_done = 1'b0;
//                 alu_ctrl    = 4'b0010;                
//             end

//             4'b0100: begin //ADDI
//                 cmp_lt      = 0;
//                 cmp_eq      = 0;
//                 branch      = 1'b0;
//                 imm_type    = 1'b1;
//                 regwrite   = 1'b1;
//                 exit_instr  = 1'b0;
//                 kernel_done = 1'b0;
//                 alu_ctrl    = 4'b0011;                
//             end

//             4'b0101: begin //MOV
//                 cmp_lt      = 0;
//                 cmp_eq      = 0;
//                 branch      = 1'b0;
//                 imm_type    = 1'b0;
//                 regwrite   = 1'b1;
//                 exit_instr  = 1'b0;
//                 kernel_done = 1'b0;
//                 alu_ctrl    = 4'b0000;                
//             end
//             4'b0110: begin //LOAD
//                 cmp_lt      = 0;
//                 cmp_eq      = 0;
//                 branch      = 1'b0;
//                 imm_type    = 1'b1;
//                 regwrite   = 1'b1;
//                 exit_instr  = 1'b0;
//                 kernel_done = 1'b0;
//                 alu_ctrl    = 4'b0000;                
//             end

//             4'b0111: begin //STORE  MEM[ RS1 + OFFSET + (R0 * 4) ] = RS2
//                 cmp_lt      = 0;
//                 cmp_eq      = 0;
//                 branch      = 1'b0;
//                 imm_type    = 1'b1;
//                 regwrite   = 1'b0;
//                 exit_instr  = 1'b0;
//                 kernel_done = 1'b0;
//                 alu_ctrl    = 4'b0000;                
//             end

//             4'b1000: begin //CMP --> uses gpu_cmp_unit.v
//                 case (rd_cmptype)
//                     4'b0001: begin //cmp_lt
//                         cmp_lt = 1'b1;
//                         cmp_eq = 1'b0;
//                     end
//                     4'b0010: begin  //cmp_eq
//                         cmp_lt = 1'b0;
//                         cmp_eq = 1'b1;
//                     end
//                     default: begin
//                         cmp_lt = 1'b0;
//                         cmp_eq = 1'b0;
//                     end
//                 endcase              
//                 imm_type    = 1'b1;
//                 regwrite   = 1'b0;
//                 branch      = 1'b0;
//                 exit_instr  = 1'b0;
//                 kernel_done = 1'b0;
//                 alu_ctrl    = 4'b0000;                
//             end

//             4'b1001: begin // BRANCH
//                 cmp_lt      = 0;
//                 cmp_eq      = 0;
//                 branch      = 1'b1;
//                 imm_type    = 1'b1;
//                 regwrite   = 1'b0;
//                 exit_instr  = 1'b0;
//                 kernel_done = 1'b0;
//                 alu_ctrl    = 4'b0000;
//             end
            
//             4'b1010: begin //EXIT
//                 cmp_lt      = 0;
//                 cmp_eq      = 0;
//                 branch      = 1'b0;
//                 imm_type    = 1'b1;
//                 regwrite   = 1'b0;
//                 exit_instr  = 1'b1;
//                 kernel_done = 1'b0;
//                 alu_ctrl    = 4'b0000;                
//             end
            
//             4'b1011: begin //END
//                 cmp_lt      = 0;
//                 cmp_eq      = 0;
//                 branch      = 1'b0;
//                 imm_type    = 1'b0;
//                 regwrite   = 1'b0;
//                 exit_instr  = 1'b0;
//                 kernel_done = 1'b1;
//                 alu_ctrl    = 4'b0000;
//             end
            
//             default: begin
//                 cmp_lt      = 0;
//                 cmp_eq      = 0;
//                 branch      = 1'b0;
//                 imm_type    = 1'b0;
//                 regwrite   = 1'b0;
//                 exit_instr  = 1'b0;
//                 kernel_done = 1'b0;
//                 alu_ctrl    = 4'b0000;
//             end
//         endcase
//     end

// endmodule