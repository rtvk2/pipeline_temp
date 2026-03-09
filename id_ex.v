module id_ex(input clk,reset,flush,mem_to_reg,reg_write_en,mem_read,mem_write,branch,alu_src,
input[3:0]alu_control,input[63:0]ID_EX_pc_in,data_in_1,data_in_2,imm_gen,
input[4:0]ID_EX_rd_in,ID_EX_rs1_in,ID_EX_rs2_in,
output mem_to_reg_out,reg_write_en_out,mem_read_out,mem_write_out,branch_out,alu_src_out,
output[3:0]alu_control_out,output[63:0]ID_EX_MEM_pc_out,data_out_1,data_out_2,imm_gen_out,
output[4:0]ID_EX_MEM_rd_out,ID_EX_MEM_rs1_out,ID_EX_MEM_rs2_out);
reg mem_to_reg_out_reg;
reg reg_write_en_out_reg;
reg mem_read_out_reg;
reg mem_write_out_reg;
reg branch_out_reg;
reg alu_src_out_reg;
reg[3:0]alu_control_out_reg;
reg[63:0]ID_EX_MEM_pc_out_reg,data_out_1_reg,data_out_2_reg,imm_gen_out_reg;
reg[4:0]ID_EX_MEM_rd_out_reg,ID_EX_MEM_rs1_out_reg,ID_EX_MEM_rs2_out_reg;
always@(posedge clk or posedge reset)begin
    if (reset)begin
        mem_to_reg_out_reg<=1'b0;
        reg_write_en_out_reg<=1'b0;
        mem_read_out_reg<=1'b0;
        mem_write_out_reg<=1'b0;
        branch_out_reg<=1'b0;
        alu_src_out_reg<=1'b0;
        alu_control_out_reg<=4'b0;
        ID_EX_MEM_pc_out_reg<=64'b0;
        data_out_1_reg<=64'b0;
        data_out_2_reg<=64'b0;
        imm_gen_out_reg<=64'b0;
        ID_EX_MEM_rd_out_reg<=5'b0;
        ID_EX_MEM_rs1_out_reg<=5'b0;
        ID_EX_MEM_rs2_out_reg<=5'b0;
    end
    else if(flush)begin
        mem_to_reg_out_reg<=1'b0;
        reg_write_en_out_reg<=1'b0;
        mem_read_out_reg<=1'b0;
        mem_write_out_reg<=1'b0;
        branch_out_reg<=1'b0;
        alu_src_out_reg<=1'b0;
        alu_control_out_reg<=4'b0;
        ID_EX_MEM_pc_out_reg<=64'b0;
        data_out_1_reg<=64'b0;
        data_out_2_reg<=64'b0;
        imm_gen_out_reg<=64'b0;
        ID_EX_MEM_rd_out_reg<=5'b0;
        ID_EX_MEM_rs1_out_reg<=5'b0;
        ID_EX_MEM_rs2_out_reg<=5'b0;
    end
    else begin
        mem_to_reg_out_reg<=mem_to_reg;
        reg_write_en_out_reg<=reg_write_en;
        mem_read_out_reg<=mem_read;
        mem_write_out_reg<=mem_write;
        branch_out_reg<=branch;
        alu_src_out_reg<=alu_src;
        alu_control_out_reg<=alu_control;
        ID_EX_MEM_pc_out_reg<=ID_EX_pc_in;
        data_out_1_reg<=data_in_1;
        data_out_2_reg<=data_in_2;
        imm_gen_out_reg<=imm_gen;
        ID_EX_MEM_rd_out_reg<=ID_EX_rd_in;
        ID_EX_MEM_rs1_out_reg<=ID_EX_rs1_in;
        ID_EX_MEM_rs2_out_reg<=ID_EX_rs2_in;
    end
end
assign mem_to_reg_out=mem_to_reg_out_reg;
assign reg_write_en_out=reg_write_en_out_reg;
assign mem_read_out=mem_read_out_reg;
assign mem_write_out=mem_write_out_reg;
assign branch_out=branch_out_reg;
assign alu_src_out=alu_src_out_reg;
assign alu_control_out=alu_control_out_reg;
assign ID_EX_MEM_pc_out=ID_EX_MEM_pc_out_reg;
assign data_out_1=data_out_1_reg;
assign data_out_2=data_out_2_reg;
assign imm_gen_out=imm_gen_out_reg;
assign ID_EX_MEM_rd_out=ID_EX_MEM_rd_out_reg;
assign ID_EX_MEM_rs1_out=ID_EX_MEM_rs1_out_reg;
assign ID_EX_MEM_rs2_out=ID_EX_MEM_rs2_out_reg;
endmodule