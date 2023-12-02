//*考虑寄存器文件，或l1, 尺度较小，选用组合逻辑读出，以尽快完成单周期运算;令写回的时机发生在时钟下降沿，比PC慢一拍。
module regfile (
    input clk,
    input rstn,
    input WE3,
    input [4 :0] A1,
    input [4 :0] A2,
    input [4 :0] A3,
    input [31 :0] WD3,
    output wire [31 : 0] RD1,
    output wire [31 : 0] RD2
);
reg [31 : 0] regfile [31 : 0] ;

always @(negedge clk or negedge rstn) begin 
    if (!rstn) begin :regfile_init
        integer i;
        for (i=0; i  <32 ; i = i + 1 ) regfile[i] = 0;
    end
   else begin
        if(WE3) regfile[A3] <= WD3;
   end
end
//*寄存器读地址产生后，直接通过非同步读取方式，读取两个源寄存器的数据，与立即数操作数一起准备好，进入ALU的输入端。以尽快地在单周期内完成计算。
assign RD1 = regfile[A1];
assign RD2 = regfile[A2];
endmodule