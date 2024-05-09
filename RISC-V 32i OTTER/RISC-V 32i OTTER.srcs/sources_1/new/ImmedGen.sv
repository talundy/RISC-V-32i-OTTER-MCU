`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Thomas Lundy
// 
// Create Date: 05/09/2024 03:12:55 PM
// Design Name: Immediate Generator
// Module Name: ImmedGen
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


module ImmedGen(
    input [31:0] ir,
    output [31:0] uType,
    output [31:0] iType,
    output [31:0] sType,
    output [31:0] jType,
    output [31:0] bType
    );
    
	assign uType = {ir[31:12], {12{1'b0}}};
	assign iType = {{20{ir[31]}}, ir[31:20]};
	assign sType = {{20{ir[31]}}, ir[31:25], ir[11:7]};
	assign jType = {{12{ir[31]}}, ir[19:12], ir[20], ir[30:21], 1'b0};
	// byte aligned addresses
	assign bType = {{20{ir[31]}}, ir[7], ir[30:25], ir[11:8], 1'b0}; 
    // word aligned address
    //assign bType = {{21{ir[31]}}, ir[7], ir[30:25], ir[11:8], 1b'0};
    
endmodule
