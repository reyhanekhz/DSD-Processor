module restoring_division (
    input clk, reset, start,
    input signed [15:0] dividend, divisor,
    output reg signed [15:0] remainder, quotient,
    output reg done
);

    reg [4:0] count;
    reg [15:0] temp_dividend, temp_divisor;
    reg [16:0] temp_remainder;
    reg [15:0] temp_quotient;

    reg dividend_sign, divisor_sign, quotient_sign;

    parameter IDLE = 2'b00, INIT = 2'b01, DIVIDE = 2'b10, FINISH = 2'b11;
    reg [1:0] state;
    reg [16:0] sub_result;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 0;
            state <= IDLE;
            done <= 0;
            remainder <= 0;
            quotient <= 0;
        end 


        else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= INIT;
                        done <= 0;
                    end
                end

                INIT: begin
                    // Store signs
                    dividend_sign <= dividend[15];
                    divisor_sign  <= divisor[15];
                    quotient_sign <= dividend[15] ^ divisor[15];

                    // Use absolute values
                    temp_dividend <= dividend[15] ? (~dividend + 1) : dividend;
                    temp_divisor  <= divisor[15]  ? (~divisor + 1)  : divisor;

                    // 17 bits for keeping sign when shifting
                    temp_remainder <= 17'b0;
                    temp_quotient  <= 16'b0;
                    count <= 0;
                    state <= DIVIDE;
                end

                DIVIDE: begin
                    // 16 cycles
                    if (count < 16) begin
                        temp_dividend  <= temp_dividend << 1;
                        // Store result to check
                        sub_result = {temp_remainder[15:0], temp_dividend[15]} - temp_divisor;

                        if (sub_result[16]) begin
                            temp_remainder <= {temp_remainder[15:0], temp_dividend[15]};
                            temp_quotient  <= {temp_quotient[14:0], 1'b0};
                        end 
                        else begin
                            temp_remainder <= sub_result;
                            temp_quotient  <= {temp_quotient[14:0], 1'b1};
                        end

                        count <= count + 1;
                    end
                    else begin
                        state <= FINISH;
                    end
                end

                FINISH: begin
                    // restore signs
                    quotient  <= quotient_sign ? (~temp_quotient + 1) : temp_quotient;
                    remainder <= dividend_sign ? (~temp_remainder[15:0] + 1) : temp_remainder[15:0];
                    done <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
