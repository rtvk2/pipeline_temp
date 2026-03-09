`timescale 1ns/1ps

module hazard_unit(
    input [4:0] rsD, rtD, rsE, rtE, WriteRegE, WriteRegM, WriteRegW,
    input RegWriteE, RegWriteM, RegWriteW, MemtoRegE, MemtoRegM, BranchD,
    output reg [1:0] ForwardAE, ForwardBE,
    output ForwardAD, ForwardBD,
    output StallF, StallD, FlushE
);

    // --- EXECUTE STAGE FORWARDING ---
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

    // --- DECODE STAGE FORWARDING (For Branches) ---
    assign ForwardAD = (rsD != 0) && (rsD == WriteRegM) && RegWriteM;
    assign ForwardBD = (rtD != 0) && (rtD == WriteRegM) && RegWriteM;

    // --- STALL LOGIC ---
    wire lwstall;

    // Load-Use Stall: stall when a load in EX is needed by next instruction in ID
    assign lwstall = ((rsD == WriteRegE) || (rtD == WriteRegE)) && MemtoRegE;

    // Pipeline Control
    assign StallF = lwstall;
    assign StallD = lwstall;
    assign FlushE = lwstall;

endmodule