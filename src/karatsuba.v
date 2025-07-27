module karatsuba (
    input clk, reset,
    input [15:0] x , y,
    output reg [31:0] product,
    output reg done
);
    wire [15:0] z0, z1, z2, w0;

    shift_and_add m1(.clk(clk), .reset(reset), .x(x[7:0]), .y(y[7:0]), .product(z0));
    shift_and_add m2(.clk(clk), .reset(reset), .x(x[15:8]), .y(y[15:8]), .product(z2));
    shift_and_add m3(.clk(clk), .reset(reset), .x(x[15:8] + x[7:0]), .y(y[15:8] + y[7:0]), .product(w0));


    wire [15:0] z1_temp = w0 - z0 - z2;
    wire [31:0] temp_product = (z2 << 16) + (z1_temp << 8) + z0;

    reg [3:0] clk_counter;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_counter <= 4'b0;
            done <= 1'b0;
            product <= 1'b0;
        end

        else begin
            if (clk_counter < 4'b8) begin
                clk_counter <= (clk_counter + 1);
                done <= 1'b0;
            end
            else begin
                product <= temp_product;
                done <= 1'b1;
            end
        end
    end


endmodule