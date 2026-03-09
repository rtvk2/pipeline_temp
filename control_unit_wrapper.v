`include "cu.v"
`include "alu_cu.v"
module control_unit_top (
    input [6:0] opcode,
    input [2:0] instr11,
    input instr12,
    input zero_flag,
    output Branch, MemRead, MemtoReg, MemWrite, ALUSrc, RegWrite, pc_src,
    output [3:0] ALUControl
);

    wire [1:0] w_ALUOp;

    cu Main_Control (
        .opcode(opcode),
        .Branch(Branch),
        .MemRead(MemRead),
        .MemtoReg(MemtoReg),
        .ALUOp(w_ALUOp),
        .MemWrite(MemWrite),
        .ALUSrc(ALUSrc),
        .RegWrite(RegWrite)
    );

    alu_cu ALU_Control (
        .ALUOp(w_ALUOp),
        .funct3(instr11),
        .funct7_bit(instr12),
        .ALUControl(ALUControl)
    );

    // Decision Gate
    and Branch_Gate (pc_src, Branch, zero_flag);


endmodule

