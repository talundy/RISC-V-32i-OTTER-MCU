`timescale 1ns / 1ps

module EX_MEM(
	input logic CLK,
	input logic RST,
	//*************** INPUT ***************//
	// Control signals
	input logic [1:0] SIZE_EX,				// Memory Signal
	input logic SIGN_EX,					// Memory Signal 
	input logic RF_WR_SEL_EX,
	input logic REG_WRITE_EX,
	input logic MEM_READ_2_EX,			 	// Memory Signal	
	input logic MEM_WRITE_EX,				// Memory Signal
	// ALU Result
	input logic [31:0] ALU_RESULT_EX,		// Memory Signal (non-exclusive)
	// Other
	input logic [31:0] RS2_EX,				// Memory Signal
	input logic [31:0] RD_EX,
	input logic [31:0] PC_N_EX,
	
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
	output logic [31:0] PC_N_MEM,

	);

	//*************** REGISTERS ***************//
	logic [1:0] EX_SIZE_MEM;				// Memory Signal
	logic EX_SIGN_MEM;					// Memory Signal
	logic EX_RF_WR_SEL_MEM;
	logic EX_REG_WRITE_MEM;
	logic EX_MEM_READ_2_MEM;			 	// Memory Signal	
	logic EX_MEM_WRITE_MEM;				// Memory Signal
	logic [31:0] EX_ALU_RESULT_MEM;		// Memory Signal (non-exclusive)
	logic [31:0] EX_RS2_MEM;				// Memory Signal
	logic [31:0] EX_RD_MEM;
	logic [31:0] EX_PC_N_MEM;

	// Clear internal registers on reset, else read input
	always_ff @ (posedge CLK)
	begin
		if(RST)
		begin
			EX_SIZE_MEM <= 0;
			EX_SIGN_MEM <= 0;	
			EX_RF_WR_SEL_MEM <= 0;
			EX_REG_WRITE_MEM <= 0;
			EX_MEM_READ_2_MEM <= 0;		 	
			EX_MEM_WRITE_MEM <= 0;		
			EX_ALU_RESULT_MEM <= 0;	
			EX_RS2_MEM <= 0;	
			EX_RD_MEM <= 0;
			EX_PC_N_MEM <= 0;
		end else 
		begin
			EX_SIZE_MEM <= SIZE_EX;
			EX_SIGN_MEM <= SIGN_EX
			EX_RF_WR_SEL_MEM <= RF_WR_SEL_EX;
			EX_REG_WRITE_MEM <= REG_WRITE_EX;
			EX_MEM_READ_2_MEM <= MEM_READ_2_EX;
			EX_MEM_WRITE_MEM <= MEM_WRITE_EX;
			EX_ALU_RESULT_MEM <= ALU_RESULT_EX;
			EX_RS2_MEM <= RS2_EX;
			EX_RD_MEM <= RD_EX;
			EX_PC_N_MEM <= PC_N_EX; 
		end
	end

	// Clear outputs on reset, else write output
	always_ff @ (posedge CLK)
	begin
		SIZE_MEM <= 0;
		SIGN_MEM <= 0;
		RF_WR_SEL_MEM <= 0;
		REG_WRITE_MEM <= 0;
		MEM_READ_2_MEM <= 0;	
		MEM_WRITE_MEM <= 0;
		ALU_RESULT_MEM <= 0;
		RS2_MEM	<= 0;
		RD_MEM <= 0;
		PC_N_MEM <= 0;
	end else 
	begin
		SIZE_MEM <= EX_SIZE_MEM; 
		SIGN_MEM <= EX_SIGN_MEM; 
		RF_WR_SEL_MEM <= EX_RF_WR_SEL_MEM;
		REG_WRITE_MEM <= EX_REG_WRITE_MEM; 
		MEM_READ_2_MEM <= EX_MEM_READ_2_MEM; 
		MEM_WRITE_MEM <= EX_MEM_WRITE_MEM;
		ALU_RESULT_MEM <= EX_ALU_RESULT_MEM;
		RS2_MEM	<= EX_RS2_MEM; 
		RD_MEM <= EX_RD_MEM;
		PC_N_MEM <= EX_PC_N_MEM;
	end

endmodule
