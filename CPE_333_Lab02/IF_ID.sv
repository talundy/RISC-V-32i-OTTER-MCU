`timescale 1ns / 1ps

module IF_ID(
	input logic CLK,					// Clock signal
	input logic RST,					// Reset Signal
	input logic [31:0] DOUT2_IF,		// Instruction
	input logic [31:0] ADDR_IF,			// PC
	input logic [31:0] N_ADDR_IF,		// PC + 4
	output logic [31:0] IR_ID,
   	output logic [31:0] ADDR_ID,	
	output logic [31:0] N_ADDR_ID
	);

	logic [31:0] IF_DOUT2_ID, IF_ADDR_ID, IF_N_ADDR_ID;

	// Clear registers on reset, else, save data_IF
	always_ff @ (posedge CLK)
	begin
		if(RST) 
		begin
			IF_DOUT2_ID <= 0;
			IF_ADDR_ID <= 0;
			IF_N_ADDR_ID <= 0;
		end else
		begin
			IF_DOUT2_ID <= DOUT2_IF;
			IF_ADDR_ID <= ADDR_IF;
			IF_N_ADDR_ID <= N_ADDR_IF;
		end
	end

	// Clear output on reset, else, write data
	always_ff @ (posedge CLK)
	begin 
		if (RST)
		begin
			IR_ID <= 0;
			ADDR_ID <= 0;
			N_ADDR_ID <= 0;
		end else 
		begin 
			IR_ID <= IF_DOUT2_ID;
			ADDR_ID <= IF_ADDR_ID;
			N_ADDR_ID <= IF_N_ADDR_ID;
		end;
	end	

endmodule
