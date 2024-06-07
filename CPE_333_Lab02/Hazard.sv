`timescale 1ps / 1ns

module HazardUnit(
	input clk, 
	input rst,
	input rs1D,
	input rs2D,
	input rs1E,
	input rs2E,
	input rdE,
	input rdW,
	input rdM,
	input rwM, //regWrite
	input rwW, 
	input pcsourceE,

	output logic stallF,
	output logic stallD,
	output logic flushE,
	output logic [1:0] alusrcA,
	output logic [1:0] alusrcB
	);


	always_comb begin
		if(rst) begin
			flushE <= 1;
		end
	end

	ForwardUnit myFU(
		.clk(clk),
		.rst(rst),
		.rs1E(rs1E),
		.rs2E(rs2E),
		.rdM(rdM),
		.rdW(rdW),
		.rwE(rwE),
		.rwM(rwM),
		.rwW(rwW),

		.aluSrcA(alusrcA),
		.aluSrcB(alusrcB)
		);

		

endmodule
