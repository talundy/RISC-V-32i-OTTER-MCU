`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Thomas Lundy
// 
// Create Date: 05/09/2024 03:12:55 PM
// Design Name: Branch Address Generator
// Module Name: BrAddrGen
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


module BrAddrGen(
    input [31:0] jType,
    input [31:0] bType,
    input [31:0] iType,
    input [31:0] pc,
    input [31:0] rs1,
    output [31:0] jalr,
    output [31:0] branch,
    output [31:0] jal
    );
    
	assign jalr = iType + rs1;		// from immed_gen to pc mux
	assign branch = bType + pc;		// 
	assign jal = jType + pc;		// 
    
    
    
endmodule
