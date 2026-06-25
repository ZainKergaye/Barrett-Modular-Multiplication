// Barrett reduction (improved BMM) for 8-bit inputs.
// Computes r = (a*b) mod q for fixed (parameter) q.
//
// Algorithm:
//   k  = ceil(log2(q))
//   μ  = floor(2^(2k + 3) / q)
//   z  = a*b
//   m1 = floor(z / 2^(k-2))
//   m2 = m1 * μ
//   m3 = floor(m2 / 2^(k + 5))
//   t  = z - m3*q
//   if t>=q return t-q else t
module barrett_improved_8bit (
	input  wire clock,
  input  wire [7:0] a,
  input  wire [7:0] b,
	input  wire [7:0] q,
  output wire [7:0] r
);

	reg [16-1:0] k, Mu, z, m1, m2, m3, t, res;

	always @(posedge clock) begin 
		// Pre computation phase
		k = 8; // # of bits in q NOTE: NOT RIGHT
		// TODO: FIGURE OUT HOW TO GET # OF BITS IN Q
		Mu = (1 << (2*k + 3)) / q; // 2^2k / q I don't think floor matters

		// Integer multiplication phase 
		z = a * b;
		
		// Reduction steps 
		m1 = z >> (k - 2);
		m2 = m1 * Mu;
		m3 = m2 >> (k + 5);
		t = z - m3 * q;

		// Overflow correction
    if (t >= q)     res = t - q;
    else                 res = t;

	end

	assign r = res;
endmodule

