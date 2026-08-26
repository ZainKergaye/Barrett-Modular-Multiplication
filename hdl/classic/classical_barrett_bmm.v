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
module classical_barrett_bmm #(
	parameter integer K = 13, 
	parameter integer Q = 7681, 
	parameter integer MU = 8736
)(
	input wire [K-1:0] a,
	input wire [K-1:0] b, 
	output wire [K-1:0] result
);
	
	localparam integer W = 2*K + 2;

	wire [W-1:0] z;
	wire [W-1:0] m1;
	wire [W-1:0] m2;
	wire [W-1:0] m3;
	wire [W-1:0] mq;
	wire [W-1:0] t;

	// Step 3: z = a * b
	assign z = a * b;

	// Step 4: m1 = floor(z / 2^K)
	assign m1 = z >> K;

	// Step 5: m2 = m1 * MU
	assign m2 = m1 * MU;

	// Step 6: m3 = floor(m2 / 2^K)
	assign m3 = m2 >> K;

	// Step 6.5: mq = m3 * Q
	assign mq = m3 * Q;

	// Step 7: t = z - mq
	assign t = z - mq;

	// Step 8: Overflow correction
	always_comb begin
		if (t >= 2*Q)
			result = t - 2*Q;
		else if (t >= Q)
			result = t - Q;
		else
			result = t[K-1:0];
		end
	end
endmodule
