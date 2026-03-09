`timescale 1ns/1ps
`define IMEM_SIZE 4096 
module instruction_mem(
    input [63:0] addr,
    output reg [31:0] instr
);
    integer i;
    reg [7:0] mem [0:`IMEM_SIZE-1];
    initial begin
        for (i = 0; i < `IMEM_SIZE; i = i + 1) mem[i] = 8'h00;
        $readmemh("instructions.txt", mem);
    end
    always @(*) begin
        // Big-Endian Implementation:
        instr[31:24] = mem[addr];
        instr[23:16] = mem[addr+1];
        instr[15:8]  = mem[addr+2];
        instr[7:0]   = mem[addr+3];
    end
endmodule