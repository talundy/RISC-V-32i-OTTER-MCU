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
// * Interrupt/Reset Logic
// *********************************************************************************

// CSR Registers and interrupt logic
	CSR CSRs(
		.clk(CLK),
		.rst(RESET),
		.intTaken(intTaken),
		.addr(IR[31:20]),
		.next_pc(pc),
		.wd(aluResult),
		.wr_en(csrWrite),
		.rd(csr_reg),
		.mepc(mepc),
		.mtvec(mtvec),
		.mie(mie));
   
	always_ff @ (posedge CLK)
	begin
		if(INTR && mie)
			prev_INT = 1'b1;
		if(intCLK || RESET)
			prev_INT = 1'b0;
	end


// *********************************************************************************
// * Fetch (Instruction Memory) Stage
// *********************************************************************************

// FETCH SIGNALS
	assign next_pc = pc + 4; //byte-aligned


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
		
// INSTRUCTION/DATA MEMORY
// Memory module is declared here, but also used in Memory stage. 
// Instruction Memory is port 1, Data Memory is port 2
	OTTER_mem_byte #(14) memory(
		.MEM_CLK(CLK),
		.MEM_ADDR1(pc),
		.MEM_ADDR2(aluResult),
		.MEM_DIN2(B),
		.MEM_WRITE2(memWrite),
		.MEM_READ1(memRead1),
		.MEM_READ2(memRead2),
		.ERR(), 				// ??
		.MEM_DOUT1(IR),
		.MEM_DOUT2(mem_data),
		.IO_IN(IOBUS_IN),
		.IO_WR(IOBUS_WR),
		.MEM_SIZE(IR[13:12]), 	// ??
		.MEMSIGN(IR[14]));		// ??

// *********************************************************************************
// * Decode (Register File) stage
// *********************************************************************************
   
// Decode Stage Connections
	logic br_lt, br_eq, br_ltu;
	wire [31:0], U_immed, I_immed, S_immed, J_immed, B_immed;


// Decoder Unit. This unit will be modified to account for pipelining. 
   OTTER_PL_Decoder CU_DECODER(
   		// Inputs
		.CU_OPCODE(opcode),
		.CU_FUNC3(IR[14:12]),
		.CU_FUNC7(IR[31:25]),
		.CU_BR_EQ(br_eq), 
		.CU_BR_LT(br_lt),
		.CU_BR_LTU(bt_ltu),
		.intTaken(intTaken),
		// Outputs
		.CU_PCSOURCE(pc_sel),
		.CU_ALU_SRCA(opA_sel),
		.CU_ALU_SRCB(opB_sel),
		.CU_ALU_FUN(alu_fun),
		.CU_RF_WR_SEL(wb_sel),
		.PC_WRITE(),
		.REG_WRITE(),
		.MEM_WRITE(),
		.MEM_READ_1(),		// Instruction Memory
		.MEM_READ_2());		// Data Memory

// Branch Address Generator
	BrAddrGen BRANCH_ADDR_GEN(
		J_immed,
		B_immed,
		I_immed,
		pc,
		A,
		jalr_pc,
		branch_pc,
		jump_pc);

// Branch Condition Generator
	brCondGen BRANCH_COND_GEN(
		A,
		B,
		br_eq,
		br_lt,
		br_ltu);

// Immediate Generator
	ImmedGen IMMED_GEN(
		IR,
		U_immed,
		I_immed,
		S_immed,
		J_immed,
		B_immed);

// Register File
	OTTER_registerFile RF(
		IR[19:15],
		IR[24:20],
		IR[11:7],
		rfIn,
		regWrite,
		A,
		B,
		CLK);
		
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
   OTTER_ALU ALU(
	   alu_fun, 
	   aluAin, 
	   aluBin, 
	   aluResult); 

// *********************************************************************************
// * Memory (Data Memory) stage 
// *********************************************************************************


// *********************************************************************************
// * Write (Write Back) stage
// *********************************************************************************
    
// Register Input Multiplexor
	Mutlt4to1 regWriteback(
		next_pc,
		csr_reg,
		mem_data,
		aluResult,
		wb_sel,
		rfIn);

// *********************************************************************************
// * MMIO Stuff
// *********************************************************************************
	assign IOBUS_ADDR = aluResult;
	assign IOBUS_OUT = B;


endmodule
