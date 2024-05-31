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
//////////////////////////////////////////////////////////////////////////////////


module CacheController(
    input CLK,
    input RST,
	input hit,
	input readen1,
	input readen2,
	output logic stall,
	output logic memRE,
	output logic memWE,
	output logic valid1,
	output logic valid2
    );
    
    //// CacheController as State Machine
    /*
    typedef enum logic [1:0] {STAGE1, STAGE2, STAGE3, STAGE4} state_type;
    state_type state;
    
    // Start the state machine in the first stage
    initial begin state = STAGE1; 
    
    // State Machine
    always @ (posedge CLK)
    begin
        if(RST)     state <= STAGE1;
        else begin
            case(state)
            STAGE1: begin
                // HDL here;
            end 
            STAGE2: begin 
            end
            STAGE3: begin 
            end 
            STAGE4: begin 
            end
            default: begin
            end
        end
    end
    
    */
    
    
    
    
endmodule
