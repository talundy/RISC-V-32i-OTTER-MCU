`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Thomas Lundy
// 
// Create Date: 04/17/2024 05:47:09 PM
// Design Name: 
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
    logic btnl;
    logic btnc;
    logic [15:0] switches;
    logic ps2clk;
    logic ps2data;
    logic [15:0] leds;
    logic [7:0] cathodes;
    logic [3:0] anodes;
    logic [7:0] vga_rgb;
    logic vga_hs;
    logic vga_vs;
    logic tx;
    
    
//Instantiate device under test
OTTER_Wrapper dut(
       .CLK(clk),
       .BTNL(BTNL),
       .BTNC(btnc),
       .SWITCHES(switches),
       .PS2Clk(ps2clk),
       .LEDS(leds),
       .CATHODES(cathodes),
       .ANODES(anodes),        
       .VGA_RGB(vga_rgb),
       .VGA_HS(vga_hs),
       .VGA_VS(vga_vs),
      .Tx(tx)
);
    
    // Generate test clock signals
    initial begin
        clk = 0;
        forever #1 clk = ~clk; // toggle every nanosecond for a 1Ghz clk
    end
    
    // Instantiate other signals
    initial begin 
        btnl = 0;
        btnc = 0; // trigger restart by turning on
        switches = 0;
        ps2clk = 0;
        ps2data = 0;
        leds = 0;
        cathodes = 0;
        anodes = 0;
        vga_rgb = 0;
        vga_vs = 0;
        vga_hs = 0;
        tx = 0;
        
        #6
        btnc = 0; // turn off reset after 6 ns (two cycles)
        #10_000;
        $finish; // should end sim after 10k ns
    end
    
    
    
    
    
    // Watch for exit subroutine calls (hardcode based on mem file)
    //always @(posedge clk) begin
    //    if(dut.MCU.pc == 32'h00002038)
    //        $display("PC address hit first instruction of exit subroutine (h'2038c) at time %t", $time);
    //    else if(dut.MCU.pc == 32'h00002044) 
    //        $display("PC address is exiting (hit first jal inst.) (h'2044) at time %t", $time);
    //end
        
endmodule
