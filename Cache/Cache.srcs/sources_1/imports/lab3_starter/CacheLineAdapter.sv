`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cow Poly 
// Engineer: Danny Gutierrez
// 
// Create Date: 04/07/2024 12:16:02 AM
// Design Name: 
// Module Name: CacheLineAdapter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description:
//         This module is responsible for interfacing between the cache and the memory. The middle man if you will.
//         It will be responsible for reading and writing to the memory
//         It will also be responsible for reading and writing to the cache
//         It will be responsible for the cache line size
// 
// Instantiated by:
//      CacheLineAdapter myCacheLineAdapter (
//          .CLK        ()
//      );
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module CacheLineAdapter (
    input CLK,
    input RST,
    input [255:0] cacheline_in,
    input [31:0] addr,
    input [31:0] data_in,
    
    output logic [255:0] cacheline_out,
    output logic [31:0] mem_addr,
    output logic [31:0] mem_pkg_out
    );
    
endmodule
