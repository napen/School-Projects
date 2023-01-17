module clkdiv 
#( 
parameter WIDTH = 64, // Width of the register required
parameter N = 100000000// We will divide by 12 for example in this case
)
(clk,reset, clk_out);
 
input clk;
input reset;
output reg clk_out;
 
reg [WIDTH-1:0] count;
//wire [WIDTH-1:0] r_nxt;
//reg clk_track;
 
always @(posedge clk or posedge reset)
 
begin
  if (reset)
     begin
        count <= 32'b0;
		  clk_out <= 1'b0;
     end
 
  else if (count == N - 1)
 	   begin
	     count <= 0;
	     clk_out <= ~clk_out;
	   end
  else 
		begin
			count <= count + 1;
			clk_out <= clk_out;
		end
end
 
 //assign r_nxt = r_reg+1;   	      
 //assign clk_out = clk_track;
endmodule
 
