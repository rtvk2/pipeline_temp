
module sra_64 (input [63:0] din,input [5:0] val,output [63:0] dout);
   
    wire sign = din[63];
    wire [31:0] f32 = {32{sign}};
    wire [15:0] f16 = {16{sign}};
    wire [7:0]  f8  = {8{sign}};
    wire [3:0]  f4  = {4{sign}};
    wire [1:0]  f2  = {2{sign}};
    wire f1  = sign;
    wire [63:0] s1, s2, s4, s8, s16;
  
    mux2_64 m32 (.i0(din), .i1({f32, din[63:32]}), .sel(val[5]), .out(s1));
    mux2_64 m16 (.i0(s1), .i1({f16, s1[63:16]}), .sel(val[4]), .out(s2));
    mux2_64 m8  (.i0(s2), .i1({f8, s2[63:8]}), .sel(val[3]), .out(s4));
    mux2_64 m4  (.i0(s4), .i1({f4, s4[63:4]}), .sel(val[2]), .out(s8));
    mux2_64 m2  (.i0(s8), .i1({f2, s8[63:2]}), .sel(val[1]), .out(s16));
    mux2_64 m1  (.i0(s16), .i1({f1, s16[63:1]}), .sel(val[0]), .out(dout));
endmodule