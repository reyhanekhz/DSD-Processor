module main_memory (
    input clk, reset,
    input [15:0] address,
    input [15:0] data_in,
    input write_enable, read_enable,
    output reg [15:0] data_out,
);

    reg [15:0] memory [0:65535];



    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (integer i = 0; i < 65536; i = i + 1) begin
                memory[i] = 16'b0;
                data_out <= 16'b0;
            end
        end

        else begin 
            if (write_enable) begin
                memory[address] <= data_in;
            end
            if (read_enable) begin
                data_out <= memory[address];
            end
        end
    end
endmodule 