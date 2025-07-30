module main_memory (
    input clk,
    input reset,
    input [9:0] address,       
    input signed [15:0] data_in,
    input write_enable,
    input read_enable,
    output reg signed [15:0] data_out
);

    // 1024x16-bit memory
    reg signed [15:0] memory [0:1023];

    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // Clear memory on reset
            for (i = 0; i < 1024; i = i + 1) begin
                memory[i] <= 16'b0;
            end
            data_out <= 16'b0;
        end 


        else begin
            // Write operation for store
            if (write_enable)
                memory[address] <= data_in;

            // Read operation for load
            if (read_enable)
                data_out <= memory[address];
        end
    end

endmodule
