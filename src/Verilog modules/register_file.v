module register_file (
    input clk, reset,
    input write_enable,
    input [1:0] read_reg_index1, read_reg_index2,
    input [1:0] write_reg_index,
    input signed [15:0] write_data,
    output reg signed [15:0] reg_read_1, reg_read_2
);

    reg signed [15:0] x0, x1, x2, x3;

    // Reset and Write in a single always block
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            x0 <= 16'b0;
            x1 <= 16'b0;
            x2 <= 16'b0;
            x3 <= 16'b0;
        end 
        else if (write_enable) begin
            case (write_reg_index)
                2'b00: x0 <= write_data;
                2'b01: x1 <= write_data;
                2'b10: x2 <= write_data;
                2'b11: x3 <= write_data;
            endcase
        end
    end

    // Read can stay in a separate always block (combinational or clocked)
    always @(negedge clk) begin
        case (read_reg_index1)
            2'b00: reg_read_1 <= x0;
            2'b01: reg_read_1 <= x1;
            2'b10: reg_read_1 <= x2;
            2'b11: reg_read_1 <= x3;
        endcase
        
        case (read_reg_index2)
            2'b00: reg_read_2 <= x0;
            2'b01: reg_read_2 <= x1;
            2'b10: reg_read_2 <= x2;
            2'b11: reg_read_2 <= x3;
        endcase
    end

endmodule
