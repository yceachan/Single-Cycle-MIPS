
module mips_tb;

  // Parameters

  //Ports
  reg  clk;
  reg  rstn;
  wire [31 : 0] pc_dut;
  mips  mips_inst (
    .clk(clk),
    .rstn(rstn),
    .pc_dut(pc_dut)
  );

always #5  clk = ! clk ;
initial begin
  clk <= 0;
  rstn <= 1;
  #1 rstn =0;
  #1 rstn =1;
end
always @(negedge clk) begin
  if (pc_dut >= 12*4) #15 $stop;
end
endmodule
