module alu #(parameter W = 32 ) (
    input signed [W-1 : 0 ] SrcA,
    input signed [W-1 : 0 ] SrcB,
    input [2 : 0 ]  ALUControl,
    output reg [W-1 : 0 ] ALUResult,
    output wire  Zero
);
assign  Zero = (ALUResult == 0);

always @(*) begin
    case (ALUControl)
    3'b000: begin //AND
        ALUResult = SrcA & SrcB;   //* 按位与，与符号位无关。
    end
    3'b001: begin // OR
        ALUResult = SrcA | SrcB;
    end
    3'b010: begin // plus
       ALUResult = SrcA + SrcB;
    end
    3'b011: begin // UNESED
        ALUResult = 0;
    end
    3'b100: begin //  SrcA AND ~SrcB
        ALUResult =  SrcA & ~SrcB;
    end
    3'b101: begin //  SrcA OR ~SrcB
        ALUResult =  SrcA | ~SrcB;
    end
    3'b110: begin //  SrcA sub SrcB 
       ALUResult = SrcA - SrcB;
    end
    3'b111: begin //  slt ALUResult = SrcA < SrcB ?  1 : 0;
       ALUResult = SrcA < SrcB ? 1 : 0;
    end
    endcase
end

endmodule //alu

