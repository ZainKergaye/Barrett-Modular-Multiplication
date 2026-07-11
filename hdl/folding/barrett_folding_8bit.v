// Barrett folding reduction for 8-bit inputs.
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
module barrett_folding_8bit (
	input  wire clock,
  input  wire [7:0] a,
  input  wire [7:0] b,
	input  wire [7:0] q,
  output wire [7:0] r
);

  function integer ceil_log2;
    input integer x;
    integer t;
    begin
      // x assumed > 1
      t = 0;
      x = x - 1;
      while (x > 0) begin
        t = t + 1;
        x = x >> 1;
      end
      ceil_log2 = t;
    end
  endfunction

	reg [16-1:0] s, qPrime, zPrime, k, Mu, z, m1, m2, m3, t, res;

	always @(posedge clock) begin 
		// Pre computation phase
		k = ceil_log2(q); // # of bits in q
		s = k >> 1; // k / 2
		qPrime = (1 << (3 * s)) % q; // 2^3s mod q not sure how to do the mod q
		Mu = (1 << (3*s)) / q; // 2^3s / q

		// Integer multiplication phase 
		z = a * b;
		
		// Reduction steps 
		m1 = z >> (1 << (3*s)); // z / (2^3s)
		m2 = m1 * qPrime; 
		zPrime = m2 + (z % (1<<(3*s))); // m2 + z mod 2^3s
		m3 = m2 >> k;
		t = z - m3 * q;

		// Overflow correctio4
    if (t >= (2*q))      res = t - 2 * q;
    else if (t >= q)     res = t - q;
    else                 res = t;

	end

	assign r = res;
endmodule

