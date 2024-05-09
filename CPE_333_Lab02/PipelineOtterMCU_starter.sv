`timescale 1ns / 1ps




// ! Add Signals Here
typedef struct packed {
    logic [31:0] PC;
    logic [31:0] IR;
    logic [4:0] rs1_addr;
    logic [4:0] rs2_addr;
    logic [4:0] rd_addr;
    logic [31:0] rs1_data;
    logic [31:0] rs2_data;
    logic [31:0] imm;
    logic [3:0] alu_fun;
    logic srcB_sel;
    logic regWrite;
    logic [1:0] rf_sel;
    logic memWrite;
    logic memRead;
} Instr_t;


module OTTER_MCU (
    input CLK,    
    input INTR,       
    input RESET,      
    input [31:0] IOBUS_IN,    
    output [31:0] IOBUS_OUT,    
    output [31:0] IOBUS_ADDR,
    output logic IOBUS_WR
);

    Instr_t instr;
    



// *********************************************************************************
// * Fetch (Instruction Memory) Stage
// *********************************************************************************

// FETCH SIGNALS
	assign next_pc = pc + 4;
	assign jalr_pc = I_immed + A;		// I_immed should come from ID_EX Pipeline Register
	// byte-aligned address. This needs to move to the Decode stage.
	assign branch_pc = pc + {{20{IR[31]}}, IR[7], IR[30:25], IR[11:8], 1'b0};
	// This calculation needs to move to Decode stage
	assign jump_pc = pc + {{12{IR[31]}}, IR[19:12], IR[20], IR[30:21], 1'b0};	


// Program Counter
	ProgCount PC (
		.PC_CLK(CLK),		
		.PC_RST(RESET),	
		.PC_LD(pcWrite),	// from ID_EX pipeline register
		.PC_DIN(pc_value),	// from PCdatasrc
		.PC_COUNT(pc));		// output to memory module



// PC Multiplexor. 4 normal inputs, 2 interrupt inputs.
    Mult6to1 PCdatasrc (
		next_pc, 
		jalr_pc, 
		branch_pc, 
		jump_pc,
		mtvec,
		mepc,
		pc_sel,		// select
		pc_value)	// output 
// Memory module is declared here, but also used in Memory stage. 

// *********************************************************************************
// * Decode (Register File) stage
// *********************************************************************************
    
// Decoder Unit. This unit will be modified to account for pipelining. 
   OTTER_CU_Decoder CU_DECODER(
   		// Inputs
		.CU_OPCODE(opcode),
		.CU_FUNC3(IR[14:12]),
		.CU_FUNC7(IR[31:25]),
		.CU_BR_EQ(br_eq), 
		.CU_BR_LT(br_lt),
		.CU_BR_LTU(bt_ltu),
		// Outputs
		.CU_PCSOURCE(pc_sel),
		.CU_ALU_SRCA(opA_sel),
		.CU_ALU_SRCB(opB_sel),
		.CU_ALU_FUN(alu_fun),
		.CU_RF_WR_SEL(wb_sel),
		.intTaken(intTaken));

		
// BRANCH CONDITION GENERATOR
// 		This should be declared in a separate module. Until then,
	logic br_lt, br_eq, br_ltu;
	always_comb
	begin
		br_lt = 0;
		br_eq = 0;
		br_ltu= 0;
		if($signed(A) < $signed(B)) br_lt = 1;
		if(A == B) br_eq = 1;
		if(A < B) br_ltu = 1;
	end
// IMMED_GEN
// 		As with above, needs to be modulated.
	assign S_immed = {{20{IR[31]}},IR[31:25],IR[11:7]};
	assign I_immed = {{20{IR[31]}},IR[31:20]};
	assign U_immed = {IR[31:12], {12{1'b0}}};

// *********************************************************************************
// * Execute (ALU) Stage
// *********************************************************************************

// ALU Source A Multiplexor
	Mult2to1 ALUAinput(
		A,				// RS1. From reg file.   
		U_immed, 		// From IMMED_GEN.
		opA_sel, 		// From decoder. 
		aluAin);		// To ALU.

// ALU Source B Multiplexor
	Mult4to1 ALUBinput(
		B,				//RS2. From reg file.
		I_immed,		// From IMMED_GEN.
		S_immed,		// From IMMED_GEN. 
		pc,				// Piped from PC. 
		opB_sel,		// From decoder.
		aluBin);		// To ALU.


// RISC-V ALU
   OTTER_ALU ALU(alu_fun, aluAin, aluBin, aluResult); 

// *********************************************************************************
// * Memory (Data Memory) stage 
// *********************************************************************************


// *********************************************************************************
// * Write (Write Back) stage
// *********************************************************************************
    

endmodule
