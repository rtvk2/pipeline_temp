module mux2_1 (input i0, i1, sel, output out);
    wire not_sel,a0,a1;
    not g1(not_sel,sel);
    and g2(a0,i0,not_sel);
    and g3(a1,i1,sel);
    or  g4(out,a0,a1);
endmodule

module mux2_64 (input [63:0] i0, i1,input sel,output [63:0] out);
    genvar k;
    generate
        for(k=0; k<64; k=k+1) 
          begin : mux_array
            mux2_1 m (.i0(i0[k]), .i1(i1[k]), .sel(sel), .out(out[k]));
        end
    endgenerate
endmodule