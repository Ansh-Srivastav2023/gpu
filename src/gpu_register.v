module gpu_reg0 (
    input clk,
    input rst,
    input regwrite,
    input [3:0] rs1,
    input [3:0] rs2,
    input [3:0] rd,
    input [31:0] write_data,
    output signed [31:0] R1,
    output signed [31:0] R2
);

    reg signed [31:0] thread_reg [0:7];

    assign R1 = thread_reg[rs1[2:0]];
    assign R2 = thread_reg[rs2[2:0]];

    integer i;
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            for (i = 0; i < 8; i = i + 1)
                thread_reg[i] <= 32'b0;
        end
        else if (regwrite) begin
            thread_reg[rd[2:0]] <= write_data;
        end
    end

endmodule

module gpu_reg1 (
    input clk,
    input rst,
    input regwrite,
    input [3:0] rs1,
    input [3:0] rs2,
    input [3:0] rd,
    input [31:0] write_data,
    output signed [31:0] R1,
    output signed [31:0] R2
);

    reg signed [31:0] thread_reg [0:7];

    assign R1 = thread_reg[rs1[2:0]];
    assign R2 = thread_reg[rs2[2:0]];

    integer i;
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            for (i = 0; i < 8; i = i + 1)
                thread_reg[i] <= 32'b0;
        end
        else if (regwrite) begin
            thread_reg[rd[2:0]] <= write_data;
        end
    end

endmodule

module gpu_reg2 (
    input clk,
    input rst,
    input regwrite,
    input [3:0] rs1,
    input [3:0] rs2,
    input [3:0] rd,
    input [31:0] write_data,
    output signed [31:0] R1,
    output signed [31:0] R2
);

    reg signed [31:0] thread_reg [0:7];

    assign R1 = thread_reg[rs1[2:0]];
    assign R2 = thread_reg[rs2[2:0]];

    integer i;
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            for (i = 0; i < 8; i = i + 1)
                thread_reg[i] <= 32'b0;
        end
        else if (regwrite) begin
            thread_reg[rd[2:0]] <= write_data;
        end
    end

endmodule

module gpu_reg3 (
    input clk,
    input rst,
    input regwrite,
    input [3:0] rs1,
    input [3:0] rs2,
    input [3:0] rd,
    input [31:0] write_data,
    output signed [31:0] R1,
    output signed [31:0] R2
);

    reg signed [31:0] thread_reg [0:7];

    assign R1 = thread_reg[rs1[2:0]];
    assign R2 = thread_reg[rs2[2:0]];

    integer i;
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            for (i = 0; i < 8; i = i + 1)
                thread_reg[i] <= 32'b0;
        end
        else if (regwrite) begin
            thread_reg[rd[2:0]] <= write_data;
        end
    end

endmodule

