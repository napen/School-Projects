`timescale 1ns / 1ps

module test2();

reg clk;
reg rst;
reg [31:0] data_in;
wire [31:0] data_out;

reg read;
reg write;

reg [31:0] address;

initial
begin
	clk <= 0;
	write <= 1;
	read <= 0;
	forever
	#5 clk <= ~clk;
end

initial
begin
	rst <= 1;
	#10 rst <= 0;
end

datacache U1(.address(address), .data_in(data_in),.clk(clk),.rst(rst),.write(write),.read(read),.temp_out(data_out));


/*initial
#15
repeat(120)
begin
	#20
	data_in <= ({$random}%4294967295);
	address <= ({$random}%32767);
end
*/
initial
begin
#10
data_in <= 32'd54;
address <= 16'd10;
#10
read <= 0 ;
write <=1 ;
#10
write <=0;
#10
data_in <= 32'd21;
address <= 16'd100;
#10
read <= 0 ;
write <= 1 ;
#10
write <=0;
#10
data_in <= 32'd99;
address <= 16'd50;
#10
read <= 0 ;
write <= 1 ;
#10
write <=0;
#10
address <= 16'd50;
#10
read <= 1;
write <= 0 ;
#10
read <= 0;
#10
data_in <= 32'd88;
address <= 16'd10;
#10
read <= 0 ;
write <= 1 ;
#10
write <=0;
#10
address <= 16'd10;
#10
read <= 1;
write <= 0 ;
#10
read <=0;
#10
address <= 16'd100;
#10
read <= 1;
write <= 0 ;
#10
read <=0;
#10 $finish;


end

initial
	begin
	$shm_open ("cache2_TB");
	$shm_probe (test2,"AS");
	end

endmodule
	
