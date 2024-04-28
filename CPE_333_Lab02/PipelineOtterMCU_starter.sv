// starter code
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
    
    

// *********************************************************************************
// * Decode (Register File) stage
// *********************************************************************************
    

    


// *********************************************************************************
// * Execute (ALU) Stage
// *********************************************************************************

    

// *********************************************************************************
// * Memory (Data Memory) stage 
// *********************************************************************************


// *********************************************************************************
// * Write (Write Back) stage
// *********************************************************************************
    

endmodule
