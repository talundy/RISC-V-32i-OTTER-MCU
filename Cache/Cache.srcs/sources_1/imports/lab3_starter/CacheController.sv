`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cow Poly
// Engineer: Thomas Lundy
// 
// Create Date: 04/07/2024 12:27:49 AM
// Design Name: 
// Module Name: CacheController
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      This module is the cache controller.
//      It is responsible for controlling the memory system.
//
// Instantiated by:
//      CacheController myCacheController (
//          .CLK        ()
//          .RST        ()
//          .hit        ()
//          .readen1    ()
//          .readen2    ()
//          .stall      ()
//          .memRE      ()
//          .memWE      ()
//          .valid1     ()
//          .valid2     ()
//      );
//
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//
//////////////////////////////////////////////////////////////////////////////////


module CacheController(
    input CLK,
    input RST,
	input miss,
	input wen,
	input ren,
	input mem_valid_in,
	output logic stall,
	output logic memRE,
	output logic memWE,
	output logic mem_valid_out
    );
    
    //// CacheController as State Machine
    
    typedef enum logic[1:0] {STAGE1, STAGE2, STAGE3, STAGE4} state_type;
    state_type state;
    
    
    
    // Start the state machine in the first stage
    initial begin 
        state = STAGE1; 
    end
    
    always_comb begin
        if(miss) state <= STAGE2;
    end
    // State Machine
    // Designed to only be active on misses
    always @(posedge CLK)
    begin
        if(RST)     state <= STAGE1;
        else 
            case(state)
            STAGE1: begin               // default state
                mem_valid_out <= 0;
                stall <= 0;
                memRE <= 0;
                memWE <= 0;
            end 
            STAGE2: begin                           // upon miss
                if (mem_valid_in) begin             // cache is being written to 
                    stall <= 1;                     // stall until mem_valid is no longer asserted
                end else if (!mem_valid_in && wen) begin    // write miss
                    /*
                    Stall the cache while we write the data to memory. 
                    */
                    stall <= 1;
                    memRE <= 0;
                    memWE <= 1;
                    mem_valid_out <=0;
                    state <= STAGE3;
                end else if (!mem_valid_in && ren) begin    // read miss
                    /*
                    Stall the cache while we read the data from memory. 
                    */
                    stall <= 1;
                    memRE <= 1;
                    memWE <= 0;
                    mem_valid_out <=0;
                    state <= STAGE4;
                end
            end
            STAGE3: begin // handle write miss
                
            end 
            STAGE4: begin // handle read miss
            
            end
            default: begin
                state <= STAGE1;
            end
            endcase
    end
    
    
    
    
    
    
endmodule
