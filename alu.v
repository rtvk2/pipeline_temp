
`include "full_adder.v"
`include "mux.v"           
`include "64bit_adder.v"    
`include "64bit_subs.v"    
`include "64bit_and.v"     
`include "64bit_or.v"      
`include "64bit_xor.v"
`include "sll_64.v"
`include "srl_64.v"
`include "sra_64.v"
`include "slt_64.v"
`include "sltu_64.v"

module alu_64_bit (input [63:0] a,input [63:0] b,input [3:0] opcode,output reg [63:0] result,output reg cout,output reg carry_flag,output reg overflow_flag, output wire zero_flag);

    wire [63:0] w_sum, w_diff;
    wire [63:0] w_and, w_or, w_xor;
    wire [63:0] w_sll, w_srl, w_sra, w_slt, w_sltu;
    wire w_add_cout, w_add_ovf;
    wire w_sub_cout, w_sub_ovf;
    wire w_slt_cout, w_slt_ovf, w_slt_zero;
    wire w_sltu_cout, w_sltu_ovf, w_sltu_zero;
    wire w_sub_borrow;
 
    adder_64      add_unit (.a(a), .b(b), .sum(w_sum),  .carry(w_add_cout), .overflow(w_add_ovf));
  
    subtractor_64 sub_unit (.a(a), .b(b), .diff(w_diff), .carry(w_sub_cout), .overflow(w_sub_ovf));

    and_64 u_and (.a(a), .b(b), .y(w_and));
  
    or_64  u_or  (.a(a), .b(b), .y(w_or));
  
    xor_64 u_xor (.a(a), .b(b), .y(w_xor));

    sll_64 shift_l (.din(a), .val(b[5:0]), .dout(w_sll));
  
    srl_64 shift_r (.din(a), .val(b[5:0]), .dout(w_srl));
  
    sra_64 shift_a (.din(a), .val(b[5:0]), .dout(w_sra));

    slt_64  comp_slt  (.a(a), .b(b), .dout(w_slt),  .cout(w_slt_cout),  .overflow(w_slt_ovf),  .zero(w_slt_zero));
  
    sltu_64 comp_sltu (.a(a), .b(b), .dout(w_sltu), .cout(w_sltu_cout), .overflow(w_sltu_ovf), .zero(w_sltu_zero));

    
    not g_borrow(w_sub_borrow,w_sub_cout);
    
    always @(*) begin
        carry_flag = 1'b0;
        overflow_flag = 1'b0;
        cout = 1'b0;

        case (opcode)
            4'b0000: begin // ADD
                result = w_sum; 
                cout = w_add_cout; 
                carry_flag = w_add_cout; 
                overflow_flag = w_add_ovf; 
            end

            4'b1000: begin // SUB
                result = w_diff; 
                cout = w_sub_cout; 
                carry_flag = w_sub_borrow; 
                overflow_flag = w_sub_ovf; 
            end

            4'b0010: begin // SLT
                result = w_slt; 
            end

            4'b0011: begin // SLTU
                result = w_sltu; 
            end

            4'b0001: result = w_sll; // SLL
            4'b0101: result = w_srl; // SRL
            4'b1101: result = w_sra; // SRA
            4'b0111: result = w_and; // AND
            4'b0110: result = w_or;  // OR
            4'b0100: result = w_xor; // XOR
            
            default: result = 64'b0;
        endcase
    end
    assign zero_flag = (result == 64'b0);

endmodule
