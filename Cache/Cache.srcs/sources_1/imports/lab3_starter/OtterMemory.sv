`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cow Poly
// Engineer: 
// 
// Create Date: 04/07/2024 12:18:27 AM
// Design Name: 
// Module Name: OtterMemory
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//     This module is the memory wrapper.
//     It is responsible for interfacing between the memory and the OTTER.
// 
// Instantiated by:
//      OtterMemory myOtterMemory (
//          .MEM_CLK        (),
//          .MEM_RST        (),
//          .MEM_RDEN1      (),
//          .MEM_RDEN2      (),
//          .MEM_WE2        (),
//          .MEM_ADDR1      (),
//          .MEM_ADDR2      (),
//          .MEM_DIN2       (),
//          .MEM_SIZE       (),
//          .MEM_SIGN       (),
//          .IO_IN          (),
//          .IO_WR          (),
//          .MEM_DOUT1      (),
//          .MEM_DOUT2      (),
//          .MEM_VALID1     (),
//          .MEM_VALID2     ()
//      );
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//   IO taken from 233 memory module. Thanks to the creators of that module.
//   This module IO should not be changed.
//   This memory system should be able to work with the multi-cycle and pipeline OTTER. Change your controllers accordingly.
//   Have fun with this lab :)
//
//////////////////////////////////////////////////////////////////////////////////


module OtterMemory (
    input MEM_CLK, 
    input MEM_RST,
    input MEM_RDEN1,                // read enable Instruction
    input MEM_RDEN2,                // read enable data
    input MEM_WE2,                  // write enable.
    input [13:0] MEM_ADDR1,         // Instruction Memory word Addr (Connect to PC[15:2])
    input [31:0] MEM_ADDR2,         // Data Memory Addr
    input [31:0] MEM_DIN2,          // Data to save
    input [1:0] MEM_SIZE,           // 0-Byte, 1-Half, 2-Word
    input MEM_SIGN,                 // 1-unsigned 0-signed
    input [31:0] IO_IN,             // Data from IO     
    output logic IO_WR,             // IO 1-write 0-read
    output logic [31:0] MEM_DOUT1,  // Instruction
    output logic [31:0] MEM_DOUT2,  // Data
    output logic MEM_VALID1,
    output logic MEM_VALID2
    );
    
    /* ADD YOUR DESIGN HERE */
	// SIGNALS //////////////////////////////////////////////////
	wire addr_sel, valid1_sel, valid2_sel;
	
	wire re_MEM, we_MEM ;
	wire cacheValid1, cacheValid2, ccValid1, ccValid2;	
	wire [31:0] addr, data_MEM;

	wire re_cache, stall;
	assign re_cache = MEM_RDEN1 + MEM_RDEN2;
	

    // L1 or L1s
	TwoWayCache myCache(
		.CLK(MEM_CLK),
		// Inputs 
		.memRdEn1(MEM_RDEN1),
		.memRdEn2(MEM_RDEN2),
		.RE(re_cache),
		.WE(MEM_WE2),
		.ADDR(addr),
		.DATA_IN2(MEM_DIN2),
		.SIZE(MEM_SIZE),
		.SIGN(MEM_SIGN),
		.stall(stall),
		// Outputs
		.valid1(),
		.valid2(),
		.DATA_OUT()
		);


    CacheLineAdapter myCacheLineAdapter (
        .CLK        ()
    );

    // Your choice of dual port or single port main memory
	
	SinglePortDelayMemory myMem(
		// Inputs
		.CLK(MEM_CLK),
		.RE(re_MEM),
		.WE(we_MEM),
		.DATA_IN(),
		.ADDR(),
		// Outputs
		.MEM_VALID(),
		.DATA_OUT(data_MEM)
		);


    CacheController myCacheController (
        // Inputs
		.CLK(MEM_CLK),
		.RST(MEM_RST),
		.hit(),
		.readen1(MEM_RDEN1),
		.readen2(MEM_RDEN2),
		// Outputs
		.stall(stall),
		.memRE(re_MEM),
		.memWE(we_MEM),
		.valid1(ccValid1),
		.valid2(ccValid2)
    );

	// MULTIPLEXORS
	Mult4to1 addressMux(
		MEM_ADDR1,
		MEM_ADDR2,
		IO_IN,
		data_MEM,
		addr,
		addr_sel
		);
	
	Mult2to1 valid1Mux(
		cacheValid1,
		ccValid1,
		MEM_VALID1,
		valid1_sel
		);
	
	Mult2to1 valid2Mux(
		cacheValid2,
		ccValid2,
		MEM_VALID2,
		valid2_sel
		);



endmodule
