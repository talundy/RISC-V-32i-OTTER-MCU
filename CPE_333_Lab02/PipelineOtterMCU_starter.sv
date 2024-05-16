`timescale 1ns / 1ps




// ! Add Signals Here
typedef struct packed {

// Fetch Stage Signals ///////////////////////////////////////
	logic [31:0] ir_IF;
	logic [31:0] pc_IF;
	logic [31:0] next_pc_IF;

// Decode Stage Signals ///////////////////////////////////////
   	
	//****** DECODER ******//
	// CONTROL OUTPUTS
	logic [3:0] alu_fun_ID;
	logic alu_srcA_ID;
	logic [1:0] alu_srcB_ID;
	logic [1:0] rf_wr_sel_ID;
	logic [3:0] pcSource_ID;
		// READ/WRITE
	logic pcWrite_ID, regWrite_ID, memWrite_ID, memRead1_ID, memRead2_ID;
	// CONTROL INPUTS
	logic br_lt, br_eq, br_ltu; // No ID postfix as these don't progress through pipeine

	//****** INSTRUCTION STUFF ********//
	logic [6:0] opcode;
	logic [3:0] func3;
	logic [5:0] func7;
	//logic [10:0] func12;	//ir[31:20]	
	logic [4:0] rs1_addr, rs2_addr, rd_addr_ID;	
	logic [1:0] size_ID;
	logic sign_ID;

	//****** REGISTER FILE ******//
	logic [31:0] rs1_ID, rs2_ID;

	//****** BRANCH COND. GEN, IMMEDIATES *******//
	logic [31:0] U_immed_ID;
	logic [31:0] I_immed_ID;
	logic [31:0] S_immed_ID;
	logic [31:0] B_immed;
	logic [31:0] J_immed;
	logic [31:0] jal_ID;
	logic [31:0] branch_ID;
	logic [31:0] jalr_ID;
	
	//****** PASSTHROUGHS *******//
	logic [31:0] pc_ID, next_pc_ID;
	// logic [31:0] ir_ID;


// Execute Stage Signals ///////////////////////////////////////
   	//****** DECODER ******//
	// CONTROL OUTPUTS
	logic [3:0] alu_fun_EX;
	logic alu_srcA_EX;
	logic [1:0] alu_srcB_EX;
	logic [1:0] rf_wr_sel_EX;
	logic [3:0] pcSource_EX;
		// READ/WRITE
	logic pcWrite_EX, regWrite_EX, memWrite_EX, memRead1_EX, memRead2_EX;
	


	//****** BRANCH COND. GEN, IMMEDIATES *******//
	logic [31:0] U_immed_EX;
	logic [31:0] I_immed_EX;
	logic [31:0] S_immed_EX;
	logic [31:0] B_immed_EX;
	logic [31:0] J_immed_EX;
	// jump/branch
	logic [31:0] jal_EX;
	logic [31:0] branch_EX;
	logic [31:0] jalr_EX;

	//****** INSTRUCTION STUFF ********//
	logic [31:0] rs1_EX, rs2_EX;
   	
	//****** ALU ******//
	logic [31:0] alu_result_EX;

	//****** PASSTHROUGHS *******//
	logic [31:0] ir_EX, pc_EX, next_pc_EX;
	logic [4:0] rd_addr_EX;
	logic [1:0] size_EX;
	logic sign_EX;


// Memory Stage Signals ///////////////////////////////////////
  	logic [31:0] alu_result_MEM;
	logic [31:0] next_pc_MEM;   
	logic [31:0] rs2_MEM;
	logic [4:0] rd_addr_MEM;

   	//****** CONTROL ******//
	logic regWrite_MEM;
	logic [1:0] rf_wr_sel_MEM;
	logic memRead2_MEM;
	logic memWrite_MEM;
	logic [1:0] size_MEM;
	logic sign_MEM;

// Writeback Stage Signals ///////////////////////////////////////
	logic [31:0] dout2;	
	logic [31:0] alu_result_WB;
	logic [31:0] next_pc_WB;
	logic regWrite_WB;
	logic [1:0] rf_wr_sel_WB;
	logic [4:0] rd_addr_WB;

// Interrupt/Reset/Ind. Signals ///////////////////////////////////////
	logic intTaken;

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
// * MMIO Stuff
// *********************************************************************************
	assign IOBUS_ADDR = alu_result;
	assign IOBUS_OUT = rs2_ID;



// *********************************************************************************
// * Interrupt/Reset Logic
// *********************************************************************************

// CSR Registers and interrupt logic
	CSR CSRs(
		.clk(CLK),
		.rst(RESET),
		.intTaken(intTaken),
		.addr(ir_ID[31:20]),
		.next_pc(pc),
		.wd(alu_result),
		.wr_en(csrWrite),
		.rd(csr_reg),
		.mepc(mepc),
		.mtvec(mtvec),
		.mie(mie));
   
    
	//always_ff @ (posedge CLK)
	//begin
	//	if(INTR && mie)
	//		prev_INT = 1'b1;
	//	if(intCLK || RESET)
	//		prev_INT = 1'b0;
	//end



// *********************************************************************************
// * Fetch (Instruction Memory) Stage
// *********************************************************************************

// INTERNAL SIGNALS
	assign next_pc_IF = pc + 4; //byte-aligned
	logic pc_value;			// pc mux to pc

// Program Counter
	ProgCount PC (
		.PC_CLK(CLK),		
		.PC_RST(RESET),	
		.PC_LD(pcWrite_EX),	// from ID_EX pipeline register
		.PC_DIN(pc_value),	// from PCdatasrc
		.PC_COUNT(pc_IF));		// output to memory module



// PC Multiplexor. 4 normal inputs, 2 interrupt inputs.
    Mult6to1 PCdatasrc (
		next_pc_IF, 
		jalr_pc_EX, 
		branch_pc_EX, 
		jump_pc_EX,
		mtvec,		// interrupt stuff
		mepc,		// interrupt stuff
		pcSource_EX,		// select
		pc_value);	// output 
		
// INSTRUCTION/DATA MEMORY
// Memory module is declared here, but also used in Memory stage. 
// Instruction Memory is port 1, Data Memory is port 2
	OTTER_mem_byte #(14) memory(
		.MEM_CLK(CLK),
		.MEM_ADDR1(pc_IF),
		.MEM_ADDR2(alu_result),
		.MEM_DIN2(B),
		.MEM_WRITE2(memWrite),
		.MEM_READ1(memRead1),
		.MEM_READ2(memRead2),
		.ERR(), 				// ??
		.MEM_DOUT1(ir_IF),
		.MEM_DOUT2(dout2_MEM),
		.IO_IN(IOBUS_IN),
		.IO_WR(IOBUS_WR),
		.MEM_SIZE(ir[13:12]), 	// ??
		.MEMSIGN(ir[14]));		// ??

	// IF_ID Pipeline Register
	IF_ID if_id(	
		.CLK(CLK),
		.RST(RESET),
		// Inputs
		.DOUT2_IF(ir_IF),
		.ADDR_IF(pc_IF),
		.N_ADDR_IF(next_pc_IF),
		// Outputs
		.IR_ID(ir_ID),
		.ADDR_ID(pc_ID),
		.N_ADDR_ID(next_pc_ID));


// *********************************************************************************
// * Decode (Register File) stage
// *********************************************************************************
   wire [31:0] ir_ID;
   
// Decode Stage Connections
	logic br_lt, br_eq, br_ltu;
	logic rfIn;
	assign opcode = ir_ID[6:0];
	assign func3 = ir_ID[14:12];
	assign func7 = ir_ID[31:25];
	//assign func12 = ir[31:20];
	assign rs1_addr = ir_ID[19:15];
	assign rs2_addr = ir_ID[24:20];
	assign rd_addr_ID = ir_ID[11:7];
   	assign size_ID = ir_ID[13:12];
	assign sign_ID = ir_ID[14];


// Decoder Unit. This unit will be modified to account for pipelining. 
   OTTER_PL_Decoder CU_DECODER(
   		// Inputs
		.CU_OPCODE(opcode),
		.CU_FUNC3(func3),
		.CU_FUNC7(func7),
		.CU_BR_EQ(br_eq), 
		.CU_BR_LT(br_lt),
		.CU_BR_LTU(bt_ltu),
		.intTaken(intTaken),
		// Outputs
		.CU_PCSOURCE(pc_source_ID),
		.CU_ALU_SRCA(alu_srcA_ID),
		.CU_ALU_SRCB(alu_srcB_ID),
		.CU_ALU_FUN(alu_fun_ID),
		.CU_RF_WR_SEL(rf_wr_sel_ID),
		.PC_WRITE(pcWrite_ID),
		.REG_WRITE(regWrite_ID),
		.MEM_WRITE(memWrite_ID),
		.MEM_READ_1(memRead1_ID),		// Instruction Memory
		.MEM_READ_2(memRead2_ID));		// Data Memory

// Branch Address Generator
	BrAddrGen BRANCH_ADDR_GEN(
		J_immed,
		B_immed,
		I_immed_ID,
		pc_ID,
		rs1_ID,
		jalr_ID,
		branch_ID,
		jump_ID);

// Branch Condition Generator
	brCondGen BRANCH_COND_GEN(
		rs1_ID,
		rs2_ID,
		br_eq,
		br_lt,
		br_ltu);

// Immediate Generator
	ImmedGen IMMED_GEN(
		ir,
		U_immed_ID,
		I_immed_ID,
		S_immed_ID,
		J_immed,
		B_immed);

// Register File
	OTTER_registerFile RF(
		rs1_addr,
		rs2_addr,
		rd_addr_WB,
		rfIn,
		regWrite_WB,
		rs1_ID,
		rs2_ID,
		CLK);

// ID_EX Pipeline Register
	ID_EX id_ex(
		.CLK(CLK),
		.RST(RESET),
		// Inputs
		.PC_SOURCE_ID(pcSource_ID),
		.ALU_SRCA_ID(alu_srcA_ID),
		.ALU_SRCB_ID(alu_srcB_ID),
		.ALU_FUN_ID(alu_fun_ID),
		.RF_WR_SEL_ID(rw_wr_sel_ID),
		.PC_WRITE_ID(pcWrite_ID),
		.MEM_WRITE_ID(memWrite_ID),
		.REG_WRITE_ID(regWrite_ID),
		.MEM_READ_2_ID(memRead2_ID), //memRead1 tied high for now
		.RS1_ID(rs1_ID),
		.RS2_ID(rs2_ID),
		.RD_ID(rd_addr_ID),
		.U_TYPE_ID(U_immed_ID),
		.I_TYPE_ID(I_immed_ID),
		.S_TYPE_ID(S_immed_ID),
		.JAL_ID(jal_ID),
		.BRANCH_ID(branch_ID),
		.JALR_ID(jalr_ID),
		.PC_ID(pc_ID),
		.PC_N_ID(next_pc_ID),
		.SIZE_ID(size_ID),
		.SIGN_ID(sign_ID),
		// Outputs	
		.PC_SOURCE_EX(pcSource_EX),
		.ALU_SRCA_EX(alu_srcA_EX),
		.ALU_SRCB_EX(alu_srcB_EX),
		.ALU_FUN_EX(alu_fun_EX),
		.RF_WR_SEL_EX(rf_wr_sel_EX),
		.PC_WRITE_EX(pcWrite_EX),
		.MEM_WRITE_EX(memWrite_EX),
		.REG_WRITE_EX(regWrite_EX),
		.MEM_READ_2_EX(memRead1_EX), //memRead1 tied high for now
		.RS1_EX(rs1_EX),
		.RS2_EX(rs2_EX),
		.RD_EX(rd_addr_EX),
		.U_TYPE_EX(U_immed_EX),
		.I_TYPE_EX(I_immed_EX),
		.S_TYPE_EX(S_immed_EX),
		.JAL_EX(jal_EX),
		.BRANCH_EX(branch_EX),
		.JALR_EX(jalr_EX),
		.PC_EX(pc_EX),
		.PC_N_EX(next_pc_EX),
		.SIZE_EX(size_EX),
		.SIGN_EX(sign_EX));

// *********************************************************************************
// * Execute (ALU) Stage
// *********************************************************************************
	// Execute stage signals
	logic aluAin, aluBin;

// ALU Source A Multiplexor
	Mult2to1 ALUAinput(
		rs1_EX,				// RS1. From reg file.   
		U_immed_EX, 		// From IMMED_GEN.
		alu_srcA_EX, 		// From decoder. 
		aluAin);		// To ALU.

// ALU Source B Multiplexor
	Mult4to1 ALUBinput(
		rs2_EX,				//RS2. From reg file.
		I_immed_EX,		// From IMMED_GEN.
		S_immed_EX,		// From IMMED_GEN. 
		pc_EX,				// Piped from PC. 
		alu_srcB_EX,		// From decoder.
		aluBin);		// To ALU.


// RISC-V ALU
   OTTER_ALU ALU(
	   alu_fun_EX, 
	   aluAin, 
	   aluBin, 
	   alu_result_EX); 

// EX_MEM PIPELINE REGISTER
	EX_MEM ex_mem(
		.CLK(CLK),
		.RST(RESET),
		// Input
		.SIZE_EX(size_EX),
		.SIGN_EX(sign_EX),
		.RF_WR_SEL_EX(rf_wr_sel_EX),
		.REG_WRITE_EX(regWrite_EX),
		.MEM_READ_2_EX(memRead2_EX), //memRead1 tied high for now
		.MEM_WRITE_EX(memWrite_EX),
		.ALU_RESULT_EX(alu_result_EX),
		.RS2_EX(rs2_EX),
		.RD_EX(rd_addr_EX),
		.PC_N_EX(next_pc_EX),
		// Output
		.SIZE_MEM(size_MEM),
		.SIGN_EX(sign_MEM),
		.RF_WR_SEL_EX(rf_wr_sel_MEM),
		.REG_WRITE_EX(regWrite_MEM),
		.MEM_READ_2_EX(memRead2_MEM),
		.MEM_WRITE_EX(memWrite_MEM),
		.ALU_RESULT_EX(alu_result_MEM),
		.RS2_EX(rs2_MEM),
		.RD_EX(rd_addr_MEM),
		.PC_N_EX(next_pc_MEM)
		);
// *********************************************************************************
// * Memory (Data Memory) stage 
// *********************************************************************************

// MEM_WB Pipeline Register
	MEM_WB mem_wb(
		.CLK(CLK),
		.RST(RESET),
		// Inputs
		.DOUT_2_MEM(dout2_MEM),
		.ALU_RESULT_MEM(),
		.PC_N_MEM(next_pc_MEM),
		.REG_WRITE_MEM(regWrite_MEM),
		.RF_WR_SEL_MEM(rf_wr_sel_MEM),
		.RD_MEM(rd_addr_MEM),
		// Output
		.DOUT_2_WB(dout2_WB),
		.ALU_RESULT_WB(alu_result_WB),
		.PC_N_WB(next_pc_WB),
		.REG_WRITE_WB(regWrite_WB),
		.RF_WR_SEL_WB(rf_wr_sel_WB),
		.RD_WB(rd_addr_WB)
		);



// *********************************************************************************
// * Write (Write Back) stage
// *********************************************************************************
    
// Register Input Multiplexor
	Mult4to1 regWriteback(
		next_pc_WB,
		csr_reg,
		dout2_WB,
		alu_result_WB,
		rf_wr_sel_WB,
		rfIn);



endmodule
