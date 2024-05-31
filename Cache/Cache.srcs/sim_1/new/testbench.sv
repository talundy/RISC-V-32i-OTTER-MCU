`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Thomas Lundy
// 
// Create Date: 05/29/2024 12:26:27 PM
// Design Name: Cache Testbench
// Module Name: testbench
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


module testbench();
    
    // Create test signals
    logic clk;
    logic rst;
    logic rden1, rden2;
    logic we2;
    logic [31:0] addr1, addr2;
    logic [31:0] din2;
    logic [1:0] size;
    logic sign;
    logic [31:0] io_in;
    logic io_wr;
    logic [31:0] dout1, dout2;
    logic valid1, valid2;
    
    OtterMemory dut(
    .MEM_CLK(), 
    .MEM_RST(),
    .MEM_RDEN1(),                // read enable Instruction
    .MEM_RDEN2(),                // read enable data
    .MEM_WE2(),                  // write enable.
    .MEM_ADDR1(),         // Instruction Memory word Addr (Connect to PC[15:2])
    .MEM_ADDR2(),         // Data Memory Addr
    .MEM_DIN2(),          // Data to save
    .MEM_SIZE(),           // 0-Byte, 1-Half, 2-Word
    .MEM_SIGN(),                 // 1-unsigned 0-signed
    .IO_IN(),             // Data from IO     
    .IO_WR(),             // IO 1-write 0-read
    .MEM_DOUT1(),  // Instruction
    .MEM_DOUT2(),  // Data
    .MEM_VALID1(),
    .MEM_VALID2()
    );
    
    // CLK Signal /////////////////////////////////////
    initial begin
        clk = 0;
        forever #1 clk = ~clk; // toggles every ns, 1GHz clk
    end
        
    initial begin 
    //// INITIALIZATION /////////////////////////////////
        rst = 1;
        rden1 = 0;
        rden2 = 0;
        we2 = 0;
        addr1 = 0;
        addr2 = 0;
        din2 = 0;
        size = 0;
        sign = 0;
        io_in = 0;
        io_wr = 0;
        dout1 = 0;
        dout2 = 0;
        valid1 = 0;
        valid2 = 0;
    //// TEST SIGNALS ////////////////////////////////////
        #3 // Turn off reset after 3ns (1 cycle)
        rst = 0;
    end
endmodule
