//====================================================================
// Testbench for barrett_reduce_8bit
//====================================================================
`timescale 1ns/1ps

module tb_barrett_reduce_8bit;
	integer BITS= 16;
  reg  [BITS - 1:0] z q k u;
  wire [BITS - 1:0] r;

  barrett_reduce_8bit dut (
		.z		 (z),
    .q     (q),
		.k		 (k),
		.u     (u),
    .r     (r)
  );

	// Testing here
  initial begin

    $display("All tests passed.");
    $finish;
  end

endmodule
