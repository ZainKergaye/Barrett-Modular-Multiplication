// Barrett reduction (classical BMM) for 8-bit inputs.
// Computes r = (a*b) mod q for fixed (parameter) q.
//
// Algorithm:
//   k  = ceil(log2(q))
//   μ  = floor(2^(2k) / q)
//   z  = a*b
//   m1 = floor(z / 2^k)
//   m2 = m1 * μ
//   m3 = floor(m2 / 2^k)
//   t  = z - m3*q
//   if t >= 2q return t-2q else if t>=q return t-q else t
//   Have an understanding of how a circuit is structred rather than the math
//   DOES NOT NEED A CLOCK
//   PRECALC CONSTANT OUTSIDE OF FUNC. FEED INTO CIRCUIT DIRECTLY
//   DO 1 - 2 algorithms
//   DONT CARE ABOUT A AND B YET, TAKE Z AS INPUT
//   MAKE Z A RANDOM NUMBER
module barrett_reduce_8bit #(
	parameter integer WIDTH = 1
)(
	input  wire [WIDTH-1:0] z,
	input  wire [WIDTH-1:0] q,
	input  wire [WIDTH-1:0] k,
	input  wire [WIDTH-1:0] u,
  output wire [WIDTH-1:0] r
);
assign r = q;
endmodule

