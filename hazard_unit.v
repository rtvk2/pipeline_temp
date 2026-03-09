`timescale 1ns/1ps

module hazard_unit(
    input [4:0] rsE, rtE,
    input [4:0] WriteRegM, WriteRegW,
    input       RegWriteM, RegWriteW,
    input [4:0] rsD, rtD,
    input [4:0] WriteRegE,
    input       MemtoRegE,
    input       PCSrcE,
    output reg [1:0] ForwardAE, ForwardBE,
    output StallF, StallD, FlushD, FlushE
);

    always @(*) begin
        if      ((rsE != 0) && (rsE == WriteRegM) && RegWriteM) ForwardAE = 2'b10;
        else if ((rsE != 0) && (rsE == WriteRegW) && RegWriteW) ForwardAE = 2'b01;
        else                                                     ForwardAE = 2'b00;
    end

    always @(*) begin
        if      ((rtE != 0) && (rtE == WriteRegM) && RegWriteM) ForwardBE = 2'b10;
        else if ((rtE != 0) && (rtE == WriteRegW) && RegWriteW) ForwardBE = 2'b01;
        else                                                     ForwardBE = 2'b00;
    end

    wire lwstall;
    assign lwstall = ((rsD == WriteRegE) || (rtD == WriteRegE)) && MemtoRegE;

    assign StallF = lwstall;
    assign StallD = lwstall;
    assign FlushD = PCSrcE;
    assign FlushE = lwstall | PCSrcE;

endmodule
