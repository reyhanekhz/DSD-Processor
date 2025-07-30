module karatsuba (
    input clk,
    input reset,
    input start,
    input signed [15:0] x, y,
    output reg signed [31:0] product,
    output reg done
);

    // Save the sign
    wire result_sign = x[15] ^ y[15];

    // Multiply the absolute values and apply the sign in the end
    wire [15:0] abs_x = x[15] ? -x : x;
    wire [15:0] abs_y = y[15] ? -y : y;

    wire [7:0] x_low  = abs_x[7:0];
    wire [7:0] x_high = abs_x[15:8];
    wire [7:0] y_low  = abs_y[7:0];
    wire [7:0] y_high = abs_y[15:8];


    wire [15:0] z0, z2, w0;
    wire d0, d2, d1; // Done signals
    reg s0, s1, s2; // Start signals


    // Parallel multipliers
    shift_and_add m0(.clk(clk), .reset(reset), .start(s0), .x(x_low), .y(y_low),  .product(z0), .done(d0));
    shift_and_add m1(.clk(clk), .reset(reset), .start(s1), .x(x_high), .y(y_high), .product(z2), .done(d2));
    shift_and_add m2(.clk(clk), .reset(reset), .start(s2), .x(x_low + x_high), .y(y_low + y_high), .product(w0), .done(d1));

    reg [15:0] z1;
    reg [31:0] unsigned_product;

    // States
    parameter IDLE = 2'b00, INIT = 2'b01, BUSY = 2'b10, FINISH = 2'b11;
    reg [1:0] state;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            done <= 0;
            s0 <= 0; s1 <= 0; s2 <= 0;
            product <= 0;
            z1 <= 0;
        end 
        
        else begin
            case (state)
                IDLE: begin
                    done <= 0;
                    // Wait till start
                    if (start) begin
                        s0 <= 1;
                        s1 <= 1;
                        s2 <= 1;
                        state <= INIT;
                    end
                end

                INIT: begin
                    s0 <= 0;
                    s1 <= 0;
                    s2 <= 0;
                    state <= BUSY;
                end

                BUSY: begin
                    // Wait till multipliers are done
                    if (d0 && d1 && d2) begin
                        z1 <= w0 - z0 - z2;
                        unsigned_product <= ({z2,16'b0}) + ({z1,8'b0}) + z0;
                        state <= FINISH;
                    end
                end

                FINISH: begin
                    product <= result_sign ? -unsigned_product : unsigned_product;
                    done <= 1;
                    state <= IDLE; 
                end
            endcase
        end
    end
endmodule
