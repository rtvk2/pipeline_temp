module adder_64 (input [63:0]a,input [63:0]b,output [63:0]sum,output carry,output overflow);
    wire [64:0] c;
    assign c[0] = 1'b0;

    genvar i;
    generate
        for(i=0;i<64;i=i+1) 
          begin : ADD_LOOP
            full_adder fa (.a(a[i]),.b(b[i]),.cin(c[i]),.sum(sum[i]),.cout(c[i+1]));
        end
    endgenerate

    assign carry=c[64];
    xor x_ovf (overflow, c[63], c[64]);

endmodule