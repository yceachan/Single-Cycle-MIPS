//*数据存储器的尺度较大，又需要在单周期内完成ram_io和此后的reg_写回操作，故将其读出的时机定在上升沿，慢PC半拍
//*写入的时机放在下降沿，慢PC一拍，这样，存储器的数据是新的。
module dmem 
(
    input clk,
    input rstn,
    input WE,
    input [31 : 0] din,
    input [31: 0] addr,
    output reg [31 : 0] dout
);
reg  [31 : 0] mem [63 : 0];
wire [31 : 0] addr_by_4 = { 2'b00 , addr[31 : 2] }; //*addr按字节寻址，右移两位，字对齐作为mem的index
always @(negedge clk or negedge rstn) begin 
    if ( !rstn ) begin :sram_init
        integer i;
        for ( i = 0 ; i < 64 ; i = i + 1 ) begin
          mem[i] <= 0;
        end
    end
    else begin 
       if(WE)      mem[addr_by_4] <= din;
    end
end

always @(posedge clk or negedge rstn ) begin
    if(!rstn) dout <=0;
    else   if ( !WE )   dout <= mem [addr_by_4];
end
endmodule