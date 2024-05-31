`timescale 1ns / 1ps



module TwoWayCache(
	input CLK,
	input memRdEn1,
	input memRdEn2,
	input RE,
	input WE,
	input [31:0] ADDR,
	input [31:0] DATA_IN2,
	input [1:0] SIZE,
	input SIGN,
	input stall,
	
	output valid1,
	output valid2,
	output [31:0] DATA_OUT
	);
endmodule
