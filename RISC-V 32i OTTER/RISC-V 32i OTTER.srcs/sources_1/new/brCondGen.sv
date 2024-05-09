`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Thomas Lundy
// 
// Create Date: 05/09/2024 04:01:46 PM
// Design Name: Branch Condition Generator
// Module Name: brCondGen
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module brCondGen(
    input [31:0] rs1,
    input [31:0] rs2,
    output logic br_eq,
    output logic br_lt,
    output logic br_ltu
    );
    
	always_comb
	begin
		br_lt = 0;
		br_eq = 0;
		br_ltu = 0;
		if($signed(rs1) < $signed(rs2)) br_lt = 1;
		if(rs1 == rs2) br_eq = 1;
		if(rs1 < rs2) br_ltu = 1;
	end	
    
    
    
    
endmodule
