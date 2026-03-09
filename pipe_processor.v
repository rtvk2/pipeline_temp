`timescale 1ns / 1ps
`include "control_unit_wrapper.v"
`include "data_unit_wrapper.v"

module pipe_processor(
    input clk,
    input reset
);
    wire [31:0] InstrD;
    wire ZeroE;
    
    // Control unit outputs
    wire BranchD, MemReadD, MemtoRegD, MemWriteD, ALUSrcD, RegWriteD;
    wire [3:0] ALUControlD;
    
    // In pipelined architecture, Control Unit takes InstrD (Instruction from Decode Stage)
    // and generates control signals for the Decode stage.
    control_unit_top CU_inst(
        .opcode(InstrD[6:0]),
        .instr11(InstrD[14:12]),
        .instr12(InstrD[30]),
        .zero_flag(ZeroE),
        .Branch(BranchD),
        .MemRead(MemReadD),
        .MemtoReg(MemtoRegD),
        .MemWrite(MemWriteD),
        .ALUSrc(ALUSrcD),
        .RegWrite(RegWriteD),
        .pc_src(), // Ignored in pipelined
        .ALUControl(ALUControlD)
    );

    data_module DU_inst(
        .clk(clk),
        .reset(reset),
        .ALUSrcD(ALUSrcD),
        .MemtoRegD(MemtoRegD),
        .RegWriteD(RegWriteD),
        .MemWriteD(MemWriteD),
        .MemReadD(MemReadD),
        .BranchD(BranchD),
        .ALUControlD(ALUControlD),
        .InstrD(InstrD),
        .ZeroE(ZeroE)
    );

endmodule
