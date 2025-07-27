module karatsuba (
    input clk,
    input reset,
    input start,
    input [15:0] x, y,
    output reg [31:0] product,
    output reg done
);

    // Split inputs
    wire [7:0] x_low  = x[7:0];
    wire [7:0] x_high = x[15:8];
    wire [7:0] y_low  = y[7:0];
    wire [7:0] y_high = y[15:8];

    // Wires for multiplier outputs
    wire [15:0] z0, z2, w0;
    wire d0, d2, d1;

    // Start signals for each multiplier
    reg s0, s1, s2;

    // Instantiate 3 parallel multipliers
    shift_and_add m0(.clk(clk), .reset(reset), .start(s0), .x(x_low),               .y(y_low),               .product(z0), .done(d0));
    shift_and_add m1(.clk(clk), .reset(reset), .start(s1), .x(x_high),              .y(y_high),              .product(z2), .done(d2));
    shift_and_add m2(.clk(clk), .reset(reset), .start(s2), .x(x_low + x_high),      .y(y_low + y_high),      .product(w0), .done(d1));

    // Local registers for z1 and final product
    reg [15:0] z1;

    // FSM states

    parameter IDLE = 2'b00, INIT = 2'b01, BUSY = 2'b10, FINISH = 2'b11;
    reg [1:0] state;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            done <= 0;
            s0 <= 0; s1 <= 0; s2 <= 0;
            product <= 0;
            z1 <= 0;
        end else begin
            case (state)
                IDLE: begin
                    done <= 0;
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
                    if (d0 && d1 && d2) begin
                        z1 <= w0 - z0 - z2;
                        product <= ({z2,16'b0}) + ({z1,8'b0}) + z0;
                        state <= FINISH;
                    end
                end

                FINISH: begin
                    done <= 1;
                    state <= IDLE; 
                end
            endcase
        end
    end
endmodule
