`timescale 1ns / 1ps
`include "pc.v"
`include "reg_file.v"
`include "ig.v"
`include "instruction_mem.v"
`include "data_mem.v"
`include "alu.v"
`include "if_id.v"
`include "id_ex.v"
`include "ex_mem.v"
`include "mem_wb.v"
`include "hazard_unit.v"

module data_module(
    input clk,
    input reset,
    // Control signals from external Control Unit (Decode stage)
    input ALUSrcD,
    input MemtoRegD,
    input RegWriteD,
    input MemWriteD,
    input MemReadD,
    input BranchD,
    input [3:0] ALUControlD,
    // Outputs for Control Unit
    output [31:0] InstrD,
    output ZeroE
);

    // =============================================================
    //  IF Stage Wires
    // =============================================================
    wire [63:0] PCF;
    wire [63:0] PCPlus4F;
    wire [31:0] InstrF;
    wire [63:0] next_pc;
    wire [63:0] pc_input;

    // =============================================================
    //  ID Stage Wires (after IF/ID)
    // =============================================================
    wire [63:0] PCD;
    wire [63:0] RD1D, RD2D;
    wire [63:0] ImmExtD;
    wire [4:0]  Rs1D, Rs2D, RdD;

    // =============================================================
    //  EX Stage Wires (after ID/EX)
    // =============================================================
    wire        RegWriteE, MemtoRegE, MemReadE, MemWriteE, BranchE, ALUSrcE;
    wire [3:0]  ALUControlE;
    wire [63:0] PCE, RD1E, RD2E, ImmExtE;
    wire [4:0]  RdE, Rs1E, Rs2E;
    wire [63:0] SrcAE, WriteDataE, SrcBE;
    wire [63:0] ALUResultE;
    wire [63:0] PCTargetE;
    wire        PCSrcE;

    // =============================================================
    //  MEM Stage Wires (after EX/MEM)
    // =============================================================
    wire        RegWriteM, MemtoRegM, MemReadM, MemWriteM;
    wire [63:0] ALUResultM;
    wire [63:0] WriteDataM;
    wire [63:0] ReadDataM;
    wire [4:0]  RdM;

    // =============================================================
    //  WB Stage Wires (after MEM/WB)
    // =============================================================
    wire        RegWriteW, MemtoRegW;
    wire [63:0] ALUResultW;
    wire [63:0] ReadDataW;
    wire [63:0] ResultW;
    wire [4:0]  RdW;

    // =============================================================
    //  Hazard Unit Wires
    // =============================================================
    wire [1:0]  ForwardAE, ForwardBE;
    wire        StallF, StallD, FlushD, FlushE;

    // =============================================================
    //  IF STAGE
    // =============================================================

    // PC + 4
    assign PCPlus4F = PCF + 64'd4;

    // Next PC Mux: branch target or PC+4
    assign next_pc = PCSrcE ? PCTargetE : PCPlus4F;

    // Stall: hold current PC when pipeline is stalled
    assign pc_input = StallF ? PCF : next_pc;

    // Program Counter
    program_counter pc_inst (
        .clk(clk),
        .reset(reset),
        .pc_in(pc_input),
        .pc_out(PCF)
    );

    // Instruction Memory
    instruction_mem imem_inst (
        .addr(PCF),
        .instr(InstrF)
    );

    // =============================================================
    //  IF/ID Pipeline Register
    // =============================================================
    if_id if_id_inst (
        .clk(clk),
        .reset(reset),
        .flush(FlushD),
        .IF_ID_write(~StallD),
        .IF_ID_pc_in(PCF),
        .IF_ID_instr_in(InstrF),
        .IF_ID_pc_out(PCD),
        .IF_ID_instr_out(InstrD)
    );

    // =============================================================
    //  ID STAGE
    // =============================================================

    // Instruction field extraction
    assign Rs1D = InstrD[19:15];
    assign Rs2D = InstrD[24:20];
    assign RdD  = InstrD[11:7];

    // Register File (read in ID, write in WB)
    reg_file regfile_inst (
        .clk(clk),
        .reset(reset),
        .read_reg1(Rs1D),
        .read_reg2(Rs2D),
        .write_reg(RdW),
        .write_data(ResultW),
        .reg_write_en(RegWriteW),
        .read_data1(RD1D),
        .read_data2(RD2D)
    );

    // Immediate Generator
    ig imm_gen_inst (
        .instr(InstrD),
        .imm_data(ImmExtD)
    );

    // =============================================================
    //  ID/EX Pipeline Register
    // =============================================================
    id_ex id_ex_inst (
        .clk(clk),
        .reset(reset),
        .flush(FlushE),
        // Control In
        .mem_to_reg(MemtoRegD),
        .reg_write_en(RegWriteD),
        .mem_read(MemReadD),
        .mem_write(MemWriteD),
        .branch(BranchD),
        .alu_src(ALUSrcD),
        .alu_control(ALUControlD),
        // Data In
        .ID_EX_pc_in(PCD),
        .data_in_1(RD1D),
        .data_in_2(RD2D),
        .imm_gen(ImmExtD),
        .ID_EX_rd_in(RdD),
        .ID_EX_rs1_in(Rs1D),
        .ID_EX_rs2_in(Rs2D),
        // Control Out
        .mem_to_reg_out(MemtoRegE),
        .reg_write_en_out(RegWriteE),
        .mem_read_out(MemReadE),
        .mem_write_out(MemWriteE),
        .branch_out(BranchE),
        .alu_src_out(ALUSrcE),
        .alu_control_out(ALUControlE),
        // Data Out
        .ID_EX_MEM_pc_out(PCE),
        .data_out_1(RD1E),
        .data_out_2(RD2E),
        .imm_gen_out(ImmExtE),
        .ID_EX_MEM_rd_out(RdE),
        .ID_EX_MEM_rs1_out(Rs1E),
        .ID_EX_MEM_rs2_out(Rs2E)
    );

    // =============================================================
    //  EX STAGE
    // =============================================================

    // Forwarding Mux A (SrcAE): 00=RD1E, 10=ALUResultM, 01=ResultW
    assign SrcAE = (ForwardAE == 2'b10) ? ALUResultM :
                   (ForwardAE == 2'b01) ? ResultW :
                                          RD1E;

    // Forwarding Mux B (WriteDataE): 00=RD2E, 10=ALUResultM, 01=ResultW
    assign WriteDataE = (ForwardBE == 2'b10) ? ALUResultM :
                        (ForwardBE == 2'b01) ? ResultW :
                                               RD2E;

    // ALU Source Mux: 0=Forwarded register data, 1=Immediate
    assign SrcBE = ALUSrcE ? ImmExtE : WriteDataE;

    // ALU
    alu_64_bit alu_inst (
        .a(SrcAE),
        .b(SrcBE),
        .opcode(ALUControlE),
        .result(ALUResultE),
        .zero_flag(ZeroE),
        .cout(),
        .carry_flag(),
        .overflow_flag()
    );

    // Branch Target Adder: PCE + ImmExtE
    assign PCTargetE = PCE + ImmExtE;

    // Branch Decision: PCSrcE = BranchE AND ZeroE
    assign PCSrcE = BranchE & ZeroE;

    // =============================================================
    //  EX/MEM Pipeline Register
    // =============================================================
    ex_mem ex_mem_inst (
        .clk(clk),
        .reset(reset),
        // Control In
        .mem_to_reg(MemtoRegE),
        .reg_write_en(RegWriteE),
        .mem_read(MemReadE),
        .mem_write(MemWriteE),
        // Data In
        .alu_out(ALUResultE),
        .data2(WriteDataE),
        .rd(RdE),
        .rs2_ID_EX(Rs2E),
        // Control Out
        .mem_to_reg_out(MemtoRegM),
        .reg_write_en_out(RegWriteM),
        .mem_read_out(MemReadM),
        .mem_write_out(MemWriteM),
        // Data Out
        .alu_out_out(ALUResultM),
        .data2_out(WriteDataM),
        .rd_out(RdM),
        .rs2_ID_EX_out()
    );

    // =============================================================
    //  MEM STAGE
    // =============================================================
    data_mem dmem_inst (
        .clk(clk),
        .reset(reset),
        .address(ALUResultM),
        .write_data(WriteDataM),
        .MemWrite(MemWriteM),
        .MemRead(MemReadM),
        .read_data(ReadDataM)
    );

    // =============================================================
    //  MEM/WB Pipeline Register
    // =============================================================
    mem_wb mem_wb_inst (
        .clk(clk),
        .reset(reset),
        // Control In
        .mem_to_reg(MemtoRegM),
        .reg_write_en(RegWriteM),
        // Data In
        .data(ReadDataM),
        .alu_out(ALUResultM),
        .rd(RdM),
        // Data Out
        .data_out(ReadDataW),
        .alu_out_out(ALUResultW),
        .rd_out(RdW),
        // Control Out
        .mem_to_reg_out(MemtoRegW),
        .reg_write_en_out(RegWriteW)
    );

    // =============================================================
    //  WB STAGE
    // =============================================================

    // Result Mux: 0=ALU Result, 1=Memory Read Data
    assign ResultW = MemtoRegW ? ReadDataW : ALUResultW;

    // =============================================================
    //  HAZARD UNIT
    // =============================================================
    hazard_unit hazard_inst (
        .rsE(Rs1E),
        .rtE(Rs2E),
        .WriteRegM(RdM),
        .WriteRegW(RdW),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),
        .rsD(Rs1D),
        .rtD(Rs2D),
        .WriteRegE(RdE),
        .MemtoRegE(MemtoRegE),
        .PCSrcE(PCSrcE),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        .StallF(StallF),
        .StallD(StallD),
        .FlushD(FlushD),
        .FlushE(FlushE)
    );

endmodule