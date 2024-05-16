`timescale 1ns / 1ps

module ID_EX(
//*************** INPUT SIGNALS ****************//
	// MCU Signals 
	input logic CLK,
	input logic RST,

	// Decoder Control Signals
	input logic [1:0] PC_SOURCE_ID, 		// EXECUTE SIGNAL
	input logic ALU_SRCA_ID,				// EXECUTE SIGNAL
	input logic [1:0] ALU_SRCB_ID,			// EXECUTE SIGNAL
	input logic [3:0] ALU_FUN_ID,			// EXECUTE SIGNAL
	input logic [1:0] RF_WR_SEL_ID,
	//..// Read/Write Signals
	input logic PC_WRITE_ID,				// EXECUTE SIGNAL
	input logic MEM_WRITE_ID,
	input logic REG_WRITE_ID,
	input logic MEM_READ_2_ID,
	
	// Register Signals
	input logic [31:0] RS1_ID,				// EXECUTE SIGNAL
	input logic [31:0] RS2_ID,				// EXECUTE SIGNAL (NON-EXCLUSIVE)
	input logic [31:0] RD_ID,
	
	// Immediate Signals
	input logic [31:0] U_TYPE_ID,			// EXECUTE SIGNAL
	input logic [31:0] I_TYPE_ID,			// EXECUTE SIGNAL
	input logic [31:0] S_TYPE_ID,			// EXECUTE SIGNAL

	// Branch Address Signals
	input logic [31:0] JAL_ID,				// EXECUTE SIGNAL
	input logic [31:0] BRANCH_ID,			// EXECUTE SIGNAL
	input logic [31:0] JALR_ID,				// EXECUTE SIGNAL
	
	// PC Signals
	input logic [31:0] PC_ID,				// EXECUTE SIGNAL
	input logic [31:0] PC_N_ID,

	// Memory Signals
	input logic [1:0] SIZE_ID,
	input logic SIGN_ID,

//*************** OUTPUT SIGNALS ****************//
	// Decoder Control Signals
	output logic [1:0] PC_SOURCE_EX, 		// EXECUTE SIGNAL
	output logic ALU_SRCA_EX,				// EXECUTE SIGNAL
	output logic [1:0] ALU_SRCB_EX,			// EXECUTE SIGNAL
	output logic [3:0] ALU_FUN_EX,			// EXECUTE SIGNAL
	output logic [1:0] RF_WR_SEL_EX,
	//..// Read/Write Signals
	output logic PC_WRITE_EX,				// EXECUTE SIGNAL
	output logic MEM_WRITE_EX,
	output logic REG_WRITE_EX,
	output logic MEM_READ_2_EX,
	
	// Register Signals
	output logic [31:0] RS1_EX,				// EXECUTE SIGNAL
	output logic [31:0] RS2_EX,				// EXECUTE SIGNAL (NON-EXCLUSIVE)
	output logic [31:0] RD_EX,
	
	// Immediate Signals
	output logic [31:0] U_TYPE_EX,			// EXECUTE SIGNAL
	output logic [31:0] I_TYPE_EX,			// EXECUTE SIGNAL
	output logic [31:0] S_TYPE_EX,			// EXECUTE SIGNAL

	// Branch Address Signals
	output logic [31:0] JAL_EX,				// EXECUTE SIGNAL
	output logic [31:0] BRANCH_EX,			// EXECUTE SIGNAL
	output logic [31:0] JALR_EX,				// EXECUTE SIGNAL
	
	// PC Signals
	output logic [31:0] PC_EX,				// EXECUTE SIGNAL
	output logic [31:0] PC_N_EX,

	// Memory Signals
	output logic [1:0] SIZE_EX,
	output logic SIGN_EX

	);

//*************** THE PIPELINE REGISTERS. ****************//
	logic [1:0] ID_PC_SOURCE_EX; 		// EXECUTE SIGNAL
	logic ID_ALU_SRCA_EX;				// EXECUTE SIGNAL
	logic [1:0] ID_ALU_SRCB_EX;			// EXECUTE SIGNAL
	logic [3:0] ID_ALU_FUN_EX;			// EXECUTE SIGNAL
	logic [1:0] ID_RF_WR_SEL_EX;
	logic ID_PC_WRITE_EX;				// EXECUTE SIGNAL
	logic ID_MEM_WRITE_EX;
	logic ID_REG_WRITE_EX;
	logic ID_MEM_READ_2_EX;
	logic [31:0] ID_RS1_EX;				// EXECUTE SIGNAL
	logic [31:0] ID_RS2_EX;				// EXECUTE SIGNAL (NON-EXCLUSIVE)
	logic [31:0] ID_RD_EX;
	logic [31:0] ID_U_TYPE_EX;			// EXECUTE SIGNAL
	logic [31:0] ID_I_TYPE_EX;			// EXECUTE SIGNAL
	logic [31:0] ID_S_TYPE_EX;			// EXECUTE SIGNAL
	logic [31:0] ID_JAL_EX;				// EXECUTE SIGNAL
	logic [31:0] ID_BRANCH_EX;			// EXECUTE SIGNAL
	logic [31:0] ID_JALR_EX;			// EXECUTE SIGNAL
	logic [31:0] ID_PC_EX;				// EXECUTE SIGNAL
	logic [31:0] ID_PC_N_EX;
	logic [1:0] ID_SIZE_EX;
	logic ID_SIGN_EX;

//*************** THE SEQUENTIAL LOGIC ****************//
	// Clear registers on reset, else read inputs
	always_ff @ (posedge CLK)
	begin
		if (RST)
		begin
			ID_PC_SOURCE_EX <= 0;
			ID_ALU_SRCA_EX <= 0;	
			ID_ALU_SRCB_EX <= 0;
			ID_ALU_FUN_EX <= 0;	
			ID_RF_WR_SEL_EX <= 0;
			ID_PC_WRITE_EX <= 0;	
			ID_MEM_WRITE_EX <= 0;
			ID_REG_WRITE_EX <= 0;
			ID_MEM_READ_2_EX <= 0;
			ID_RS1_EX <= 0;
			ID_RS2_EX <= 0;
			ID_RD_EX <= 0;
			ID_U_TYPE_EX <= 0;
			ID_I_TYPE_EX <= 0;
			ID_S_TYPE_EX <= 0;
			ID_JAL_EX <= 0;	
			ID_BRANCH_EX <= 0;
			ID_JALR_EX <= 0;
			ID_PC_EX <= 0;
			ID_PC_N_EX <= 0;
			ID_SIZE_EX <= 0;
			ID_SIGN_EX <= 0;
		end else 
		begin
			ID_PC_SOURCE_EX <= PC_SOURCE_ID;
			ID_ALU_SRCA_EX <= ALU_SRCA_ID; 	
			ID_ALU_SRCB_EX <= ALU_SRCB_ID; 
			ID_ALU_FUN_EX <= ALU_FUN_ID; 	
			ID_RF_WR_SEL_EX <= RF_WR_SEL_ID; 
			ID_PC_WRITE_EX <= PC_WRITE_ID; 	
			ID_MEM_WRITE_EX <= MEM_WRITE_ID; 
			ID_REG_WRITE_EX <= REG_WRITE_ID; 
			ID_MEM_READ_2_EX <= MEM_READ_2_ID; 
			ID_RS1_EX <= RS1_ID; 
			ID_RS2_EX <= RS2_ID; 
			ID_RD_EX <= RD_ID; 
			ID_U_TYPE_EX <= U_TYPE_ID; 
			ID_I_TYPE_EX <= I_TYPE_ID; 
			ID_S_TYPE_EX <= S_TYPE_ID; 
			ID_JAL_EX <= JAL_ID; 	
			ID_BRANCH_EX <= BRANCH_ID; 
			ID_JALR_EX <= JALR_ID; 
			ID_PC_EX <= PC_ID; 
			ID_PC_N_EX <= PC_N_ID; 
			ID_SIZE_EX <= SIZE_ID; 
			ID_SIGN_EX <= SIGN_ID; 
		end
	end

	// Clear outputs on reset, else write outputs
	always_ff @ (posedge CLK)
	begin
		if (RST)
		begin
			PC_SOURCE_EX <= 0;
			ALU_SRCA_EX <= 0;	
			ALU_SRCB_EX <= 0;
			ALU_FUN_EX <= 0;	
			RF_WR_SEL_EX <= 0;
			PC_WRITE_EX <= 0;	
			MEM_WRITE_EX <= 0;
			REG_WRITE_EX <= 0;
			MEM_READ_2_EX <= 0;
			RS1_EX <= 0;
			RS2_EX <= 0;
			RD_EX <= 0;
			U_TYPE_EX <= 0;
			I_TYPE_EX <= 0;
			S_TYPE_EX <= 0;
			JAL_EX <= 0;	
			BRANCH_EX <= 0;
			JALR_EX <= 0;
			PC_EX <= 0;
			PC_N_EX <= 0;
			SIZE_EX <= 0;
			SIGN_EX <= 0;
		end else 
		begin
			PC_SOURCE_EX <= ID_PC_SOURCE_EX;
			ALU_SRCA_EX <= ID_ALU_SRCA_EX; 	
			ALU_SRCB_EX <= ID_ALU_SRCB_EX; 
			ALU_FUN_EX <= ID_ALU_FUN_EX; 	
			RF_WR_SEL_EX <= ID_RF_WR_SEL_EX; 
			PC_WRITE_EX <= ID_PC_WRITE_EX; 	
			MEM_WRITE_EX <= ID_MEM_WRITE_EX; 
			REG_WRITE_EX <= ID_REG_WRITE_EX; 
			MEM_READ_2_EX <= ID_MEM_READ_2_EX; 
			RS1_EX <= ID_RS1_EX; 
			RS2_EX <= ID_RS2_EX; 
			RD_EX <= ID_RD_EX; 
			U_TYPE_EX <= ID_U_TYPE_EX; 
			I_TYPE_EX <= ID_I_TYPE_EX; 
			S_TYPE_EX <= ID_S_TYPE_EX; 
			JAL_EX <= ID_JAL_EX; 	
			BRANCH_EX <= ID_BRANCH_EX; 
			JALR_EX <= ID_JALR_EX; 
			PC_EX <= ID_PC_EX; 
			PC_N_EX <= ID_PC_N_EX; 
			SIZE_EX <= ID_SIZE_EX; 
			SIGN_EX <= ID_SIGN_EX; 
		end
	end





endmodule
