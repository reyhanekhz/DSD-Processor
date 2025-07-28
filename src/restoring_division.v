module restoring_division (
    input clk, reset, start,
    input [15:0] dividend, divisor,
    output reg [15:0] remainder, quotient,
    output reg done
);

    reg [4:0] count;
    reg [15:0] temp_dividend, temp_divisor;
    reg [16:0] temp_remainder;   
    reg [15:0] temp_quotient;

    parameter IDLE = 2'b00, INIT = 2'b01, DIVIDE = 2'b10, FINISH = 2'b11;

    reg [1:0] state;
    reg [16:0] sub_result;   


    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 5'b0;
            state <= IDLE;
            done <= 1'b0;
            remainder <= 16'b0;
            quotient <= 16'b0;
        end 

        else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= INIT;
                        done <= 1'b0;
                    end
                end

                INIT: begin
                    temp_dividend <= dividend;
                    temp_divisor  <= divisor;
                    temp_remainder <= 17'b0;    
                    temp_quotient <= 16'b0;     
                    count <= 5'b0;
                    state <= DIVIDE;
                end

                DIVIDE: begin
                    if (count < 16) begin
                        temp_dividend  <= temp_dividend << 1;

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
                    quotient  <= temp_quotient;
                    remainder <= temp_remainder[15:0];
                    done <= 1'b1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
