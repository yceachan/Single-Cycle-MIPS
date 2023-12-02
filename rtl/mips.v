module mips 
(
    input clk,
    input rstn,
    output wire [31:0] pc_dut
);
//*************************************MIPS信号列表***************************************//
//*instr译码信号
wire [31:0] instr;
wire [5: 0] op = instr[31:26];
wire [4: 0] rs = instr[25:21];
wire [4: 0] rt = instr[20:16];
wire [4: 0] rd = instr[15 : 11];
wire [4 : 0] shamt = instr [10 :6];
wire [5 : 0] funct = instr [5 : 0];
wire [15: 0] imm = instr[15:0]; 

//*controller信号
wire MemtoReg; //*控制信号 寄存器写回 数据源 0：ALU 1:R
wire MemWrite; //*控制信号 数据存储器 写使能
wire [2:0] ALUControl; //*控制信号 ALU 操作码
wire  ALUSrc; //* 控制信号 ALU SrcB位选信号  0:rt  1:imm
wire  RegWrite; //* 控制信号 寄存器写回使能
wire  RegDst; //* 控制信号 寄存器文件写回位选 0-rt 1-rd
wire BeqFlag; //* beq 指令标志    
wire BneFlag; //* bne 指令标志    
wire  Jump  ; //* 控制信号 PC数据位选 0-其他 1-j指令跳转
wire ImmSign; //*ALU运算，符合扩展类型标志

//* ALU数据路径
wire  [31 : 0] immExt_s={ { 16 { imm[15] } }, imm}; //*imm有符号扩展 大括号看花了。。。
wire [31 : 0] immExt_u={16'b0 , imm}; //TODO imm无符号扩展 ,unused
wire [31 : 0]  SrcA; //*ALU 操作数A
wire [31 : 0]  SrcB;//*ALU 操作数B
wire[ 31 : 0 ] ALUResult;//*ALU 运算结果
wire Zero;

wire [31:0] RF_RD1;  //*RF 读通道1
wire [31:0] RF_RD2;  //*RF 读通道2

assign SrcA = RF_RD1;   //*以组合逻辑读出
assign SrcB =ALUSrc ? (ImmSign ? immExt_s : immExt_u) : RF_RD2; //*以组合逻辑读出




//*pc数据路径
reg [31 : 0 ] PC;
assign pc_dut = PC;
wire [31 : 0 ] pc_puls_4  = PC + 32'd4 ;
wire [31 : 0 ] pc_jta_imm = immExt_s<<2 ;
wire [31 : 0 ] pc_bta     = pc_puls_4 + pc_jta_imm ;  //*PCBranch
wire [31 : 0 ] pc_jta     = { PC[31:28] , instr[25:0] , 2'b0}; //* JTA = {PC[31:28],j_addr ,2'b0}  
wire           PCSrc      = (BeqFlag & Zero) | (BneFlag & !Zero);   //beq or bne  :，PCSrc =  bta
wire [31 : 0 ] pc_next        = Jump? pc_jta : (PCSrc? pc_bta : pc_puls_4);


always @(negedge clk or negedge rstn)      begin
    if(!rstn)  PC <= 0; 
    else       PC <= pc_next;
end
//*数据存储器数据路径
wire [31 : 0]  ReadData;
wire [31 : 0]  WriteData   = RF_RD2 ;   //数据寄存器写通道，sw: *mem=*rt;

//*写回数据路径
wire [31 : 0]  Result; 
assign         Result  = MemtoReg? ReadData : ALUResult;    //*写回位选 ram or alu
wire [4 : 0]   addr_wb = RegDst ? rd : rt;
//*************************************子模组例化***************************************//

imem  imem_inst (
    .clk(clk),
    .rstn(rstn),
    .addr(pc_next),  
    .dout(instr)
  );

regfile  regfile_inst (
    .clk(clk),
    .rstn (rstn),
    .WE3(RegWrite),   //!RegWrite; //* 寄存器写回使能
    .A1(rs),
    .A2(rt),
    .A3(addr_wb),
    .WD3(Result),  //*寄存器写回通道
    .RD1(RF_RD1),
    .RD2(RF_RD2)
  );



alu #(.W(32))
 alu_inst (
    .SrcA(SrcA),
    .SrcB(SrcB),
    .ALUControl(ALUControl),
    .ALUResult(ALUResult),
    .Zero(Zero)
  );
    

  dmem dmem_inst (
    .clk(clk),
    .rstn (rstn),
    .WE(MemWrite),
    .din(WriteData),
    .addr(ALUResult),
    .dout(ReadData)
  );

  cotroller  cotroller_inst (
    .op(op),
    .funct(funct),
    .MemtoReg(MemtoReg),
    .MemWrite(MemWrite),
    .ALUControl(ALUControl),
    .ALUSrc(ALUSrc),
    .ImmSign(ImmSign),
    .RegWrite(RegWrite),
    .RegDst(RegDst),
    .BeqFlag(BeqFlag),
    .BneFlag(BneFlag),
    .Jump(Jump)
  );

endmodule



