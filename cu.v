`timescale 1ns / 1ps
module cu(
    input [6:0] opcode,
    output reg Branch,
    output reg MemRead,
    output reg MemtoReg,
    output reg [1:0] ALUOp,
    output reg MemWrite,
    output reg ALUSrc,
    output reg RegWrite);

    always @(*) begin
        //default values to 0 to prevent latches
        Branch   = 1'b0;
        MemRead  = 1'b0;
        MemtoReg = 1'b0;
        ALUOp    = 2'b00;
        MemWrite = 1'b0;
        ALUSrc   = 1'b0;
        RegWrite = 1'b0;

        case(opcode)
            //if not mentioned, all control signals remain 0
            //r-type: add, sub, and, or
            7'b0110011: begin
                RegWrite = 1'b1; //write to register file
                ALUOp    = 2'b10; //check funct3 and funct7 to add/sub/and/or
            end
            //i-type: add and load
            7'b0010011: begin
                ALUSrc   = 1'b1; // forces alu to take immediate value (64 bit) instead of register
                RegWrite = 1'b1;    
                ALUOp    = 2'b00; //check funct3 to add/or/and (default to add)
            end
            //load: ld
            7'b0000011: begin
                ALUSrc   = 1'b1; 
                MemtoReg = 1'b1; // forces write back to take data from memory instead of alu result
                RegWrite = 1'b1;
                MemRead  = 1'b1; // read from memory
                ALUOp    = 2'b00;
            end
            //store: sd
            7'b0100011: begin
                ALUSrc   = 1'b1;
                MemWrite = 1'b1;
                ALUOp    = 2'b00;
            end
            //branch: beq
            7'b1100011: begin
                Branch = 1'b1; //determine if pc should be updated with branch target address or pc + 4
                ALUOp  = 2'b01; //check funct3 to beq/bne
            end
        endcase
    end
endmodule