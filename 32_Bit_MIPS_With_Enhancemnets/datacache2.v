`timescale 1ns / 1ps
module datacache(address, data_in, clk, rst, write, read, temp_out);

input [31:0] address;// 24-bit tag, 4-bit offset
input [31:0] data_in;
input clk,rst;
input write,read;
output [31:0] temp_out;

reg [31:0] pre_adr = 0;
reg [31:0] pre_data = 0;
reg [31:0] temp_out;

reg [31:0] cache_arr [0:15];
reg [31:0] mem_arr [0:255];
reg [0:0] v_arr [0:15];
reg [3:0] t_arr [0:15];

integer i;

always @(*)
begin 
	if(rst)
	begin
		for(i = 0; i<16; i = i+1)
		begin
			v_arr[i] <= 1'b0;
			t_arr[i] <= 5'b00000;
		end
	end
	else if(!rst && write)////write, which means sw
	begin
		begin
			mem_arr[pre_adr] <= data_in;
			v_arr[{pre_adr[7:4]}] <= 1;
			t_arr[{pre_adr[7:4]}] <= {pre_adr[31:8]};
			cache_arr[{pre_adr[7:4]}] <= pre_data;
		end
	end
	else if(!rst && read)//read, which means lw
	begin
		begin	
		if(v_arr[{pre_adr[7:4]}] == 1)
			begin
				if( t_arr[{pre_adr[7:4]}] == {pre_adr[31:8]})
				temp_out <= cache_arr[{pre_adr[7:4]}];
				else 
				begin
					cache_arr[{pre_adr[7:4]}] <= mem_arr[pre_adr];
					temp_out <= mem_arr[pre_adr];
				end
			end
		else
			begin
				cache_arr[{pre_adr[7:4]}] <= mem_arr[pre_adr];
				temp_out <= mem_arr[pre_adr];
			end
	
		end
	end
	else
	begin
		pre_adr <= address;
		pre_data <= data_in;
	end
end
endmodule
			












	 
