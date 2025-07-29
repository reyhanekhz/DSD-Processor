module shift_and_add (
    input clk, reset, start,
    input signed [7:0] x, y,
    output reg signed [15:0] product,
    output reg done
);
    // 16 bit version of x
    reg signed [15:0] x_extended;
    reg [7:0] y_reg;
    reg [3:0] count;

    parameter IDLE = 2'b00, INIT = 2'b01, BUSY = 2'b10, FINISH = 2'b11;
    reg [1:0] state;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            product <= 16'b0;
            x_extended <= 16'b0;
            y_reg <= 8'b0;
            count <= 0;
            done <= 0;
            state <= IDLE;
        end 
        
        else begin
            case (state)
                IDLE: if (start) begin
                    state <= INIT;
                    done <= 1'b0;
                end

                INIT: begin
                    product <= 16'b0;
                    x_extended <= {{8{x[7]}}, x}; // Sign extend 
                    y_reg <= y[7] ? -y : y;       // Absolute value of y 
                    count <= 0;
                    state <= BUSY;
                end

                BUSY: begin
                    // Wait till 8 cycles
                    if (count < 8) begin
                        // Add if y's bit is 1
                        if (y_reg[0]) 
                            product <= product + x_extended;
                        // Shift y to right, x to left
                        y_reg <= y_reg >> 1;
                        x_extended <= x_extended << 1;

                        count <= count + 1;
                    end 
                    
                    
                    else state <= FINISH;
                end

                FINISH: begin
                    // restore sign of y
                    if (y[7]) product <= -product;
                    done <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
