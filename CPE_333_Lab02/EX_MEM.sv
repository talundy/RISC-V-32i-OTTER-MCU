`timescale 1ns / 1ps

module EX_MEM(
	input CLK,
	input RST,
	//*************** INPUT ***************//
	// Control signals
	input wire [1:0] SIZE_EX,				// Memory Signal
	input wire SIGN_EX,					// Memory Signal 
	input wire RF_WR_SEL_EX,
	input wire REG_WRITE_EX,
	input wire MEM_READ_2_EX,			 	// Memory Signal	
	input wire MEM_WRITE_EX,				// Memory Signal
	// ALU Result
	input wire [31:0] ALU_RESULT_EX,		// Memory Signal (non-exclusive)
	// Other
	input wire [31:0] RS2_EX,				// Memory Signal
	input wire [31:0] RD_EX,
	input wire [31:0] PC_N_EX,
	//*************** OUTPUT***************//
	// Control signals
	output logic [1:0] SIZE_MEM,				// Memory Signal
	output logic SIGN_MEM,					// Memory Signal
	output logic RF_WR_SEL_MEM,
	output logic REG_WRITE_MEM,
	output logic MEM_READ_2_MEM,			 	// Memory Signal	
	output logic MEM_WRITE_MEM,				// Memory Signal
	// ALU Result
	output logic [31:0] ALU_RESULT_MEM,		// Memory Signal (non-exclusive)
	// Other
	output logic [31:0] RS2_MEM,				// Memory Signal
	output logic [31:0] RD_MEM,
	output logic [31:0] PC_N_MEM

	);

	// Clear internal registers on reset, else read input
	always_ff @ (posedge CLK)
	begin
		if(RST)
		begin
			// Clear outputs on reset
			SIZE_MEM <= 0;
			SIGN_MEM <= 0;	
			RF_WR_SEL_MEM <= 0;
			REG_WRITE_MEM <= 0;
			MEM_READ_2_MEM <= 0;		 	
			MEM_WRITE_MEM <= 0;		
			ALU_RESULT_MEM <= 0;	
			RS2_MEM <= 0;	
			RD_MEM <= 0;
			PC_N_MEM <= 0;
		end else 
		begin
			SIZE_MEM <= SIZE_EX;
			SIGN_MEM <= SIGN_EX;
			RF_WR_SEL_MEM <= RF_WR_SEL_EX;
			REG_WRITE_MEM <= REG_WRITE_EX;
			MEM_READ_2_MEM <= MEM_READ_2_EX;
			MEM_WRITE_MEM <= MEM_WRITE_EX;
			ALU_RESULT_MEM <= ALU_RESULT_EX;
			RS2_MEM <= RS2_EX;
			RD_MEM <= RD_EX;
			PC_N_MEM <= PC_N_EX; 
		end
	end

endmodule
