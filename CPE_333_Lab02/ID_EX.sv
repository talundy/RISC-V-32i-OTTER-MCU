`timescale 1ns / 1ps

module ID_EX(
//*************** INPUT SIGNALS ****************//
	// MCU Signals 
	input CLK,
	input RST,

	// Decoder Control Signals
	input wire [1:0] PC_SOURCE_ID, 		// EXECUTE SIGNAL
	input wire ALU_SRCA_ID,				// EXECUTE SIGNAL
	input wire [1:0] ALU_SRCB_ID,			// EXECUTE SIGNAL
	input wire [3:0] ALU_FUN_ID,			// EXECUTE SIGNAL
	input wire [1:0] RF_WR_SEL_ID,
	//..// Read/Write Signals
	input wire PC_WRITE_ID,				// EXECUTE SIGNAL
	input wire MEM_WRITE_ID,
	input wire REG_WRITE_ID,
	input wire MEM_READ_2_ID,
	
	// Register Signals
	input wire [31:0] RS1_ID,				// EXECUTE SIGNAL
	input wire [31:0] RS2_ID,				// EXECUTE SIGNAL (NON-EXCLUSIVE)
	input wire [31:0] RD_ID,
	
	// Immediate Signals
	input wire [31:0] U_TYPE_ID,			// EXECUTE SIGNAL
	input wire [31:0] I_TYPE_ID,			// EXECUTE SIGNAL
	input wire [31:0] S_TYPE_ID,			// EXECUTE SIGNAL

	// Branch Address Signals
	input wire [31:0] JAL_ID,				// EXECUTE SIGNAL
	input wire [31:0] BRANCH_ID,			// EXECUTE SIGNAL
	input wire [31:0] JALR_ID,				// EXECUTE SIGNAL
	
	// PC Signals
	input wire [31:0] PC_ID,				// EXECUTE SIGNAL
	input wire [31:0] PC_N_ID,

	// Memory Signals
	input wire [1:0] SIZE_ID,
	input wire SIGN_ID,

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

//*************** THE SEQUENTIAL LOGIC ****************//
	// Clear registers on reset, else read inputs
	always_ff @ (posedge CLK)
	begin
		if (RST)
		begin
			// Clear outputs on reset
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
			// Read inputs
			PC_SOURCE_EX <= PC_SOURCE_ID;
			ALU_SRCA_EX <= ALU_SRCA_ID; 	
			ALU_SRCB_EX <= ALU_SRCB_ID; 
			ALU_FUN_EX <= ALU_FUN_ID; 	
			RF_WR_SEL_EX <= RF_WR_SEL_ID; 
			PC_WRITE_EX <= PC_WRITE_ID; 	
			MEM_WRITE_EX <= MEM_WRITE_ID; 
			REG_WRITE_EX <= REG_WRITE_ID; 
			MEM_READ_2_EX <= MEM_READ_2_ID; 
			RS1_EX <= RS1_ID; 
			RS2_EX <= RS2_ID; 
			RD_EX <= RD_ID; 
			U_TYPE_EX <= U_TYPE_ID; 
			I_TYPE_EX <= I_TYPE_ID; 
			S_TYPE_EX <= S_TYPE_ID; 
			JAL_EX <= JAL_ID; 	
			BRANCH_EX <= BRANCH_ID; 
			JALR_EX <= JALR_ID; 
			PC_EX <= PC_ID; 
			PC_N_EX <= PC_N_ID; 
			SIZE_EX <= SIZE_ID; 
			SIGN_EX <= SIGN_ID; 
		end
	end

endmodule
