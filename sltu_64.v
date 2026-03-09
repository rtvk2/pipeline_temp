module sltu_64 (input [63:0] a, b,output [63:0] dout,output cout, overflow, zero );
  
    wire [63:0] diff;
    wire w_cout, w_ovf;
    wire is_less;

    subtractor_64 sub (.a(a),.b(b),.diff(diff),.carry(w_cout),.overflow(w_ovf));
    not g1 (is_less, w_cout);
    assign dout = {63'b0, is_less};
    assign cout=w_cout;
    assign overflow=w_ovf;
    assign zero=(diff == 64'b0);

endmodule