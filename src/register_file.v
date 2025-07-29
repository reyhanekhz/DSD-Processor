module register_file (
    input clk, reset,
    input write_enable,
    input [1:0] read_reg_index1, read_reg_index2,
    input [1:0] write_reg_index,
    input signed [15:0] write_data,
    output reg signed [15:0] reg_read_1, reg_read_2
);

    reg signed [15:0] x0, x1, x2, x3;


    always @(posedge reset) begin
        // Reset registers to 0 at first
        x0 <= 16'b0;
        x1 <= 16'b0;
        x2 <= 16'b0;
        x3 <= 16'b0;
    end

    // Read on falling edge of clocks
    always @(negedge clk) begin
        case (read_reg_index1)
            2'b00: begin
                reg_read_1 <= x0;
            end
            2'b01: begin
                reg_read_1 <= x1;
            end
            2'b10: begin
                reg_read_1 <= x2;
            end
            2'b11: begin
                reg_read_1 <= x3;
            end
        endcase
        
        case (read_reg_index2)
            2'b00: begin
                reg_read_2 <= x0;
            end
            2'b01: begin
                reg_read_2 <= x1;
            end
            2'b10: begin
                reg_read_2 <= x2;
            end
            2'b11: begin
                reg_read_2 <= x3;
            end
        endcase
    end


    // Write on rising edge of clocks
    always @(posedge clk) begin
        if (write_enable == 1'b1) begin
            case (write_reg_index)
                2'b00: begin
                    x0 <= write_data;
                end
                2'b01: begin
                    x1 <= write_data;
                end
                2'b10: begin
                    x2 <= write_data;
                end
                2'b11: begin
                    x3 <= write_data;
                end
            endcase
        end
    end

endmodule