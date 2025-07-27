module control_unit (
    input clk, reset, start,
    output reg ready,
    output reg [15:0] mem_address,
    output reg mem_write_enable, mem_read_enable,
    output reg [15:0] mem_data_in,
    input [15:0] mem_data_out,
    output reg reg_write_enable,
    output reg [1:0] reg_read_addr1, reg_read_addr2, reg_write_addr,
    output reg [15:0] reg_write_data,
    input [15:0] reg_read_data1, reg_read_data2,
    output reg alu_start,
    output reg [2:0] alu_opcode,
    output reg [15:0] alu_a, alu_b,
    input [16:0] alu_result_low, alu_result_high,
    input alu_done
);

    typedef enum logic [2:0] {
        IDLE = 3'b000,
        FETCH = 3'b001,
        DECODE = 3'b010,
        EXECUTE = 3'b011,
        MEMORY = 3'b100,
        WRITEBACK = 3'b101,
        COMPLETE = 3'b110
    } state_t;

    state_t state;

    reg [15:0] PC;

    reg [15:0] instr;
    reg [2:0] opcode;
    reg [1:0] rd, rs1, rs2, base;
    reg [8:0] address_imm;

    reg [15:0] effective_addr;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            PC <= 16'b0;
            state <= IDLE;
            ready <= 1'b0;
            mem_read_enable <= 1'b0;
            mem_write_enable <= 1'b0;
            reg_write_enable <= 1'b0;
            alu_start <= 1'b0;
        end else begin
            case (state)

                IDLE: begin
                    ready <= 0;
                    if (start) state <= FETCH;
                end

                FETCH: begin
                    mem_address <= PC;
                    mem_read_enable <= 1'b1;
                    state <= DECODE;
                end

                DECODE: begin
                    mem_read_enable <= 1'b0;
                    instr <= mem_data_out;

                    opcode <= mem_data_out[15:13];

                    if (mem_data_out[15:13] == 3'b100 || mem_data_out[15:13] == 3'b101) begin
                        rd <= mem_data_out[12:11];
                        base <= mem_data_out[10:9];
                        address_imm <= mem_data_out[8:0];
                        state <= EXECUTE;
                    end else begin
                        rd <= mem_data_out[12:11];
                        rs1 <= mem_data_out[10:9];
                        rs2 <= mem_data_out[8:7];
                        state <= EXECUTE;
                    end
                end

                EXECUTE: begin
                    if (opcode == 3'b100 || opcode == 3'b101) begin
                        reg_read_addr1 <= base;
                        effective_addr <= reg_read_data1 + {{7{address_imm[8]}}, address_imm};
                        state <= MEMORY;
                    end else begin
                        reg_read_addr1 <= rs1;
                        reg_read_addr2 <= rs2;
                        alu_a <= reg_read_data1;
                        alu_b <= reg_read_data2;
                        alu_opcode <= opcode;
                        alu_start <= 1'b1;
                        if (alu_done) begin
                            alu_start <= 1'b0;
                            reg_write_addr <= rd;
                            reg_write_data <= alu_result_low[15:0];
                            reg_write_enable <= 1'b1;
                            state <= WRITEBACK;
                        end
                    end
                end

                MEMORY: begin
                    if (opcode == 3'b100) begin
                        mem_address <= effective_addr;
                        mem_read_enable <= 1'b1;
                        state <= WRITEBACK;
                    end else begin
                        mem_address <= effective_addr;
                        mem_write_enable <= 1'b1;
                        mem_data_in <= reg_read_data1;
                        state <= COMPLETE;
                    end
                end

                WRITEBACK: begin
                    mem_read_enable <= 1'b0;
                    if (opcode == 3'b100) begin
                        reg_write_enable <= 1'b1;
                        reg_write_addr <= rd;
                        reg_write_data <= mem_data_out;
                    end
                    state <= COMPLETE;
                end

                COMPLETE: begin
                    reg_write_enable <= 1'b0;
                    mem_write_enable <= 1'b0;
                    alu_start <= 1'b0;
                    PC <= PC + 1;
                    ready <= 1'b1;
                    state <= FETCH;
                end

            endcase
        end
    end
endmodule
