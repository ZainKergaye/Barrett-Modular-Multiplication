module inefficient8 (
  input  [7:0]  a,
  input  [7:0]  b,
  input  [7:0]  q,
  output [7:0]  z
);
  assign z = (a * b) % q;
endmodule
