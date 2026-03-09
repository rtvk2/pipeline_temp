module srl_64 (input [63:0] din,input [5:0] val,output [63:0] dout);
  
    wire [63:0] zero = 64'b0;
    wire [63:0] s1, s2, s4, s8, s16;

    mux2_64 m32 (.i0(din), .i1({zero[31:0], din[63:32]}), .sel(val[5]), .out(s1));
    mux2_64 m16 (.i0(s1), .i1({zero[15:0], s1[63:16]}), .sel(val[4]), .out(s2));
    mux2_64 m8  (.i0(s2), .i1({zero[7:0], s2[63:8]}), .sel(val[3]), .out(s4));
    mux2_64 m4  (.i0(s4), .i1({zero[3:0], s4[63:4]}), .sel(val[2]), .out(s8));
    mux2_64 m2  (.i0(s8), .i1({zero[1:0], s8[63:2]}), .sel(val[1]), .out(s16));
    mux2_64 m1  (.i0(s16), .i1({zero[0], s16[63:1]}), .sel(val[0]), .out(dout));
endmodule