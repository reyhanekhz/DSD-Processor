`timescale 1ns/1ps

module cpu_tb();
    // -- Control signals --
    reg clk, reset, start;
    wire ready;

    // -- Memory wiring --
    wire [15:0] mem_address, mem_data_in, mem_data_out;
    wire mem_write_enable, mem_read_enable;

    // -- Register File wiring --
    wire [15:0] reg_write_data, reg_read_data1, reg_read_data2;
    wire [1:0] reg_read_addr1, reg_read_addr2, reg_write_addr;
    wire reg_write_enable;

    // -- ALU wiring --
    wire alu_start, alu_done;
    wire [2:0] alu_opcode;
    wire [15:0] alu_a, alu_b;
    wire [15:0] alu_result_low, alu_result_high;


    // -- Module instantiations --

    control_unit CU(
        // -- Control signal --
        .clk(clk), .reset(reset), .start(start), .ready(ready),

        // -- Memory wiring --
        .mem_address(mem_address), .mem_write_enable(mem_write_enable), 
        .mem_read_enable(mem_read_enable), .mem_data_in(mem_data_in), .mem_data_out(mem_data_out),

        // -- Register file wiring --
        .reg_write_enable(reg_write_enable), .reg_read_addr1(reg_read_addr1), .reg_read_addr2(reg_read_addr2),
        .reg_write_addr(reg_write_addr), .reg_write_data(reg_write_data),
        .reg_read_data1(reg_read_data1), .reg_read_data2(reg_read_data2),

        // -- ALU wiring --
        .alu_start(alu_start), .alu_opcode(alu_opcode), .alu_a(alu_a), .alu_b(alu_b),
        .alu_result_low(alu_result_low), .alu_result_high(alu_result_high), .alu_done(alu_done)
    );

    alu ALU(
        .a(alu_a), .b(alu_b), .opcode(alu_opcode), .clk(clk), .reset(reset), .start(alu_start),
        .result_low(alu_result_low), .result_high(alu_result_high), .done(alu_done)
    );

    register_file RF(
        .clk(clk), .reset(reset), .write_enable(reg_write_enable),
        .read_reg_index1(reg_read_addr1), .read_reg_index2(reg_read_addr2),
        .write_reg_index(reg_write_addr), .write_data(reg_write_data),
        .reg_read_1(reg_read_data1), .reg_read_2(reg_read_data2)
    );

    main_memory MEM(
        .clk(clk), .reset(reset),
        .address(mem_address), .data_in(mem_data_in),
        .write_enable(mem_write_enable), .read_enable(mem_read_enable),
        .data_out(mem_data_out)
    );

    // -- Generating clock pulse every 5ns --
    always #5 clk = ~clk;

    initial begin
        // -- Generate VCD file output --
        $dumpfile("cpu_waveform.vcd");
        $dumpvars(0, cpu_tb);

        // -- Reset everything --
        clk = 0; reset = 1; start = 0;
        #10 reset = 0;

        // -- Load test instructions in memory --

        // ADD x1 = x2 + x3
        MEM.memory[0] = 16'b000_01_10_11_0000000;
        // SUB x1 = x2 - x3
        MEM.memory[1] = 16'b001_01_10_11_0000000;
        // MUL x1 = x2 * x3
        MEM.memory[2] = 16'b010_01_10_11_0000000;
        // DIV x1 = x2 / x3
        MEM.memory[3] = 16'b011_01_10_11_0000000;
        // STORE x1 -> M[x0 + 5]
        MEM.memory[4] = 16'b101_01_00_000000101;
        // LOAD x3 <- M[x0 + 5]
        MEM.memory[5] = 16'b100_11_00_000000101;


        RF.x2 = 16'd10;
        RF.x3 = 16'd3;
        MEM.memory[5] = 16'd0; 
        
        // === Start Execution ===
        start = 1; #10 start = 0;

        // === Wait and Check after each instruction ===
        // #50  $display("[ADD] x1 = %d (expected 13)", RF.x1);
        // #100  $display("[SUB] x1 = %d (expected 7)", RF.x1);
        #100  $display("[MUL] x1 = %d (expected 30)", RF.x1);
        // #50  $display("[DIV] x1 = %d (expected 3)", RF.x1);
        // #50  $display("[STORE] Memory[5] = %d (expected 3 from last x1)", MEM.memory[5]);
        // #50  $display("[LOAD] x3 = %d (expected 3)", RF.x3);

        // #50  $display("=== TEST COMPLETE ===");
        $finish;
    end

endmodule
