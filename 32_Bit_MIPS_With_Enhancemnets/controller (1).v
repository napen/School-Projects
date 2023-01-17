module controller(alusrc, aluop, 
                  memread, memwrite, memtoreg, 
		  branch, regwrite, regdst,
                  op, clk, reset) ;
	//12/1 need to finalize opcodes and corresponding outputs
   // INPUTS (3)
   input  [5:0]   op         ;	// OPCODE
   input          clk, reset;
   //input 	  zero;

   // OUTPUTS (12)
   output         alusrc    ;	// ALUSrcA
   output [1:0]   aluop      ;	// ALUOp
   output         memread    ;	// MemRead
   output         memwrite   ;	// MemWrite
   output         memtoreg   ;	// MemtoReg
   //output 	  pcsource   ;	// PCSrc
   output         regwrite   ;	// RegWrite
   output	  regdst     ;	// RegDst
   output	  branch     ;

   // REGISTERS
   reg 		  alusrc     ;
   reg [1:0]      aluop      ;	// ALUOp
   reg            branch     ;	// Branch
   reg            memread    ;	// MemRead
   reg            memwrite   ;	// MemWrite
   reg            memtoreg   ;	// MemtoReg
   reg            regwrite   ;	// RegWrite
   reg   	  regdst     ;	// RegDst



   // OPCODES  -- Make input decoding simpler
   // 
   parameter      LW      =  6'b100011;	// load word
   parameter      SW      =  6'b101011; // store word
   parameter      RTYPE   =  6'b0; // Regsiter type instuction TODO - see lecture 4b 
   parameter      BEQ     =  6'b000100; // Branch if Equal instruction i-type TODO
   parameter      J       =  6'b000010; //  Jump, not used in this
   parameter	  ADDI	  =  6'b001000; // addi op
   
   always @(op or reset)
      begin

	if(reset)
	begin
		alusrc <= 0;
		aluop <= 2'b00;
		memread <= 0;
		memwrite <= 0;
		memtoreg <= 0;
		regwrite <= 0;	
		regdst <= 0;
		branch <= 0;
   	end

	else 
	begin
	case(op)
		
	LW:
	   begin
	        alusrc <= 1;
		aluop <= 2'b00;
		memread <= 1;
		memwrite <= 0;
        	memtoreg <= 1;
        	regwrite <= 1;	
		regdst <= 0;
		branch <= 0;
	   end
	SW:
	   begin
	        alusrc <= 1;
		aluop <= 2'b00;
		memread <= 0;
		memwrite <= 1;
        	memtoreg <= 0;
        	regwrite <= 0;	
		//regdst <= 1'bx;
		branch <= 0;
	   end
	RTYPE:
	   begin
	        alusrc <= 0;
		aluop <= 2'b10;
		memread <= 0;
		memwrite <= 0;
        	memtoreg <= 0;
        	regwrite <= 1;	
		regdst <= 1;
		branch <= 0;
	   end
	BEQ:
	   begin
	        alusrc <= 0;
		aluop <= 2'b01;
		memread <= 0;
		memwrite <= 0;
        	memtoreg <= 0;
        	regwrite <= 1;	
		//regdst <= 1'bx;
		branch <= 1;
	   end
	J: //not used
	   begin
	        alusrc <= 0;
		aluop <= 2'b10;
		memread <= 0;
		memwrite <= 0;
        	memtoreg <= 0;
        	regwrite <= 1;	
		regdst <= 1;
		branch <= 0;
	   end
	ADDI:
	   begin
	        alusrc <= 1;
		aluop <= 2'b11;
		memread <= 0;
		memwrite <= 0;
        	memtoreg <= 0;
        	regwrite <= 1;	
		regdst <= 0;
		branch <= 0;
	   end
	endcase
	end
     end
   
endmodule
