`timescale 1ns / 1ps

module MEM_WB(
	input logic CLK,
	input logic RST,
	// Inputs
	input logic [31:0] DOUT_2_MEM,
	input logic [31:0] ALU_RESULT_MEM,
	input logic [31:0] PC_N_MEM,
	input logic REG_WRITE_MEM,
	input logic RF_WR_SEL_MEM,
	input logic RD_MEM,
	// Outputs 
	output logic [31:0] DOUT_2_WB,
	output logic [31:0] ALU_RESULT_WB,
	output logic [31:0] PC_N_WB,
	output logic REG_WRITE_WB,
	output logic RF_WR_SEL_WB,
	output logic RD_WB
	
	);

	// Registers	
	logic [31:0] MEM_DOUT_2_WB;
	logic [31:0] MEM_ALU_RESULT_WB;
	logic [31:0] MEM_PC_N_WB;
	logic MEM_REG_WRITE_WB;
	logic MEM_RF_WR_SEL_WB;
	logic MEM_RD_WB;

	// Clear internal registers on reset or readin from inputs
	always_ff @ (posedge CLK)
	begin
		if (RST)
		begin
			MEM_DOUT_2_WB <= 0;
			MEM_ALU_RESULT_WB <= 0;
			MEM_PC_N_WB <= 0;
			MEM_REG_WRITE_WB <= 0;
			MEM_RF_WR_SEL_WB <= 0;
			MEM_RD_WB <= 0;
		end else 
		begin
			MEM_DOUT_2_WB <= DOUT_2_MEM;
			MEM_ALU_RESULT_WB <= ALU_RESULT_MEM;
			MEM_PC_N_WB <= PC_N_MEM;
			MEM_REG_WRITE_WB <= REG_WRITE_MEM;
			MEM_RF_WR_SEL_WB <= RF_WR_SEL_MEM;
			MEM_RD_WB <= RD_MEM;
		end
	end

	// Clear outputs on reset or write to outputs
	always_ff @ (posedge CLK)
	begin
		if (RST)	
		begin
			DOUT_2_WB <= 0;
			ALU_RESULT_WB <= 0;
			PC_N_WB <= 0;
			REG_WRITE_WB <= 0;
			RF_WR_SEL_WB <= 0;
			RD_WB <= 0;
		end else 
		begin
			DOUT_2_WB <= MEM_DOUT_2_WB;
			ALU_RESULT_WB <= MEM_ALU_RESULT_WB; 
			PC_N_WB <= MEM_PC_N_WB;
			REG_WRITE_WB <= MEM_REG_WRITE_WB;
			RF_WR_SEL_WB <= MEM_RF_WR_SEL_WB;
			RD_WB <= MEM_RD_WB;
		end
	end	

			

endmodule
