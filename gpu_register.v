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

    assign R1 = thread_reg[rs1];
    assign R2 = thread_reg[rs2];

    integer i;
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            thread_reg[0] = 0;
            for (i = 1; i < 8; i = i + 1)
                thread_reg[i] <= 32'b0;
        end
        else if (regwrite) begin
            thread_reg[rd] <= write_data;
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

    assign R1 = thread_reg[rs1];
    assign R2 = thread_reg[rs2];

    integer i;
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            thread_reg[0] = 1;
            for (i = 1; i < 8; i = i + 1)
                thread_reg[i] <= 32'b0;
        end
        else if (regwrite) begin
            thread_reg[rd] <= write_data;
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

    assign R1 = thread_reg[rs1];
    assign R2 = thread_reg[rs2];

    integer i;
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            thread_reg[0] = 2;
            for (i = 1; i < 8; i = i + 1)
                thread_reg[i] <= 32'b0;
        end
        else if (regwrite) begin
            thread_reg[rd] <= write_data;
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

    assign R1 = thread_reg[rs1];
    assign R2 = thread_reg[rs2];

    integer i;
    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            thread_reg[0] = 3;
            for (i = 1; i < 8; i = i + 1)
                thread_reg[i] <= 32'b0;
        end
        else if (regwrite) begin
            thread_reg[rd] <= write_data;
        end
    end

endmodule

