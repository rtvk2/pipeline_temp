module if_id(input clk,reset,flush,IF_ID_write,input[63:0]IF_ID_pc_in,input[31:0]IF_ID_instr_in,output[63:0]IF_ID_pc_out,output[31:0]IF_ID_instr_out);
reg[63:0]IF_ID_pc_out_reg;
reg[31:0]IF_ID_instr_out_reg;
always@(posedge clk or posedge reset)begin
    if(reset)begin
        IF_ID_pc_out_reg<=64'b0;
        IF_ID_instr_out_reg<=32'b0;
    end
    else if(flush)begin
        IF_ID_pc_out_reg<=64'b0;
        IF_ID_instr_out_reg<=32'b0;
    end
    else if(IF_ID_write)begin
        IF_ID_pc_out_reg<=IF_ID_pc_in;
        IF_ID_instr_out_reg<=IF_ID_instr_in;
    end
end
assign IF_ID_pc_out=IF_ID_pc_out_reg;
assign IF_ID_instr_out=IF_ID_instr_out_reg;
endmodule