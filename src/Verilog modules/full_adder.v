module full_adder (
    input a, b, cin,
    output sum, cout
);
    wire x, y, z;

    xor(x, a, b);
    xor(sum, x, cin);

    and(y, a, b);
    and(z, cin, x);
    or(cout, y, z);

endmodule