module inefficient64 (
  input  [63:0] a,
  input  [63:0] b,
  input  [63:0] q,
  output [63:0] z
);
  assign z = (a * b) % q;
endmodule
