//`timescale 1ns/10ps
module mips #(parameter WIDTH = 32, REGBITS = 5)( clk, reset,pcen);//,IF,ID,EX,MEM,WB); 
input clk, reset,pcen;
output IF,ID,EX,MEM,WB;
   wire [WIDTH-1:0] sl2out,wd,nextpc,readpc,alub;
   wire [3:0]  alucont;

   wire		   pcsrc, memreadID,memwriteID,alusrcID,regdstID,branchID,regwriteID,memtoregID; //1 bit ID regs
   wire [WIDTH-1:0] instrIF,instrID,pcplus4IF,pcplus4ID, signextendoutID,rd1ID,rd2ID; //32 bit IF and ID regs
   wire [1:0]	   aluopID,aluopEX; //2 bit ID and EX
   wire [WIDTH-1:0] pcplus4EX,signextendoutEX,instrEX,aluresultEX,branchpcEX,rd1EX,rd2EX; //32 bit EX regs
   wire		   alusrcEX,regdstEX,branchEX,memwriteEX,memreadEX, zeroEX, regwriteEX,memtoregEX, memreadMEM,memwriteMEM,branchMEM,zeroMEM,regwriteMEM,memtoregMEM; // 1 bit EX and MEM regs
   wire [WIDTH-1:0] aluresultMEM,branchpcMEM,rd2MEM,dcoutMEM,dcoutWB,aluresultWB; //32 bit MEM and WB regs	
   wire		   memtoregWB, regwriteWB; //1 bit WB regs
   wire  [4:0]	   waEX, waMEM, waWB;
flag flags(.reset(reset),.instrIF(instrIF),.instrID(instrID),.instrEX(instrEX),.aluresultMEM(aluresultMEM),.aluresultWB(aluresultWB),.flagIF(IF),.flagID(ID),.flagEX(EX),.flagMEM(MEM),.flagWB(WB));


clkdiv divider(.clk(fclk),.reset(reset),.clk_out(clk));

//Instruction Fetch
mux2 #(WIDTH)	pcmux(.d0(pcplus4IF), .d1(branchpcMEM), .s(pcsrc), .y(nextpc));
PC 		pcreg(.nextpc(nextpc),.outpc(readpc),.reset(reset),.enable(pcen),.clk(clk));
adder		pcadder(.out(pcplus4IF), .in1(readpc), .in2(32'h00000004));
imem		instrmem(.clk(clk), .adr(readpc), .memdata(instrIF),.rst(reset));

//Instruction Decode
controller	cont(.alusrc(alusrcID), .aluop(aluopID), .memread(memreadID), .memwrite(memwriteID), .memtoreg(memtoregID), .branch(branchID), .regwrite(regwriteID), .regdst(regdstID), .op(instrID[31:26]), .clk(clk), .reset(reset));
regfile #(WIDTH, REGBITS) rf(.clk(clk), .regwrite(regwriteWB), .ra1(instrID[25:21]), .ra2(instrID[20:16]), .wa(waWB), .wd(wd), .rd1(rd1ID), .rd2(rd2ID),.rst(reset));//NEED to add wa and wd
signextend	se(.in(instrID[15:0]) , .out(signextendoutID));

//Execution
alucontrol	aluc(.alucont(alucont), .aluop(aluopEX), .funct(signextendoutEX[5:0])); //should be the same as instr[5:0]
shiftleft2	sl2(.out(sl2out), .in(signextendoutEX));
//adder		branchadder(.out(branchpcEX), .in1(pcplus4EX), .in2(sl2out));
mux2_5 		regmux(.d0(instrEX[20:16]), .d1(instrEX[15:11]), .s(regdstEX), .y(waEX));
mux2 #(WIDTH)	alumux(.d0(rd2EX), .d1(signextendoutEX), .s(alusrcEX), .y(alub));
alu #(WIDTH)	alumain(.a(rd1EX), .b(alub), .alucont(alucont), .result(aluresultEX), .zero(zeroEX));

//Memory
datacache	dc(.address(aluresultMEM), .data_in(rd2MEM),.temp_out(dcoutMEM),.read(memreadMEM),.write(memwriteMEM),.clk(clk),.rst(reset));

//Writeback
mux2 #(WIDTH)	wdmux(.d0(dcoutWB), .d1(aluresultWB), .s(memtoregWB), .y(wd));


//pipelinestages
IFID #(WIDTH)	ifid(instrIF,instrID,pcplus4IF, pcplus4ID,clk);

IDEX #(WIDTH)	idex(clk,memreadID,memwriteID,alusrcID,regdstID,branchID,regwriteID,memtoregID,instrID,pcplus4ID, signextendoutID,rd1ID,rd2ID,aluopID,aluopEX,pcplus4EX,signextendoutEX,instrEX,rd1EX,rd2EX,alusrcEX,regdstEX,branchEX,memwriteEX,memreadEX, regwriteEX,memtoregEX);//zeroEX,branchpcEX

EXMEM #(WIDTH)	exmemp(clk,branchEX,memwriteEX,memreadEX, zeroEX, regwriteEX,memtoregEX,aluresultEX,pcplus4EX,rd2EX,waEX, memreadMEM,memwriteMEM,branchMEM,zeroMEM,regwriteMEM,memtoregMEM,waMEM,aluresultMEM,branchpcMEM,rd2MEM);//,dcoutMEM);

MEMWB #(WIDTH)	memwb(clk,regwriteMEM,memtoregMEM,dcoutMEM,aluresultMEM,waMEM,waWB,memtoregWB, regwriteWB,dcoutWB,aluresultWB);


assign pcsrc = branchEX & zeroMEM;
//assign branchpcEX = pcplus4EX; //| sl2out;
endmodule

module IFID #(parameter WIDTH = 32)(instrIF,instrID,pcplus4IF, pcplus4ID,clk);
	input [WIDTH-1:0] instrIF,pcplus4IF;
	input clk;
	output reg [WIDTH-1:0] instrID,pcplus4ID;
	always@(posedge clk)
	begin
		//Fetch -> Decode
		instrID <= instrIF;
		pcplus4ID <= pcplus4IF;
	end
endmodule

module IDEX #(parameter WIDTH = 32)(clk,memreadID,memwriteID,alusrcID,regdstID,branchID,regwriteID,memtoregID,instrID,pcplus4ID, signextendoutID,rd1ID,rd2ID,aluopID,aluopEX,pcplus4EX,signextendoutEX,instrEX,rd1EX,rd2EX,alusrcEX,regdstEX,branchEX,memwriteEX,memreadEX, regwriteEX,memtoregEX);//branchcEX, zeroEX;
	input clk;	
	input memreadID,memwriteID,alusrcID,regdstID,branchID,regwriteID,memtoregID;
	input [WIDTH-1:0] instrID,pcplus4ID, signextendoutID,rd1ID,rd2ID;
	input [1:0] aluopID;
	output reg [1:0] aluopEX;
	output reg [WIDTH-1:0] pcplus4EX,signextendoutEX,instrEX,rd1EX,rd2EX;//branchpcEX
	output reg alusrcEX,regdstEX,branchEX,memwriteEX,memreadEX,regwriteEX,memtoregEX;// zeroEX, 
	always@(posedge clk)
	begin
		//Decode -> Execute
		pcplus4EX <= pcplus4ID;
		signextendoutEX <= signextendoutID;
		instrEX <= instrID;
		rd1EX <= rd1ID;
		rd2EX <= rd2ID;
		regdstEX <= regdstID;
		alusrcEX <= alusrcID;
		aluopEX <= aluopID;
		branchEX <= branchID;
		regwriteEX <= regwriteID;
		memreadEX <= memreadID;
		memwriteEX <= memwriteID;
		memtoregEX <= memtoregID;
	end
endmodule

module EXMEM#(parameter WIDTH = 32)(clk,branchEX,memwriteEX,memreadEX, zeroEX, regwriteEX,memtoregEX,aluresultEX,branchpcEX,rd2EX,waEX, memreadMEM,memwriteMEM,branchMEM,zeroMEM,regwriteMEM,memtoregMEM,waMEM,aluresultMEM,branchpcMEM,rd2MEM);//,dcoutMEM
	input clk;	
	input branchEX,memwriteEX,memreadEX, zeroEX, regwriteEX,memtoregEX;
	input[WIDTH-1:0] aluresultEX,branchpcEX,rd2EX;
	input [4:0]	   waEX;
	output reg memreadMEM,memwriteMEM,branchMEM,zeroMEM,regwriteMEM,memtoregMEM;
	output reg [4:0]   waMEM;
	output reg [WIDTH-1:0] aluresultMEM,branchpcMEM,rd2MEM;//,dcoutMEM;

	always@(posedge clk)
	begin
		//Execute -> Memory
		waMEM <= waEX;
		rd2MEM <= rd2EX;
		aluresultMEM <= aluresultEX;
		branchMEM <= branchEX;
		zeroMEM <= zeroEX;
		branchpcMEM <= branchpcEX;
		memreadMEM <= memreadEX;
		memwriteMEM <= memwriteEX;
		regwriteMEM <= regwriteEX;
		memtoregMEM <= memtoregEX;
	end
endmodule

module MEMWB#(parameter WIDTH = 32)(clk,regwriteMEM,memtoregMEM,dcoutMEM,aluresultMEM,waMEM,waWB,memtoregWB, regwriteWB,dcoutWB,aluresultWB);
	input clk;	
	input regwriteMEM,memtoregMEM;
	input [WIDTH-1:0] dcoutMEM,aluresultMEM;
	input [4:0]	   waMEM;
	output reg [4:0]   waWB;
	output reg memtoregWB, regwriteWB;
	output reg [WIDTH-1:0] dcoutWB,aluresultWB;

	always@(posedge clk)
	begin
		//Memory -> Write Back
		regwriteWB <= regwriteMEM;
		dcoutWB <= dcoutMEM;
		aluresultWB <= aluresultMEM;
		waWB <= waMEM;
		memtoregWB <= memtoregMEM;
	end
endmodule

module alu #(parameter WIDTH = 32)
            (input      [WIDTH-1:0] a, b, 
             input      [3:0]       alucont, 
             output reg [WIDTH-1:0] result,
	     output zero);

   wire     [WIDTH-1:0] sum, slt;
   assign zero = (alucont==0); //Zero is true if aluout is 0;
   // slt should be 1 if most significant bit of sum is 1

   always@(*)
      case(alucont)
         4'b0000: result <= a & b;
         4'b0001: result <= a | b;
         4'b0010: result <= a + b;
         4'b0110: result <= a - b;
	 4'b0111: result <= a < b ? 1:0;
	 4'b1100: result <= ~(a | b); //result is nor
	 default: result <= 0; //default to 0 which shouldn't happen 
      endcase
endmodule

module regfile #(parameter WIDTH = 32, REGBITS = 5)
                (input                clk, rst,
                 input                regwrite, 
                 input  [REGBITS-1:0] ra1, ra2, wa, 
                 input  [WIDTH-1:0]   wd, 
                 output reg [WIDTH-1:0]   rd1, rd2);

   reg  [31:0] memory [(1<<REGBITS)-1:0];

   // three ported register file
   // read two ports combinationally
   // write third port on rising edge of clock
   // register 0 hardwired to 0
	
   always @(posedge clk or posedge rst)
   begin
	if(rst)	
	begin
		memory[0] <= 32'h00000000;
		memory[1] <= 32'h00000000;
		memory[2] <= 32'h00000000;
		memory[3] <= 32'h00000000;
		memory[4] <= 32'h00000000;
		memory[5] <= 32'h00000000;
		memory[6] <= 32'h00000000;
		memory[7] <= 32'h00000000;
		memory[8] <= 32'h00000001;
		memory[9] <= 32'h00000002;
		memory[10] <= 32'h00000000;
		memory[11] <= 32'h00000000;
		memory[12] <= 32'h00000000;
		memory[13] <= 32'h00000000;
		memory[14] <= 32'h00000000;
		memory[15] <= 32'h00000000;
		memory[16] <= 32'h00000000;
		memory[17] <= 32'h00000000;
		memory[18] <= 32'h00000003;
		memory[19] <= 32'h00000003;
		memory[20] <= 32'h00000004;
		memory[21] <= 32'h00000000;
		memory[22] <= 32'h00000008;
		memory[23] <= 32'h00000000;
		memory[24] <= 32'h00000000;
		memory[25] <= 32'h00000000;
		memory[26] <= 32'h00000000;
		memory[27] <= 32'h00000000;
		memory[28] <= 32'h00000000;
		memory[29] <= 32'h00000000;
		memory[30] <= 32'h00000000;
		memory[31] <= 32'h00000000;
	end

	else if(regwrite)
	begin
		memory[wa] <= wd;
	end
   end

   always @(ra1,ra2)
   begin
	rd1 = memory[ra1];
   	rd2 = memory[ra2];
   end
endmodule
	

module signextend(in ,out);

input  [15:0] in;
output [31:0] out;

assign out =  (in[15] == 1)? {16'hffff , in} : 
              (in[15] == 0)? {16'h0000 ,in}  : 16'hxxxx;

endmodule

module shiftleft2(out, in);

input [31:0]in;
output [31:0]out;

assign out = in << 2;

endmodule

module mux2_5(input  [4:0] d0, d1, 
              input              s, 
              output [4:0] y);

   assign y = s ? d1 : d0; 
endmodule

module mux2 #(parameter WIDTH = 32)
             (input  [WIDTH-1:0] d0, d1, 
              input              s, 
              output [WIDTH-1:0] y);

   assign y = s ? d1 : d0; 
endmodule

module adder(out, in1, in2);

input [31:0] in1,in2;
output [31:0] out;

assign out = in1 + in2;
endmodule

module PC (nextpc,outpc,reset,enable,clk);
	input [31:0] nextpc;
	input reset,enable,clk;
	output reg [31:0] outpc;

	always@(posedge clk or posedge reset)
	begin 
		if(reset)
		begin
			outpc <= 32'b0;
		end
		else if(enable == 1)
		begin
			outpc <= nextpc;
		end
		else
		begin
			outpc <= outpc;
		end
	end
endmodule


