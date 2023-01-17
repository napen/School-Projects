module flag(reset, instrIF, instrID, instrEX, aluresultMEM, aluresultWB, flagID, flagIF, flagEX, flagMEM, flagWB);
	input reset;
	input instrIF, instrID, instrEX;
	input aluresultMEM, aluresultWB;
	output reg flagIF, flagID, flagEX, flagMEM, flagWB;
	
	always @(*)
	begin
		if (reset)
			begin
				flagIF <= 1'b0;
				flagID <= 1'b0;
				flagEX <= 1'b0;
				flagMEM <= 1'b0;
				flagWB <= 1'b0;
			end
		else if (instrIF)
			flagIF <= 1'b1;
		else if (instrID)
			flagID <= 1'b1;
		else if (instrEX)
			flagEX <= 1'b1;
		else if (aluresultMEM)
			flagMEM <= 1'b1;
		else if (aluresultWB)
			flagWB <= 1'b1;
		else 
			begin
				flagIF <= 1'b0;
				flagID <= 1'b0;
				flagEX <= 1'b0;
				flagMEM <= 1'b0;
				flagWB <= 1'b0;
			end
	end
endmodule
	
	
	
	
