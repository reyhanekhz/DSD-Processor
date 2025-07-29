module cpu (
    input clk, reset, start,
    output ready
);

    // Memory wiring
    wire [9:0] mem_address;
    wire signed [15:0] mem_data_in, mem_data_out;
    wire mem_write_enable, mem_read_enable;

    // Register File wiring
    wire signed [15:0] reg_write_data, reg_read_data1, reg_read_data2;
    wire [1:0] reg_read_addr1, reg_read_addr2, reg_write_addr;
    wire reg_write_enable;

    // ALU wiring
    wire alu_start, alu_done;
    wire [2:0] alu_opcode;
    wire signed [15:0] alu_a, alu_b;
    wire signed [15:0] alu_result_low, alu_result_high;


    // Module instantiations

    control_unit CU(
        // Control signals
        .clk(clk), .reset(reset), .start(start), .ready(ready),

        // Memory wiring
        .mem_address(mem_address), .mem_write_enable(mem_write_enable), 
        .mem_read_enable(mem_read_enable), .mem_data_in(mem_data_in), .mem_data_out(mem_data_out),

        // Register file wiring
        .reg_write_enable(reg_write_enable), .reg_read_addr1(reg_read_addr1), .reg_read_addr2(reg_read_addr2),
        .reg_write_addr(reg_write_addr), .reg_write_data(reg_write_data),
        .reg_read_data1(reg_read_data1), .reg_read_data2(reg_read_data2),

        // ALU wiring
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

endmodule