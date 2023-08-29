//
// Simple 1st order Sigma Delta DAC
//

module sigma_delta_dac_1storder #(parameter signalwidth=16)
(
   input clk,
   input reset_n,
   input [signalwidth-1:0] d,
   output q
);

reg q_reg;
assign q=q_reg;

reg [signalwidth:0] sigma;

always @(posedge clk or negedge reset_n) begin
   if(!reset_n) begin
      sigma <= {1'b1,{signalwidth{1'b0}}};
      q_reg <= 1'b0;
   end else begin
      sigma <= sigma[signalwidth-1:0] + d;
      q_reg <= sigma[signalwidth];
   end
end

endmodule

