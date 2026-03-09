module subtractor_64 (input [63:0] a,input [63:0] b,output [63:0] diff,output carry,output overflow);
  
   wire [63:0] b_comp;
   wire [64:0] c;
   genvar k;
   generate
        for(k=0; k<64; k=k+1) begin : inv_loop
          not n1(b_comp[k],b[k]);
        end
    endgenerate
    assign c[0] = 1'b1;

   genvar i;
   generate
      for (i = 0; i < 64; i = i + 1)
       begin : SUB_LOOP
         full_adder fa (.a(a[i]),.b(b_comp[i]),.cin(c[i]),.sum(diff[i]),.cout(c[i+1]));
      end
   endgenerate

   assign carry=c[64];
   xor x_ovf (overflow, c[63], c[64]);

endmodule