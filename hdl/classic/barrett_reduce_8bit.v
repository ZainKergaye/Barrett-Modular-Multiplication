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
//   correction: if t >= 2q return t-2q else if t>=q return t-q else t
module barrett_reduce_8bit #(
  parameter integer Q = 251  // <-- set modulus here (must be > 0 and <= 255 for 8-bit)
)(
  input  wire [7:0] a,
  input  wire [7:0] b,
  output wire [7:0] r
);

  // ----------- Compile-time k and μ -----------
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

  localparam integer k = (Q <= 1) ? 1 : ceil_log2(Q);
  localparam integer MU = (Q == 0) ? 0 : ((1 << (2*k)) / Q); // floor(2^(2k)/Q)

  // ----------- Wide arithmetic widths -----------
  // z = a*b fits in up to 16 bits.
  // m2 = m1*MU; sizes depend on MU; use conservative widths.
  localparam integer ZW  = 16;
  localparam integer MW1 = ZW;              // m1 <= z/2^k
  localparam integer MW2 = MW1 + 2*k + 2; // extra headroom for μ multiply
  localparam integer TW  = ZW + 2*k + 2; // t worst-case headroom

  wire [ZW-1:0] z = a * b;

  // m1 = floor(z / 2^k) => z >> k
  wire [MW1-1:0] m1 = (k >= ZW) ? {MW1{1'b0}} : (z >> k);

  // m2 = m1 * μ
  wire [MW2-1:0] m2 = m1 * MU;

  // m3 = floor(m2 / 2^k) => m2 >> k
  wire [MW2-1:0] m3 = (k >= MW2) ? {MW2{1'b0}} : (m2 >> k);

  // t = z - m3*q
  wire [TW-1:0] prod_m3_q = m3 * Q; // unsigned
  wire [TW-1:0] t_raw = (z <= prod_m3_q) ? 0 : ( { {(TW-ZW){1'b0}}, z } - prod_m3_q );

  // Correction (classical): if t>=2q subtract 2q else if t>=q subtract q else t
  wire [TW-1:0] t_minus_2q = (t_raw >= (2*Q)) ? (t_raw - (2*Q)) : {TW{1'b0}};
  wire [TW-1:0] t_minus_q  = (t_raw >= Q)     ? (t_raw - Q)     : {TW{1'b0}};

  reg [TW-1:0] t_corr;
  always @* begin
    if (t_raw >= (2*Q))      t_corr = t_minus_2q;
    else if (t_raw >= Q)     t_corr = t_minus_q;
    else                      t_corr = t_raw;
  end

  assign r = t_corr[7:0];

endmodule

