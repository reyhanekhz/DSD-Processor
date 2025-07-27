module restoring_division (
    input clk, reset, start,
    input [15:0] dividend, divisor,
    output reg [15:0] remainder, quotient,
    output reg done
);


    reg [4:0] count;
    reg [15:0] temp_dividend, temp_divisor, temp_remainder, temp_quotient;

    parameter IDLE = 2'b00, INIT = 2'b01, DEVIDE = 2'b10, FINISH = 2'b11;

    reg [1:0] state;


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
                    temp_divisor <= divisor;
                    count <= 5'b0;
                    temp_remainder <= 16'b0;
                    state <= DEVIDE;
                end


                DEVIDE:begin
                    if (count < 5'd16) begin
                        temp_remainder <= {temp_remainder[14:0], temp_remainder[15]};
                        temp_dividend <= (temp_dividend << 1);

                        temp_remainder <= (temp_remainder - temp_divisor);

                        if (temp_remainder[15]) begin  
                        temp_remainder <= temp_remainder + temp_divisor;
                        quotient <= {quotient[14:0], 1'b0};
                        end 

                        else begin
                            quotient <= {quotient[14:0], 1'b1};
                        end
                        
                        count <= count + 1;
                    end

                    else begin
                        state <= FINISH;
                    end
                end

                FINISH: begin
                    remainder <= temp_remainder;
                    done <= 1'b1;
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule