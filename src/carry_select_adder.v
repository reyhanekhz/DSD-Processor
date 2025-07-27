module carry_select_adder (
    input [15:0] a, b,
    input cin,
    output cout,
    output [15:0] sum
);

    wire c0, c1, c2;
    wire c1_0, c1_1, c2_0, c2_1, c3_0, c3_1;
    wire [3:0] sum1_0, sum1_1, sum2_0, sum2_1, sum3_0, sum3_1;


    ripple_carry_adder(a[3:0], b[3:0], cin, sum[3:0], c0);
    
    ripple_carry_adder(a[7:4], b[7:4], 1'b0, sum1_0, c1_0);
    ripple_carry_adder(a[7:4], b[7:4], 1'b1, sum1_1, c1_1);
    assign sum[7:4] = (c0 == 1'b0) ? sum1_0 : sum1_1;
    assign c1 = (c0 == 1'b0) ? c1_0 : c1_1;

    ripple_carry_adder(a[11:8], b[11:8], 1'b0, sum2_0, c2_0);
    ripple_carry_adder(a[11:8], b[11:8], 1'b1, sum2_1, c2_1);
    assign sum[11:8] = (c1 == 1'b0) ? sum2_0 : sum2_1;
    assign c2 = (c1 == 1'b0) ? c2_0 : c2_1;
   
    ripple_carry_adder(a[15:12], b[15:12], 1'b0, sum3_0, c3_0);
    ripple_carry_adder(a[15:12], b[15:12], 1'b1, sum3_1, c3_1);
    assign sum[15:12] = (c2 == 1'b0) ? sum3_0 : sum3_1;
    assign cout = (c2 == 1'b0) ? c3_0 : c3_1;
   

endmodule