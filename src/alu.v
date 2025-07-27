module alu (
    input [15:0] a, b,
    input [2:0] opcode,
    input clk, reset,
    output reg [31:0] result,
    output done
);

    wire [15:0] CSA_add_result, CSA_sub_result;
    wire cout_add, cout_sub;

    carry_select_adder(a, b, 1'b0, cout_add, CSA_add_result);
    carry_select_adder(a, ~b, 1'b1, cout_sub, CSA_sub_result);


    wire [31:0] karatsuba_result;
    wire karatsuba_done;

    karatsuba mult_unit(
        .clk(clk), .reset(reset), .x(a), .y(b), 
        .product(karatsuba_result), .done(karatsuba_done)
    );


    always @(posedge clk or posedge reset) begin
        if (reset) begin
            result <= 32'b0;
            done <= 1'b0;
        end
        else begin
            case(opcode)
                3'b000: begin result <= {15'b0, cout_add, CSA_add_result}; done <= 1'b1; end
                3'b001: begin result <= {16{cout_sub}, CSA_sub_result};     done <= 1'b1; end
                3'b010: begin result <= karatsuba_result;                  done <= karatsuba_done; end
                default: begin result <= 32'b0; done <= 1'b1; end
            endcase
        end
    end


endmodule
