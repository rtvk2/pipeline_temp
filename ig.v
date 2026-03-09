`timescale 1ns / 1ps
module ig(
    input [31:0] instr,
    output reg [63:0] imm_data);

    wire [6:0] opcode = instr[6:0];
    always @(*) begin
        case(opcode)
            //i-type: addi and load
            // addi (0010011), ld (0000011)
            7'b0010011, 7'b0000011: begin
                imm_data = { {52{instr[31]}}, instr[31:20] }; // for each case, we copy the signed msb (instr[31]) 52 times
                // then append 12 bit of immediate data to get 64 bit immediate value
            end
            //s-type: store
            // sd (0100011)
            7'b0100011: begin
                imm_data = { {52{instr[31]}}, instr[31:25], instr[11:7] }; //same for sign extension, but need to split immediate data from [31:25] and [11:7]
                // this is cuz rs2 is in 24:20 and 12 bit offset is needed
            end
            //b-type: branch
            // beq (1100011)
            7'b1100011: begin
                imm_data = { {52{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0 }; //again same sign extension, but need to split immediate data from [31], [7], [30:25], and [11:8]
                // this is cuz rs2 is in 24:20 and 13 bit offset is needed (12 bits + 1 bit for half-word alignment)
            end
            //r-type and default: no immediate
            //set to 0 to prevent latches
            default: begin
                imm_data = 64'b0;
            end
        endcase
    end
endmodule
