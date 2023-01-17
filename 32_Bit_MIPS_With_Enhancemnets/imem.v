module imem(clk, adr,memdata,rst);

   input clk,rst;
   input [31:0] adr;
   output reg [31:0] memdata;
   reg [31:0] mips_ram [0:255];
   reg [31:0] temp;
   integer i;

 //  initial
//	begin
//		
	//	$readmemh("test.dat", mips_ram); //hex
	//end
   always@(posedge rst)
	begin
		for(i=0; i<256; i=i+1)
		begin
			mips_ram[i]=32'b0;
		end
		mips_ram[0] = 32'h01095020;
		mips_ram[1] = 32'hAC0A8000;
		mips_ram[2] = 32'h8EB10000;
		mips_ram[3] = 32'h20040001;
		mips_ram[4] = 32'h2005ffff;
	end
   always@(posedge clk)
	begin
		memdata <= mips_ram[adr>>2];

	//if(memdata)
	//f <= 1;
	//else
	//f<=0;

	end

endmodule
