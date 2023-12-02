//*考虑到指令存储器的尺度，不宜用非同步电路综合。故选择在时钟的下降沿，与PC时钟更新。addr输入为pc_next
//*addr端口，其输入为pc_next，0-时刻的pc_next即为pc初值0
module imem 
(
    input clk,
    input rstn,
    input [31 : 0] addr,
    output reg [31 : 0] dout
);
reg [31 : 0] mem [63 : 0];
wire [31 : 0] addr_by_4 = {2'b00 , addr[31 : 2 ]}; //*addr按字节寻址，右移两位，字对齐作为mem的index

//*此器件应通过ip核调用FPGA硬件资源。在rtl中写initial语句以预存储指令。
initial begin  
  $readmemh("memfile2.dat",mem);
end
always @(negedge clk or negedge rstn) begin
  if(!rstn) dout <= mem[0];
  else      dout <= mem[addr_by_4];
end
endmodule