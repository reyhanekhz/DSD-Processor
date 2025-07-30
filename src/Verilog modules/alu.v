module alu (
    input  signed [15:0] a, b,         
    input  [2:0] opcode,
    input  clk, reset, start,   
    output reg signed [15:0] result_low, 
    output reg signed [15:0] result_high,
    output reg done
);

    wire signed [15:0] CSA_add_result, CSA_sub_result;
    wire cout_add, cout_sub;

    // Adder module with carry-in 0
    carry_select_adder adder (
        .a(a), .b(b), .cin(1'b0), .cout(cout_add), .sum(CSA_add_result)
    );

    // Subtractor module with carry-in 1
    carry_select_adder subtractor (
        .a(a), .b(~b), .cin(1'b1), .cout(cout_sub), .sum(CSA_sub_result)
    );

    wire signed [31:0] karatsuba_result;   
    wire karatsuba_done;
    reg  karatsuba_start;

    karatsuba mult_unit (
        .clk(clk), .reset(reset), .start(karatsuba_start),
        .x(a), .y(b),                        
        .product(karatsuba_result), 
        .done(karatsuba_done)
    );

    wire signed [15:0] div_quotient, div_remainder;
    wire div_done;
    reg  div_start;

    restoring_division div_unit (
        .clk(clk), .reset(reset), .start(div_start),
        .dividend(a), .divisor(b),
        .remainder(div_remainder), .quotient(div_quotient),
        .done(div_done)
    );

    // ALU states
    parameter IDLE = 2'b00, BUSY_MUL = 2'b01, BUSY_DIV = 2'b10, FINISH = 2'b11;
    reg [1:0] state;

    always @(posedge clk or posedge reset) begin
        // reset all in the beginning 
        if (reset) begin
            result_low      <= 16'b0;
            result_high     <= 16'b0;
            done            <= 1'b0;
            karatsuba_start <= 1'b0;
            div_start       <= 1'b0;
            state           <= IDLE;
        end 
        
        else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    karatsuba_start <= 0;
                    div_start <= 0;

                    // Wait for the start of ALU's part
                    if (start) begin
                        case (opcode)
                            3'b000: begin // ADD
                                result_low <= CSA_add_result;
                                result_high <= {15'b0, cout_add};
                                done <= 1'b1;
                            end

                            3'b001: begin // SUB
                                result_low <= CSA_sub_result;
                                result_high <= {16{CSA_sub_result[15]}}; 
                                done <= 1'b1;
                            end

                            3'b010: begin // MULTIPLY: start the process
                                karatsuba_start <= 1'b1;
                                state <= BUSY_MUL;
                            end

                            3'b011: begin // DIVIDE: start the process
                                if (b != 16'b0) begin 
                                    div_start <= 1'b1;
                                    state <= BUSY_DIV;
                                end 
                                
                                // Division by Zero
                                else begin
                                    result_low  <= 16'b0;
                                    result_high <= 16'b0;
                                    done <= 1'b1;
                                end
                            end

                            default: begin
                                result_low <= 16'b0;
                                result_high <= 16'b0;
                                done <= 1'b1;
                            end
                        endcase
                    end
                end

                BUSY_MUL: begin
                    karatsuba_start <= 1'b0;
                    // Wait till multiplication is done
                    if (karatsuba_done) begin
                        result_low  <= karatsuba_result[15:0];
                        result_high <= karatsuba_result[31:16];
                        done <= 1'b1;
                        state <= FINISH;
                    end
                end

                BUSY_DIV: begin
                    div_start <= 1'b0;
                    // Wait till division is doen
                    if (div_done) begin
                        result_low  <= div_quotient;
                        result_high <= div_remainder;
                        done <= 1'b1;
                        state <= FINISH;
                    end
                end

                FINISH: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
