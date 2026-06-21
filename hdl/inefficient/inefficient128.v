module inefficient128 (
  input  [127:0] a,
  input  [127:0] b,
  input  [127:0] q,
  output [127:0] z
);
  assign z = (a * b) % q;
endmodule

