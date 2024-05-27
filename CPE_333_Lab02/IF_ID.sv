`timescale 1ns / 1ps

module IF_ID(
	input CLK,					// Clock signal
	input RST,					// Reset Signal
	input wire [31:0] DOUT2_IF,		// Instruction
	input wire [31:0] ADDR_IF,			// PC
	input wire [31:0] N_ADDR_IF,		// PC + 4
	output logic [31:0] IR_ID,
   	output logic [31:0] ADDR_ID,	
	output logic [31:0] N_ADDR_ID
	);

	// Clear registers on reset, else, save data_IF
	always_ff @ (posedge CLK)
	begin
		if(RST) 
		begin
			// Clear outputs
			IR_ID <= 0;
			ADDR_ID <= 0;
			N_ADDR_ID <= 0;
		end else
		begin
		    // Read data in 
			IR_ID <= DOUT2_IF;
			ADDR_ID = ADDR_IF;
			N_ADDR_ID = N_ADDR_IF;
		end   
	end


endmodule
