module gpu_instr_mem(pc, instruction);

    input signed [31:0] pc;
    output [31:0] instruction;

    reg [31:0] gpu_imem [0:49];

    initial begin
        $readmemh("gpu_imem.hex", gpu_imem);
    end

    assign instruction = gpu_imem[pc[31:2]];

endmodule