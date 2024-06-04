`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cow Poly (Moo)
// Engineer: Thomas Lundy
// 
// Create Date: 06/04/2024 01:14:55 PM
// Design Name: 
// Module Name: MemoryWrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Modified version of the OtterMemory module for CPE333 Lab 03 (Cache). 
//              This version does not differentiate instrcution/data memory, as the cache will no longer be added into the RISCV. 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module MemoryWrapper(
    input MEM_CLK, 
    input MEM_RST,
    input MEM_RDEN,                
    input MEM_WE,                  
    input [31:0] MEM_ADDR,         
    input [31:0] MEM_DIN,          
    input [1:0] MEM_SIZE,          
    input MEM_SIGN,                 
    output logic [31:0] MEM_DOUT, 
    output logic MEM_VALID
    );
    

    
    wire mem_valid_in;                                          // connects MEM to CC
    wire [31:0] data_in, data_out, addr;                        // connects MEM to CLA
    
    //// CACHE ///////////////////////////////////////////////////////////////////////
    logic [256:0] Way0, Way1;                                   // The actual ways (data)
    logic [207:0] TagArray0, TagArray1;                         // Tag Arrays (tag size * 8)
    logic [7:0] valid0, valid1;                                 // valid bit arrays
    logic [7:0] dirty0, dirty1;                                 // dirty bit arrays
    wire [256:0] cacheline_in, cacheline_out;                   // connects ways to CLA
    wire [1:0] offset;                                          // byte offset
    wire [3:0] index;                                           // set index
    wire [25:0] tag;                                            // bet you can't guess what this does
    
    assign offset = MEM_ADDR[1:0];
    assign index  = MEM_ADDR[5:2];
    assign tag    = MEM_ADDR[31:6];
    
    logic [31:0] word0, word1; // wrong?
    always_comb begin
        assign word0 = Way0[index * 8];                         // using additional regs for word0/1 may slow us down a cycle
        assign word1 = Way1[index * 8];
        
        
        if(MEM_RDEN) begin          // read attempt
            //compare tags, etc
        end else if (MEM_WE) begin  // write attempt
        
        end else begin
            // default case
        end
    end
    //////////////////////////////////////////////////////////////////////////////////
    
    CacheController myCacheController (
       .CLK(MEM_CLK),
       .RST(MEM_RST),
       .hit(),
	   .wen(MEM_WE),
	   .ren(MEM_RDEN),
	   .mem_valid_in(mem_valid_in),
	   
	   .stall(),
	   .memRE(),
	   .memWE(),
	   .mem_valid_out()
    );
    
    CacheLineAdapter myCacheLineAdapter (
        .CLK        (MEM_CLK),
        .RST(MEM_RST),
        .cacheline_in(cacheline_in),
        .addr(MEM_ADDR),
        .data_in(data_in),
    
        .cacheline_out(cacheline_out),
        .mem_addr(addr),
        .mem_pkg_out(data_out)
    );
    
    SinglePortDelayMemory #(
          .DELAY_CYCLES   (10),
          .BURST_LEN      (4)
         ) mySinglePortMemory (
          .CLK            (MEM_CLK),
          .RE             (),
          .WE             (),
          .DATA_IN        (data_out),
          .ADDR           (addr),
          .DATA_OUT       (data_in),
          .MEMVALID       (mem_valid_in)
      );
    
    
    
endmodule
