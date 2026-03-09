`timescale 1ns/1ps

module hazard_unit(
    input [4:0] rsD, rtD, rsE, rtE, WriteRegE, WriteRegM, WriteRegW,
    input RegWriteE, RegWriteM, RegWriteW, MemtoRegE, MemtoRegM, BranchD,
    output reg [1:0] ForwardAE, ForwardBE,
    output ForwardAD, ForwardBD,
    output StallF, StallD, FlushE
);

    // --- EX HAZARD: MEM->EX forwarding ---
    always @(*) begin
        if ((rsE != 0) && (rsE == WriteRegM) && RegWriteM)
            ForwardAE = 2'b10;
        else if ((rsE != 0) && (rsE == WriteRegW) && RegWriteW)
            ForwardAE = 2'b01;
        else
            ForwardAE = 2'b00;
    end

    always @(*) begin
        if ((rtE != 0) && (rtE == WriteRegM) && RegWriteM)
            ForwardBE = 2'b10;
        else if ((rtE != 0) && (rtE == WriteRegW) && RegWriteW)
            ForwardBE = 2'b01;
        else
            ForwardBE = 2'b00;
    end

    // ForwardAD/ForwardBD: branch resolves in EX using normal ALU forwarding.
    // These are kept for interface compatibility but not used by the datapath.
    assign ForwardAD = 1'b0;
    assign ForwardBD = 1'b0;

    // --- LOAD-USE STALL ---
    // Stall when ID instruction needs result of a load currently in EX
    wire lwstall;
    assign lwstall = ((rsD == WriteRegE) || (rtD == WriteRegE)) && MemtoRegE;

    assign StallF = lwstall;
    assign StallD = lwstall;
    assign FlushE = lwstall;

endmodule
