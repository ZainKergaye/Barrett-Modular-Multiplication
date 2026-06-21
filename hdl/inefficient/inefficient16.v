module inefficient16 (
  input  [15:0] a,
  input  [15:0] b,
  input  [15:0] q,
  output [15:0] z
);
  assign z = (a * b) % q;
endmodule
