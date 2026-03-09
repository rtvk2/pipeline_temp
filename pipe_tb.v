`timescale 1ns / 1ps
`include "pipe_processor.v"

module pipe_tb;
    reg clk;
    reg reset;

    integer cycle_count;

    pipe_processor uut (
        .clk(clk),
        .reset(reset)
    );

    // Clock generation
    initial begin
        clk = 0;
        cycle_count = 0;
        forever begin
            #5 clk = ~clk;
            if (clk && !reset) cycle_count = cycle_count + 1;
        end
    end

    // Halt condition checking
    always @(posedge clk) begin
        if (!reset) begin
            // We check if the instruction fetched is exactly 32'b0
            if (uut.DU_inst.InstrF === 32'b0 || uut.DU_inst.InstrF === 32'hxxxxxxxx) begin
                $display("Halt condition met: Fetched an all 0 instruction.");
                $display("Total Clock Cycles: %0d", cycle_count);
                
                // Writing register file manually if needed, or if reg_file handles it, wait minimal
                $display("Terminating simulation. Dummy instructions discarded.");
                $finish;
            end
        end
    end

    initial begin
        $dumpfile("pipe_processor.vcd");
        $dumpvars(0, pipe_tb);

        reset = 1;
        #15 reset = 0;
        
        // Failsafe timeout
        #1000;
        $display("Timeout reached.");
        $finish;
    end
endmodule
