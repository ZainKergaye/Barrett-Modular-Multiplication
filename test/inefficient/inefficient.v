`timescale 1ns/1ps

module tb;

  integer t;

  // DUTs
  wire [7:0]     z8;
  wire [15:0]    z16;
  wire [63:0]    z64;
  wire [127:0]   z128;

  reg  [7:0]     a8,   b8,   q8;
  reg  [15:0]    a16,  b16,  q16;
  reg  [63:0]    a64,  b64,  q64;
  reg  [127:0]   a128, b128, q128;

  inefficient8   u8   (.a(a8),   .b(b8),   .q(q8),   .z(z8));
  inefficient16  u16  (.a(a16),  .b(b16),  .q(q16),  .z(z16));
  inefficient64  u64  (.a(a64),  .b(b64),  .q(q64),  .z(z64));
  inefficient128 u128 (.a(a128), .b(b128), .q(q128), .z(z128));

  task compute_dummy; begin end endtask // placeholder (not checking)

  // Measure *simulated* delay from input change to output change
  real start8, start16, start64, start128;
  real dt8, dt16, dt64, dt128;

  initial begin
    // init (avoid divide-by-zero)
    a8=0; b8=0; q8=8'd3;
    a16=0; b16=0; q16=16'd7;
    a64=0; b64=0; q64=64'd11;
    a128=0; b128=0; q128=128'd13;

    // give some time for initial settling
    #5;

    for (t = 0; t < 200; t = t + 1) begin
      // --- 8-bit ---
      start8 = $time;
      a8 = $random; b8 = $random; q8 = $random; if (q8==0) q8=8'd3;
      // wait for the output to change (0-delay changes still give dt=0)
      @(z8);
      dt8 = $time - start8;

      // --- 16-bit ---
      start16 = $time;
      a16 = $random; b16 = $random; q16 = $random; if (q16==0) q16=16'd7;
      @(z16);
      dt16 = $time - start16;

      // --- 64-bit ---
      start64 = $time;
      a64 = { $random, $random }; b64 = { $random, $random }; q64 = { $random, $random }; if (q64==0) q64=64'd11;
      @(z64);
      dt64 = $time - start64;

      // --- 128-bit ---
      start128 = $time;
      a128 = { $random, $random, $random, $random };
      b128 = { $random, $random, $random, $random };
      q128 = { $random, $random, $random, $random };
      if (q128==0) q128=128'd13;
      @(z128);
      dt128 = $time - start128;

      // Print a sample; adjust verbosity if needed
      $display("t=%0d: dt8=%0t dt16=%0t dt64=%0t dt128=%0t", t, dt8, dt16, dt64, dt128);
    end

    $finish;
  end

endmodule

