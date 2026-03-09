module data_mem(input clk, reset, MemRead, MemWrite, input [63:0] address, input [63:0] write_data, output [63:0] read_data);

    reg [7:0] memory [1023:0];
    wire [9:0] addr = address[9:0];

    assign read_data = (reset) ? 64'b0 :
                       (MemRead) ? {memory[addr],   memory[addr+1], memory[addr+2], memory[addr+3],
                                    memory[addr+4], memory[addr+5], memory[addr+6], memory[addr+7]} : 64'b0;

    always @(posedge clk) begin
        if (MemWrite) begin
            memory[addr]   <= write_data[63:56];
            memory[addr+1] <= write_data[55:48];
            memory[addr+2] <= write_data[47:40];
            memory[addr+3] <= write_data[39:32];
            memory[addr+4] <= write_data[31:24];
            memory[addr+5] <= write_data[23:16];
            memory[addr+6] <= write_data[15:8];
            memory[addr+7] <= write_data[7:0];
        end
    end

    integer i;
    initial begin
        for (i = 0; i < 1024; i = i + 1) memory[i] = 8'h00;
    end

endmodule
