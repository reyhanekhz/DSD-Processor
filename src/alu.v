module alu (
    input [15:0] a, b,
    input [2:0] opcode,
    output [15:0] result
);

    wire [15:0] CSA_add_result;
    wire [15:0] CSA_sub_result;

    wire cout_add, cout_sub;

    carry_select_adder(a, b, 1'b0, cout_add, CSA_add_result);
    carry_select_adder(a, ~b, 1'b1, cout_sub, CSA_sub_result);


    assign result = (opcode == 3'b000) ? CSA_add_result :
                    (opcode == 3'b001) ? CSA_sub_result :
                    16'b0;


endmodule