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


	//****** REGISTER FILE ******//
	logic [31:0] rs1_ID, rs2_ID;

	//****** BRANCH COND. GEN, IMMEDIATES *******//
	logic [31:0] U_immed_ID;
	logic [31:0] I_immed_ID;
	logic [31:0] S_immed_ID;
	logic [31:0] B_immed_ID;
	logic [31:0] J_immed_ID;
	logic [31:0] jal_ID;
	logic [31:0] branch_ID;
	logic [31:0] jalr_ID;
	
	//****** PASSTHROUGHS *******//
	logic [31:0] ir_ID, pc_ID, next_pc_ID;


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
	
	//****** INSTRUCTION STUFF ********//
	logic [6:0] opcode;
	logic [3:0] func3;
	logic [5:0] func7;
	//logic [10:0] func12;	//ir[31:20]	
	logic [4:0] rs1_addr, rs2 addr, rd_addr;	
	logic [1:0] size_EX;
	logic sign_EX;

	//****** BRANCH COND. GEN, IMMEDIATES *******//
	logic [31:0] U_immed_EX;
	logic [31:0] I_immed_EX;
	logic [31:0] S_immed_EX;
	logic [31:0] B_immed_EX;
	logic [31:0] J_immed_EX;
	logic [31:0] jal_EX;
	logic [31:0] branch_EX;
	logic [31:0] jalr_EX;

	//****** INSTRUCTION STUFF ********//
	logic [31:0] rs1_EX, rs2_EX;

   	//****** JUMP/BRANCH ******//
	logic[31:0] jal_EX, branch_EX, jalr_EX;
   	
	//****** ALU ******//
	logic [31:0] alu_result_EX;

	//****** PASSTHROUGHS *******//
	logic [31:0] ir_EX, pc_EX, next_pc_EX;


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
	logic [4:0] rd_addr_MEM;

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
	assign IOBUS_OUT = B;



// *********************************************************************************
// * Interrupt/Reset Logic
// *********************************************************************************

// CSR Registers and interrupt logic
	CSR CSRs(
		.clk(CLK),
		.rst(RESET),
		.intTaken(intTaken),
		.addr(ir[31:20]),
		.next_pc(pc),
		.wd(alu_result),
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
		.MEM_ADDR2(alu_result),
		.MEM_DIN2(B),
		.MEM_WRITE2(memWrite),
		.MEM_READ1(memRead1),
		.MEM_READ2(memRead2),
		.ERR(), 				// ??
		.MEM_DOUT1(ir),
		.MEM_DOUT2(mem_data),
		.IO_IN(IOBUS_IN),
		.IO_WR(IOBUS_WR),
		.MEM_SIZE(ir[13:12]), 	// ??
		.MEMSIGN(ir[14]));		// ??

	// IF_ID Pipeline Register
	IF_ID if_id(	
		.CLK(CLK),
		.RST(RESET),
		// Inputs
		.DOUT2_IF(),
		.ADDR_IF(),
		.N_ADDR_IF(),
		// Outputs
		.IR_ID(),
		.ADDR_ID(),
		.N_ADDR_ID());


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
		.CU_FUNC3(ir[14:12]),
		.CU_FUNC7(ir[31:25]),
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
		ir[19:15],
		ir[24:20],
		ir[11:7],
		rfIn,
		regWrite,
		A,
		B,
		CLK);

// ID_EX Pipeline Register
	ID_EX id_ex(
		.CLK(),
		.RST(),
		// Inputs
		.PC_SOURCE_ID(),
		.ALU_SRCA_ID(),
		.ALU_SRCB_ID(),
		.ALU_FUN_ID(),
		.RF_WR_SEL_ID(),
		.PC_WRITE_ID(),
		.MEM_WRITE_ID(),
		.REG_WRITE_ID(),
		.MEM_READ_2_ID(),
		.RS1_ID(),
		.RS2_ID(),
		.RD_ID(),
		.U_TYPE_ID(),
		.I_TYPE_ID(),
		.S_TYPE_ID(),
		.JAL_ID(),
		.BRANCH_ID(),
		.JALR_ID(),
		.PC_ID(),
		.PC_N_ID(),
		.SIZE_ID(),
		.SIGN_ID(),
		// Outputs	
		.PC_SOURCE_EX(),
		.ALU_SRCA_EX(),
		.ALU_SRCB_EX(),
		.ALU_FUN_EX(),
		.RF_WR_SEL_EX(),
		.PC_WRITE_EX(),
		.MEM_WRITE_EX(),
		.REG_WRITE_EX(),
		.MEM_READ_2_EX(),
		.RS1_EX(),
		.RS2_EX(),
		.RD_EX(),
		.U_TYPE_EX(),
		.I_TYPE_EX(),
		.S_TYPE_EX(),
		.JAL_EX(),
		.BRANCH_EX(),
		.JALR_EX(),
		.PC_EX(),
		.PC_N_EX(),
		.SIZE_EX(),
		.SIGN_EX());

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
	   alu_result); 
// EX_MEM
	EX_MEM ex_mem(
		.CLK(),
		.RST(),
		// Input
		.SIZE_EX(),
		.SIGN_EX(),
		.RF_WR_SEL_EX(),
		.REG_WRITE_EX(),
		.MEM_READ_2_EX(),
		.MEM_WRITE_EX(),
		.ALU_RESULT_EX(),
		.RS2_EX(),
		.RD_EX(),
		.PC_N_EX(),
		// Output
		.SIZE_MEM(),
		.SIGN_EX(),
		.RF_WR_SEL_EX(),
		.REG_WRITE_EX(),
		.MEM_READ_2_EX(),
		.MEM_WRITE_EX(),
		.ALU_RESULT_EX(),
		.RS2_EX(),
		.RD_EX(),
		.PC_N_EX()
		);
// *********************************************************************************
// * Memory (Data Memory) stage 
// *********************************************************************************

// MEM_WB Pipeline Register
	MEM_WB mem_wb(
		.CLK(),
		.RST(),
		// Inputs
		.DOUT_2_MEM(),
		.ALU_RESULT_MEM(),
		.PC_N_MEM(),
		.REG_WRITE_MEM(),
		.RF_WR_SEL_MEM(),
		.RD_MEM(),
		// Output
		.DOUT_2_WB(),
		.ALU_RESULT_WB(),
		.PC_N_WB(),
		.REG_WRITE_WB(),
		.RF_WR_SEL_WB(),
		.RD_WB()
		);



// *********************************************************************************
// * Write (Write Back) stage
// *********************************************************************************
    
// Register Input Multiplexor
	Mutlt4to1 regWriteback(
		next_pc,
		csr_reg,
		mem_data,
		alu_result,
		wb_sel,
		rfIn);



endmodule
