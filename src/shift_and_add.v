module shift_and_add (
    input clk, reset,
    input [7:0] x, y,
    output reg [15:0] product
);

    reg [15:0] x_extended;
    reg [7:0] y_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            x_extended <= {8'b0, x};
            product <= 16'b0;
            y_reg <= y;
        end 

        else begin 
            if (y[0] == 1'b1)
                product <= (product + x_extended);
            y_reg <= (y_reg >> 1);
            x_extended <= (x_extended << 1);
        end
    end

endmodule