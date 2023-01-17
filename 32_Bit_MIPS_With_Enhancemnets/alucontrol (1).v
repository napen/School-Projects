module alucontrol( alucont, aluop, funct ) ;

// decodes the 'funct' field from the assembly instruction
// determines the type of instruction it is: R, I, J
// creates a 3-bit control line (alucont) for the ALU itself.

   input  [1:0] aluop   ;
   input  [5:0] funct   ;
   output reg [3:0] alucont ;

   always @(*)
      case(aluop)
         2'b00: alucont <= 4'b0010;  // add for lw/sw
         2'b01: alucont <= 4'b0110;  // sub (for beq)
         2'b11: alucont <= 4'b0010;  // addi
         2'b10: case(funct)       // R-Type instructions
                     6'b100000: alucont <= 4'b0010; // add (for add)
                     6'b100010: alucont <= 4'b0110; // subtract (for sub)
                     6'b100100: alucont <= 4'b0000; // logical and (for and)
                     6'b100101: alucont <= 4'b0001; // logical or (for or)
		     6'b100111: alucont <= 4'b1100; // nor
                     6'b101010: alucont <= 4'b0111; // set on less (for slt)
                     default:   alucont <= 4'b0101; // should never happen
                  endcase
	default: alucont <= 4'b1111; //shouldn't happen
      endcase

endmodule
