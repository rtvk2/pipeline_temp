`timescale 1ns / 1ps
module reg_file(
    input clk,
    input reset,
    input [4:0] read_reg1,
    input [4:0] read_reg2,
    input [4:0] write_reg,
    input [63:0] write_data,  
    input reg_write_en,
    output [63:0] read_data1, 
    output [63:0] read_data2  
);
    // Declare 32 registers, each 64-bit wide
    reg [63:0] registers [31:0];
    integer i;
    integer file;
    integer cycle_count;
    // Asynchronous read with WB->ID internal forwarding (same-cycle write bypass)
    assign read_data1 = (reg_write_en && write_reg != 0 && write_reg == read_reg1) ? write_data : registers[read_reg1];
    assign read_data2 = (reg_write_en && write_reg != 0 && write_reg == read_reg2) ? write_data : registers[read_reg2];
    // Synchronous write and cycle counting
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            cycle_count <= 0;
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 64'b0;
            end
        end else begin
            cycle_count <= cycle_count + 1;
            // Write to register (Hardwired x0 to always be 0)
            if (reg_write_en && write_reg != 5'b00000) begin
                registers[write_reg] <= write_data;
            end
        end
    end
    always @(posedge clk) begin
        file = $fopen("register_file.txt", "w");
        if (file) begin
            for (i = 0; i < 32; i = i + 1) begin
                $fdisplay(file, "%016x", registers[i]);
            end
            $fdisplay(file, "%0d", cycle_count+1); //Add the last 00000000 cycle count
            $fclose(file);
        end
    end

endmodule