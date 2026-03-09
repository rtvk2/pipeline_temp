`timescale 1ns / 1ps
module alu_cu(
    input [1:0] ALUOp,   // 2bit opcode from cu
    input [2:0] funct3,   //r-type funct3
    input funct7_bit,     //funct7 that helps tell add and sub apart
    output reg [3:0] ALUControl // 4-bit opcode for alu
);

    always @(*) begin
        case(ALUOp)
            // 00: i-type (addi, lw & sw) 
            2'b00: ALUControl = 4'b0000; //(localparam for ADD_Oper)
            // 01: beq and bne
            2'b01: ALUControl = 4'b1000; //(localparam for SUB_Oper)
            // 10: r-type (add, sub, and & or)
            2'b10: begin
                case(funct3)
                    // funct3 is 3'b000 for add and sub so check funct7 bit 
                    3'b000: begin
                        if (funct7_bit == 1'b1) // if funct7 bit is 1, it's a sub instruction
                            ALUControl = 4'b1000; // sub
                        else
                            ALUControl = 4'b0000; // add
                    end
                    // funct3 is 3'b001 for sll- shift left logical
                    3'b001: ALUControl = 4'b0001; 
                    // funct3 is 3'b010 for slt-  set less than
                    3'b010: ALUControl = 4'b0010; 
                    // funct3 is 3'b011 for sltu- set less than unsigned
                    3'b011: ALUControl = 4'b0011; 
                    // funct3 is 3'b100 for xor
                    3'b100: ALUControl = 4'b0100; 
                    // funct3 is 3'b101 for srl and sra so check funct7 bit
                    3'b101: begin
                        if (funct7_bit == 1'b1)
                            ALUControl = 4'b1101; // sra
                        else
                            ALUControl = 4'b0101; // srl
                    end
                    // funct3 is 3'b110 for or 
                    3'b110: ALUControl = 4'b0110; //(localparam for OR_Oper)
                    // funct3 is 3'b111 for and 
                    3'b111: ALUControl = 4'b0111; //(localparam for AND_Oper)
                    default: ALUControl = 4'b0000; 
                endcase
            end
            default: ALUControl = 4'b0000; // default to add operation
        endcase
    end
endmodule