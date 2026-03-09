`timescale 1ns/1ps

module hazard_unit(
    // ------------------------------------------------------------------
    //  FORWARDING UNIT inputs
    //  Compare source registers of the EX-stage instruction against the
    //  destination registers of instructions in MEM and WB stages.
    // ------------------------------------------------------------------
    input [4:0] rsE, rtE,           // Rs1E, Rs2E  — source regs of EX instr
    input [4:0] WriteRegM, WriteRegW, // RdM, RdW   — dest regs of MEM/WB instrs
    input       RegWriteM, RegWriteW, // Whether MEM / WB will write to RF

    // ------------------------------------------------------------------
    //  HAZARD DETECTION UNIT inputs
    //  Detect load-use hazard: load in EX, dependent instruction in ID.
    // ------------------------------------------------------------------
    input [4:0] rsD, rtD,           // Rs1D, Rs2D — source regs of ID instr
    input [4:0] WriteRegE,          // RdE        — dest reg of EX-stage instr
    input       MemtoRegE,          // 1 when a load instruction is in EX

    // ------------------------------------------------------------------
    //  CONTROL HAZARD input
    //  Branch resolved in EX stage; taken branch requires flushing two stages.
    // ------------------------------------------------------------------
    input       PCSrcE,             // 1 when branch is taken (BranchE & ZeroE)

    // ------------------------------------------------------------------
    //  Forwarding mux control outputs (to ALU input muxes in EX stage)
    // ------------------------------------------------------------------
    output reg [1:0] ForwardAE,     // Selects SrcAE: 00=RF, 10=ALUResultM, 01=ResultW
    output reg [1:0] ForwardBE,     // Selects SrcBE: 00=RF, 10=ALUResultM, 01=ResultW

    // ------------------------------------------------------------------
    //  Pipeline stall and flush control outputs
    // ------------------------------------------------------------------
    output StallF,  // Hold IF/ID  (disable PC and IF/ID register writes)
    output StallD,  // Hold ID/EX  (disable IF/ID register write)
    output FlushD,  // Clear IF/ID  register — squashes wrong-path instr after branch
    output FlushE   // Clear ID/EX register — inserts NOP bubble on stall or branch
);

    // ------------------------------------------------------------------
    //  FORWARDING UNIT
    //
    //  Forward from MEM stage (2'b10) if:
    //    - MEM instruction writes to RF  (RegWriteM)
    //    - its destination matches the EX source register
    //    - destination is not x0
    //
    //  Forward from WB stage (2'b01) if:
    //    - WB instruction writes to RF   (RegWriteW)
    //    - its destination matches the EX source register
    //    - destination is not x0
    //    - MEM stage is NOT already forwarding the same register
    //      (the else-if ensures MEM takes priority when both match)
    //
    //  No forward (2'b00): use value directly from register file.
    // ------------------------------------------------------------------

    // ForwardAE — controls first ALU operand (SrcAE)
    always @(*) begin
        if      ((rsE != 0) && (rsE == WriteRegM) && RegWriteM) ForwardAE = 2'b10;
        else if ((rsE != 0) && (rsE == WriteRegW) && RegWriteW) ForwardAE = 2'b01;
        else                                                     ForwardAE = 2'b00;
    end

    // ForwardBE — controls second ALU operand (SrcBE / WriteDataE)
    always @(*) begin
        if      ((rtE != 0) && (rtE == WriteRegM) && RegWriteM) ForwardBE = 2'b10;
        else if ((rtE != 0) && (rtE == WriteRegW) && RegWriteW) ForwardBE = 2'b01;
        else                                                     ForwardBE = 2'b00;
    end

    // ------------------------------------------------------------------
    //  HAZARD DETECTION UNIT  (load-use stall)
    //
    //  A load instruction reads memory in the MEM stage, so its result is
    //  not available until after MEM — one cycle later than a normal ALU
    //  result.  Forwarding alone cannot cover this gap; we must stall.
    //
    //  Stall condition: a load (MemtoRegE=1) is in EX AND its destination
    //  register (WriteRegE / RdE) matches either source register of the
    //  instruction currently in ID (rsD / rtD).
    //
    //  Stalling: disable the write-enable of IF and ID pipeline registers
    //  (StallF, StallD) so those stages hold their current data one extra
    //  cycle.  Simultaneously flush the ID/EX register (FlushE) to inject
    //  a NOP bubble into the Execute stage.
    // ------------------------------------------------------------------
    wire lwstall;
    assign lwstall = ((rsD == WriteRegE) || (rtD == WriteRegE)) && MemtoRegE;

    assign StallF = lwstall;
    assign StallD = lwstall;

    // ------------------------------------------------------------------
    //  CONTROL HAZARD HANDLING  (branch flush)
    //
    //  Strategy: predict NOT TAKEN — keep fetching PC+4 sequentially.
    //  If the branch IS taken (PCSrcE=1, resolved in EX at cycle 3):
    //    - Two instructions have been fetched speculatively (cycles 2 & 3).
    //    - FlushD clears the IF/ID register  → squashes the instr in Decode.
    //    - FlushE clears the ID/EX register  → squashes the instr in Execute.
    //  This imposes a 2-cycle branch misprediction penalty.
    //
    //  FlushE also fires on a load-use stall to inject the NOP bubble.
    // ------------------------------------------------------------------
    assign FlushD = PCSrcE;
    assign FlushE = lwstall | PCSrcE;

endmodule
