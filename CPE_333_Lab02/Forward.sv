`timescale 1ps / 1ns



module ForwardUnit(
	input clk,
	input rst,
	input rs1E,
	input rs2E,
	input rdM,
	input rdW,
	input rwE, //regWrite signals
	input rwM,
	input rwW,
	output logic [1:0] aluSrcA,
	output logic [1:0] aluSrcB
	);

	always_ff @ (posedge clk) begin
		if (rst) begin
			aluSrcA <= 0;
			aluSrcB <= 0;
		end else begin
			// ALU src A logic
			if ((rs1E == rdM) AND rwM AND (rs1E != 0)) begin
				aluSrcA <= 2; // read from alu result M
			end else if ((rs1E == rdW) AND rwW AND (rs1E != 0)) begin
				aluSrcA <= 1; // read from alu result W
			end else begin
				aluSrcA <= 00; // read from rd1 or u=type
			end
			
			// ALU src B logic
			if ((rs2E == rdM) AND rwM AND (rs2E != 0)) begin
				aluSrcA <= 2; // read from alu result M
			end else if ((rs2E == rdW) AND rwW AND (rs2E != 0)) begin
				aluSrcA <= 1; // read from alu result W
			end else begin
				aluSrcA <= 00; // read from rs2, i-type, s-type, or pc
			end
			
		end
	end


endmodule 
