`timescale 1ns/1ps

module cpu_tb();
    // Control signals
    reg clk, reset, start;
    wire ready;

    // Instantiate CPU module
    cpu CPU (
        .clk(clk), .reset(reset), .start(start), .ready(ready)
    );

    // Generating clock pulse every 5ns
    always #5 clk = ~clk;

    initial begin
        // Generate VCD file output
        $dumpfile("cpu_waveform.vcd");
        $dumpvars(0, CPU);
        $dumpvars(0, cpu_tb);

        // Reset everything
        clk = 0; reset = 1; start = 0;
        #10 reset = 0;

        // Load test instructions in memory

        // // ADD x1 = x2 + x3
        CPU.MEM.memory[0] = 16'b000_01_10_11_0000000;
        // SUB x1 = x2 - x3
        CPU.MEM.memory[1] = 16'b001_01_10_11_0000000;
        // MUL x1 = x2 * x3
        CPU.MEM.memory[2] = 16'b010_01_10_11_0000000;
        // // DIV x1 = x2 / x3
        CPU.MEM.memory[0] = 16'b011_01_10_11_0000000;
        // STORE x1 -> M[x0 + 5]
        CPU.MEM.memory[1] = 16'b101_01_00_000000101;
        // LOAD x3 <- M[x0 + 5]
        CPU.MEM.memory[2] = 16'b100_11_00_000000101;


        CPU.RF.x2 = 16'd10;
        CPU.RF.x3 = 16'd4;
        CPU.MEM.memory[5] = 16'd0; 
        
        // === Start Execution ===
        start = 1; #10 start = 0;
    end

    always @(posedge ready) begin
        $display("x1 = %d, x2 = %d, x3 = %d", 
                $signed(CPU.RF.x1), $signed(CPU.RF.x2), $signed(CPU.RF.x3));
        $display("Memory[5] = %d (signed)", $signed(CPU.MEM.memory[5]));
    end


    initial begin
        #1000 $display("=== TEST COMPLETE ===");
        $finish;
    end

endmodule
