`timescale 1ns/1ps

module cpu_tb();
    reg clk, reset, start;
    wire ready;
    reg [4:0] count;

    // Instantiate CPU
    cpu CPU (
        .clk(clk), .reset(reset), .start(start), .ready(ready)
    );

    // Clock: 10ns period
    always #5 clk = ~clk;

    initial begin
        $dumpfile("cpu_waveform.vcd");
        $dumpvars(0, cpu_tb);

        count = 0;
        clk = 0; reset = 1; start = 0;
        #10 reset = 0;

        // Load Program into Instruction Memory
        // ADD x1 = x2 + x3
        CPU.MEM.memory[0] = 16'b000_01_10_11_0000000;
        // SUB x1 = x1 - x3
        CPU.MEM.memory[1] = 16'b001_01_01_11_0000000;
        // MUL x2 = x1 * x3
        CPU.MEM.memory[2] = 16'b010_10_01_11_0000000;
        // DIV x3 = x2 / x1
        CPU.MEM.memory[3] = 16'b011_11_10_01_0000000;
        // STORE x1 -> M[x0 + 10]
        CPU.MEM.memory[4] = 16'b101_01_00_000001010;
        // LOAD x3 <- M[x0 + 10]
        CPU.MEM.memory[5] = 16'b100_11_00_000001010;
        // ADD x1 = x3 + x2
        CPU.MEM.memory[6] = 16'b000_01_11_10_0000000;
        // STORE x2 -> M[x0 + 12]
        CPU.MEM.memory[7] = 16'b101_10_00_000001100;

        // Initialize Registers & Data Memory
        CPU.RF.x0 = 0;
        CPU.RF.x2 = 16'd7;       // positive
        CPU.RF.x3 = -16'd3;      // negative
        CPU.MEM.memory[10] = 16'd123;  // memory location for store/load
        CPU.MEM.memory[12] = 16'd0;

        // Start Execution
        start = 1; #10 start = 0;
    end

    // Monitor after each instruction
    always @(posedge ready) begin
        if (count < 8) begin
            $display("x1=%d, x2=%d, x3=%d, Mem[10]=%d, Mem[12]=%d",
                    CPU.RF.x1, CPU.RF.x2, CPU.RF.x3,
                    CPU.MEM.memory[10], CPU.MEM.memory[12]);
            count <= count + 1;
        end
    end

    initial begin
        #2000 $display("TEST COMPLETE");
        $finish;
    end

endmodule
