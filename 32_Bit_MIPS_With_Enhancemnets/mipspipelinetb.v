`timescale 10ps/10ps
module mipsptb();

reg clk,rst,pcen;
//wire counterIF,counterID,counterEX,counterMEM,counterWB;

mips DUT(.clk(clk), .reset(rst),.pcen(pcen));//,.counterIF(counterIF),.counterID(counterID),.counterEX(counterEX),.counterMEM(counterMEM),.counterWB(counterWB));

initial begin
	rst <= 1'b1;
	clk <= 1'b0;
	pcen <= 1'b0;
	
	#50 rst<= 1'b0;
	#51 pcen <= 1'b1;

	#100000 $finish;
	
end

always #100 clk = ~clk;

initial
 begin
    // Open a db file for saving simulation data
  $shm_open ("mipsp_tb.db");
    // Collect all signals (hierarchically) from the module "tb"
  $shm_probe (mipsptb,"AS");
 end

endmodule

