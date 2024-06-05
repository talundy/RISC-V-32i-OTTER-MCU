// Module Name: cache
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/28/2024 06:26:10 PM
// Design Name: 
// Module Name: cache
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


module cache(
    input CLK,
    input Address,
    input [255:0]DataInMem,
    input [31:0]DataInOtter,
    input logic write_enable,
    input logic read_enable,
//    output logic [7:0]dirtyW1,
//    output logic [7:0]dirtyW2,
//    output logic [7:0]validW1,
//    output logic [7:0]validW2,
    output logic hit,
    output logic [255:0]DataOut2Mem,
    output logic [31:0]DataOutOtter
    );
    logic [5:0]Offset;
    logic [2:0]set;
    logic [27:0]tag;
    logic hitW1;
    logic hitW2;
    input logic [31:0]write_data;
    logic [7:0] LRU;
    logic [31:0]AdjustOffset;
    logic [31:0]data_arrayW1[7:0];
    logic [31:0]data_arrayW2[7:0];
    logic [27:0]tag_arrayW1[7:0];
    logic [27:0]tag_arrayW2[7:0];
    
    //Hit Checker
    always_ff @ (posedge CLK)
    begin
    if (~read_enable || ~write_enable)
        Offset = Address[5:0];
        set = Address[8:6];
        tag = Address[31:9];
        tagcomparW1 = tag_array[set];
        tagcomparW2 = tag_array[set];
        if (tagcomparW1 == tag)
        begin 
            hit = 1;
            hitW1 = 1;
            hitW2 = 0;
        end
        else if (tagcomparW2 == tag)
        begin 
            hit = 1;
            hitW2 = 1;
            hitW1 = 0;
        end
        else 
        begin
            hit = 0;
            hitW1 = 0;
            hitW2 = 0;
            
        end
    end
    //Cache write
    always_ff @(posedge CLK) 
    begin
        if (write_enable) 
        begin
            if (LRU[set]) 
            begin
                data_array_way1[set][offset] <= write_data;
//                tag_array_way1[set] <= tag;
                LRU[set] <= 0;
            end 
            else 
            begin
                data_array_way0[set][offset] <= write_data;
                tag_array_way0[set] <= tag;
                LRU[set] <= 1;
            end
        end
    end
    
    //Cache read
    always_ff @(posedge CLK) 
    begin
        AdjustOffset = Offset * 4;
        if (read_enable)
        begin
            if (hitW1 == 1)
            begin 
                DataOut = data_arrayW1[set][offset];
                LRU[set] = 0;
            end
            else if (hitW2 == 1)
            begin 
                DataOut = data_arrayW2[set][offset];
                LRU[set] = 1;
            end
            else 
            begin 
            end
        end
        else if (readMem_enable)
        begin
            for (int i = 0; i < WORDS_PER_LINE; i++) begin
                cache_line_out[(i*32) +: 32] = words[i];
            end
        end
    end
endmodule
