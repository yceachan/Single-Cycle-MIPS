module cotroller (
    input [5: 0 ] op,
    input [5: 0 ] funct,
    output MemtoReg, //*寄存器写回 数据源 0：ALU 1:RAM
    output MemWrite, //*数据存储器 写使能
   
    output [2:0] ALUControl, //*ALU 操作码
    output  ALUSrc, //*ALU SrcB位选信号
    output  ImmSign,//*符号扩展类型标志
    output  RegWrite, //* 寄存器写回使能

    output  RegDst, //* 寄存器文件写回位选 0-rt 1-rd 
    output wire BeqFlag, //* beq 指令标志    
    output wire BneFlag, //* bne 指令标志    
    output  Jump   //* PC数据位选 0-其他 1-j指令跳转
);

wire [1 : 0] ALUOp;
maindec  maindec_inst (
    .op(op),
    .MemtoReg(MemtoReg),
    .MemWrite(MemWrite),
    .ALUSrc(ALUSrc),
    .RegWrite(RegWrite),
    .RegDst(RegDst),
    .BeqFlag(BeqFlag),
    .BneFlag(BneFlag),
    .Jump(Jump),
    .ALUOp(ALUOp)
  );
  aludec  aludec_inst (
    .ALUOp(ALUOp),
    .funct(funct),
    .ImmSign(ImmSign),
    .ALUControl(ALUControl)
  );
endmodule //cotroller

module maindec(
    input [5 : 0] op,
    output reg MemtoReg, //*寄存器写回 数据源 0：ALU 1:RAM
    output reg MemWrite, //*数据存储器 写使能
    output reg ALUSrc, //*ALU SrcB位选信号 0: *rt 1:imm
    output reg RegWrite, //* 寄存器写回使能
    output reg RegDst, //* 寄存器文件写回位选 0-rt 1-rd 
    output wire BeqFlag, //* b 指令标志    
    output wire BneFlag, //* b 指令标志    
    output reg Jump,   //* PC数据位选 0-其他 1-j指令跳转
    output reg [1 : 0] ALUOp
);
assign BeqFlag = op == 6'b000100;
assign BneFlag = op == 6'b000101;
always @(*) begin
    case ( op )
    default   : begin RegWrite = 0; RegDst = 0 ;  ALUSrc = 0;    MemtoReg = 0; MemWrite = 0; ALUOp = 2'b00; Jump=0;       end //*保留,避免锁存器

    6'b000000 : begin RegWrite = 1; RegDst = 1 ;  ALUSrc  = 0;  MemWrite = 0; MemtoReg = 0;  ALUOp = 2'b10; Jump=0;  end //*R-type
    6'b100011 : begin RegWrite = 1; RegDst = 0 ;  ALUSrc  = 1;  MemWrite = 0; MemtoReg = 1;  ALUOp = 2'b00; Jump=0;  end //*lw -add
    6'b101011 : begin RegWrite = 0; RegDst = 0 ;  ALUSrc  = 1;  MemWrite = 1; MemtoReg = 0;  ALUOp = 2'b00; Jump=0;  end //*sw -add
    6'b000100 : begin RegWrite = 0; RegDst = 0 ;  ALUSrc  = 0;  MemWrite = 0; MemtoReg = 0;  ALUOp = 2'b01; Jump=0;  end //*b-sub
    6'b001000 : begin RegWrite = 1; RegDst = 0 ;  ALUSrc  = 1;  MemWrite = 0; MemtoReg = 0;  ALUOp = 2'b00; Jump=0;  end //*i-add
    6'b000010 : begin RegWrite = 0; RegDst = 0 ;  ALUSrc  = 0;  MemWrite = 0; MemtoReg = 0;  ALUOp = 2'bxx; Jump=1;  end //*j

    6'b001101 : begin RegWrite = 1; RegDst = 0 ;  ALUSrc  = 1;  MemWrite = 0; MemtoReg = 0;  ALUOp = 2'b11;  Jump=0;     end //*i-or  
    6'b000101 : begin RegWrite = 0; RegDst = 0 ;  ALUSrc  = 0;  MemWrite = 0; MemtoReg = 0;  ALUOp = 2'b01;  Jump=0;     end //*bne 数据路径
        

    endcase
end
endmodule //maindec


module aludec(
    input [1 : 0] ALUOp,
    input [5 : 0] funct,
    output reg ImmSign,//*运算对应的符号扩展类型标志  0:u 1:s
    output  reg [2:0] ALUControl
);
always @(*) begin
    case (ALUOp)
    default : begin ALUControl = 3'b000; ImmSign = 0; end //*保留
    2'b00   : begin ALUControl = 3'b010; ImmSign = 1; end//*加 i指令 
    2'b01   : begin ALUControl = 3'b110; ImmSign = 1; end//*减 b指令
    2'b10   : case (funct)
                 default  :  begin ALUControl = 3'b000; ImmSign = 0; end //*保留
                 6'b100000 : begin ALUControl = 3'b010; ImmSign = 1; end  //* R add
                 6'b100010 : begin ALUControl = 3'b110; ImmSign = 1; end //* R sub
                 6'b100100 : begin ALUControl = 3'b000; ImmSign = 0; end //* R and
                 6'b100101 : begin ALUControl = 3'b001; ImmSign = 0; end  //* R or
                 6'b101010 : begin ALUControl = 3'b111; ImmSign = 0; end  //* R slt
               endcase
    2'b11   : ALUControl = 3'b001;
    endcase

        
end

endmodule //aludec