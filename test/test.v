module test (
  input clk,
  input a,
  input en,
  inout y
);
  assign y = en ? a : 1'bz;
endmodule
