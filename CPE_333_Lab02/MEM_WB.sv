`timescale 1ns / 1ps

module MEM_WB(
	input CLK,
	input RST,
	// Inputs
	input wire [31:0] DOUT_2_MEM,
	input wire [31:0] ALU_RESULT_MEM,
	input wire [31:0] PC_N_MEM,
	input wire REG_WRITE_MEM,
	input wire RF_WR_SEL_MEM,
	input wire RD_MEM,
	// Outputs 
	output logic [31:0] DOUT_2_WB,
	output logic [31:0] ALU_RESULT_WB,
	output logic [31:0] PC_N_WB,
	output logic REG_WRITE_WB,
	output logic RF_WR_SEL_WB,
	output logic RD_WB
	
	);

	// Clear internal registers on reset or readin from inputs
	always_ff @ (posedge CLK)
	begin
		if (RST)
		begin
			// Clear outputs
			DOUT_2_WB <= 0;
			ALU_RESULT_WB <= 0;
			PC_N_WB <= 0;
			REG_WRITE_WB <= 0;
			RF_WR_SEL_WB <= 0;
			RD_WB <= 0;
		end else 
		begin
			// Read inputs
			DOUT_2_WB <= DOUT_2_MEM;
			ALU_RESULT_WB <= ALU_RESULT_MEM;
			PC_N_WB <= PC_N_MEM;
			REG_WRITE_WB <= REG_WRITE_MEM;
			RF_WR_SEL_WB <= RF_WR_SEL_MEM;
			RD_WB <= RD_MEM;
		end
	end
			
endmodule
