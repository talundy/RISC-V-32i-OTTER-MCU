`timescale 1ns / 1ps







module OTTER_MCU (
    input CLK,    
    input INTR,       
    input RESET,      
    input [31:0] IOBUS_IN,    
    output [31:0] IOBUS_OUT,    
    output [31:0] IOBUS_ADDR,
    output logic IOBUS_WR
);


// *********************************************************************************
// * MMIO Stuff
// *********************************************************************************
	wire [31:0] rs2_ID;
	assign IOBUS_ADDR = alu_result;
	assign IOBUS_OUT = rs2_ID;



// *********************************************************************************
// * Interrupt/Reset Logic
// *********************************************************************************
    wire [31:0] ir_ID;


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
    wire [31:0] pc_IF;
   	wire [31:0] ir_IF;
    wire [31:0] pc_ID, next_pc_ID;
	wire [31:0] dout2_MEM;
	wire [31:0] next_pc_IF;
	
	assign next_pc_IF = pc_IF + 4; //byte-aligned
	
	wire [31:0] pc_value;			// pc mux to pc

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
		jalr_EX, 
		branch_EX, 
		jal_EX,
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
		.MEM_ADDR2(alu_result_MEM),
		.MEM_DIN2(rs2_MEM),
		.MEM_WRITE2(memWrite_MEM),
		.MEM_READ1(memRead1),
		.MEM_READ2(memRead2_MEM),
		.ERR(), 				// ??
		.MEM_DOUT1(ir_IF),
		.MEM_DOUT2(dout2_MEM),
		.IO_IN(IOBUS_IN),
		.IO_WR(IOBUS_WR),
		.MEM_SIZE(size_MEM), 	// ??
		.MEM_SIGN(sign_MEM));		// ??

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
 // Decode Stage Signals ///////////////////////////////////////
	//****** DECODER ******//
	// CONTROL OUTPUTS
	wire [3:0] alu_fun_ID;
	wire alu_srcA_ID;
	wire [1:0] alu_srcB_ID;
	wire [1:0] rf_wr_sel_ID;
	wire [3:0] pcSource_ID;
		// READ/WRITE
	wire pcWrite_ID, regWrite_ID, memWrite_ID, memRead1_ID, memRead2_ID;
	// CONTROL INPUTS
	wire br_lt, br_eq, br_ltu; // No ID postfix as these don't progress through pipeine


	//****** REGISTER FILE ******//
	wire [31:0] rs1_ID;

	//****** BRANCH COND. GEN, IMMEDIATES *******//
	wire [31:0] U_immed_ID;
	wire [31:0] I_immed_ID;
	wire [31:0] S_immed_ID;
	wire [31:0] B_immed;
	wire [31:0] J_immed;
	wire [31:0] jal_ID;
	wire [31:0] branch_ID;
	wire [31:0] jalr_ID;
	
	//****** PASSTHROUGHS *******//
	//****** INSTRUCTION STUFF ********//
	wire [6:0] opcode;
	wire [3:0] func3;
	wire [5:0] func7;
	//logic [10:0] func12;	//ir[31:20]	
	wire [4:0] rs1_addr, rs2_addr, rd_addr_ID;	
	wire [1:0] size_ID;
	wire sign_ID; 
	
	wire [31:0] ir_EX, pc_EX, next_pc_EX;

// Decode Stage Connections
	wire rfIn;
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
		.CU_BR_LTU(br_ltu),
		.RST(RESET),
		.intTaken(intTaken),
		// Outputs
		.CU_PCSOURCE(pcSource_ID),
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
		jal_ID);

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
		.MEM_READ_2_EX(memRead2_EX), //memRead1 tied high for now
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
	// Execute Stage Signals ///////////////////////////////////////
   	//****** DECODER ******//
	// CONTROL OUTPUTS
	wire [3:0] alu_fun_EX;
	wire alu_srcA_EX;
	wire [1:0] alu_srcB_EX;
	wire [1:0] rf_wr_sel_EX;
	wire [3:0] pcSource_EX;
		// READ/WRITE
	wire pcWrite_EX, regWrite_EX, memWrite_EX, memRead1_EX, memRead2_EX;
	


	//****** BRANCH COND. GEN, IMMEDIATES *******//
	wire [31:0] U_immed_EX;
	wire [31:0] I_immed_EX;
	wire [31:0] S_immed_EX;
	wire [31:0] B_immed_EX;
	wire [31:0] J_immed_EX;
	// jump/branch
	wire [31:0] jal_EX;
	wire [31:0] branch_EX;
	wire [31:0] jalr_EX;

	//****** INSTRUCTION STUFF ********//
	wire [31:0] rs1_EX, rs2_EX;
   	
	wire [4:0] rd_addr_EX;
	wire [1:0] size_EX;
	wire sign_EX;
	wire aluAin, aluBin;
	wire [31:0] alu_result_EX;

	//****** PASSTHROUGHS *******//

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
		.SIGN_MEM(sign_MEM),
		.RF_WR_SEL_MEM(rf_wr_sel_MEM),
		.REG_WRITE_MEM(regWrite_MEM),
		.MEM_READ_2_MEM(memRead2_MEM),
		.MEM_WRITE_MEM(memWrite_MEM),
		.ALU_RESULT_MEM(alu_result_MEM),
		.RS2_MEM(rs2_MEM),
		.RD_MEM(rd_addr_MEM),
		.PC_N_MEM(next_pc_MEM)
		);
// *********************************************************************************
// * Memory (Data Memory) stage 
// *********************************************************************************
// Memory Stage Signals ///////////////////////////////////////
  	wire [31:0] alu_result_MEM;
	wire [31:0] next_pc_MEM;   
	wire [31:0] rs2_MEM;
	wire [4:0] rd_addr_MEM;

   	//****** CONTROL ******//
	wire regWrite_MEM;
	wire [1:0] rf_wr_sel_MEM;
	wire memRead2_MEM;
	wire memWrite_MEM;
	wire [1:0] size_MEM;
	wire sign_MEM;


// MEM_WB Pipeline Register
	MEM_WB mem_wb(
		.CLK(CLK),
		.RST(RESET),
		// Inputs
		.DOUT_2_MEM(dout2_MEM),
		.ALU_RESULT_MEM(alu_result_MEM),
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
 // Writeback Stage Signals ///////////////////////////////////////
	wire [31:0] dout2;	
	wire [31:0] alu_result_WB;
	wire [31:0] next_pc_WB;
	wire regWrite_WB;
	wire [1:0] rf_wr_sel_WB;
	wire [4:0] rd_addr_WB;

   
// Register Input Multiplexor
	Mult4to1 regWriteback(
		next_pc_WB,
		csr_reg,
		dout2_WB,
		alu_result_WB,
		rf_wr_sel_WB,
		rfIn);



endmodule
