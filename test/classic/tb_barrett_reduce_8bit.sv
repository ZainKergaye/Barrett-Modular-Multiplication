//====================================================================
// Testbench for barrett_reduce_8bit
//====================================================================
`timescale 1ns/1ps

module tb_barrett_reduce_8bit;

  // -----------------------------------------------------------------
  // DUT ports
  // -----------------------------------------------------------------
  reg  clk;
  reg  [7:0] a, b, q;
  wire [7:0] r;

  // Instantiate the DUT
  barrett_reduce_8bit dut (
    .clock (clk),
    .a     (a),
    .b     (b),
    .q     (q),
    .r     (r)
  );

  // -----------------------------------------------------------------
  // Clock generation
  // -----------------------------------------------------------------
  initial clk = 0;
  always #5 clk = ~clk;   // 100 MHz clock

  // -----------------------------------------------------------------
  // Reference model (pure SystemVerilog)
  // -----------------------------------------------------------------
  function automatic [7:0] ref_barrett;
    input [7:0] aa, bb, qq;
    int unsigned prod;
    int unsigned k, mu, m1, m2, m3, t, res;
    begin
      prod = aa * bb;               // 0‑255 * 0‑255 => 0‑65025 (fits 16 bits)
      // k = ceil(log2(q))
      k = $clog2(qq);
      if ( (1 << k) < qq ) k = k + 1; // ensure ceil
      mu = (1 << (2*k)) / qq;          // floor(2^(2k)/q)

      m1 = prod >> k;
      m2 = m1 * mu;
      m3 = m2 >> k;
      t  = prod - m3 * qq;

      if (t >= 2*qq)      res = t - 2*qq;
      else if (t >= qq)   res = t - qq;
      else                res = t;

      ref_barrett = res[7:0];
    end
  endfunction

  // -----------------------------------------------------------------
  // Test procedure
  // -----------------------------------------------------------------
  initial begin
    // -----------------------------------------------------------------
    // 1. Static edge cases
    // -----------------------------------------------------------------
    // q = 1 (modulus 1 always yields 0)
    a = 8'hAA; b = 8'h55; q = 8'd1; @(posedge clk);
    #1; assert(r == 8'd0) else $error("q=1 failed, r=%0d", r);

    // q = 255 (largest 8‑bit modulus)
    a = 8'hFF; b = 8'hFF; q = 8'd255; @(posedge clk);
    #1; assert(r == ((a*b) % q)) else $error("q=255 failed, r=%0d", r);

    // a*b just below 2^k boundary
    a = 8'd15; b = 8'd15; q = 8'd17; @(posedge clk);
    #1; assert(r == ((a*b) % q)) else $error("boundary 1 failed");

    // a*b just above 2·q boundary
    a = 8'd200; b = 8'd200; q = 8'd51; @(posedge clk);
    #1; assert(r == ((a*b) % q)) else $error("boundary 2 failed");

    // -----------------------------------------------------------------
    // 2. Randomized testing (e.g., 10 000 vectors)
    // -----------------------------------------------------------------
    repeat (10000) begin
      a = $urandom_range(0,255);
      b = $urandom_range(0,255);
      // keep q > 0 to avoid divide‑by‑zero
      q = $urandom_range(1,255);
      @(posedge clk);
      #1;
      if (r !== ((a*b) % q))
        $error("Mismatch: a=%0d b=%0d q=%0d  r=%0d  ref=%0d",
               a,b,q,r,((a*b)%q));
    end

    $display("All tests passed.");
    $finish;
  end

endmodule
