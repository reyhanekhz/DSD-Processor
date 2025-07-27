module shift_and_add (
    input clk, reset, start,
    input [7:0] x, y,
    output reg [15:0] product,
    output reg done
);

    reg [15:0] x_extended;
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


        case (state)
            IDLE: begin
                if (start) begin
                    state <= INIT;
                    done <= 1'b0;
                end                
            end


            INIT: begin
                product <= 16'b0;
                x_extended <= {8'b0, x};
                y_reg <= y;
                done <= 0;                
                count <= 5'b0;
                state <= BUSY;
            end

            BUSY: begin
                if (count < 8) begin
                    if (y_reg[0]) 
                        product <= product + x_extended;
                    y_reg <= y_reg >> 1;
                    x_extended <= x_extended << 1;
                    count <= count + 1;
                end 
                else begin
                    state <= FINISH;
                end
            end

            FINISH: begin
                done <= 1'b1;
                state <= IDLE;
            end

        endcase

    end

endmodule