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
    input [31:0] Address,
    input logic write_enable,
    input logic read_enable,
    output logic [32:0]DataOut
    );
    logic [5:0]Offset;
    logic [2:0]set;
    logic [27:0]tag;
    logic hit;
    logic [31:0] write_data;
    logic [8:0] LRU;
    logic [31:0]AdjustOffset;
    logic [31:0]data_arrayW1[7:0];
    logic [31:0]data_arrayW2[7:0];
    logic [27:0]tag_arrayW1[7:0];
    logic [27:0]tag_arrayW2[7:0];
    
    
    always_ff @ (posedge CLK)
    begin
        Offset <= Address[5:0];
        set = Address[8:6];
        tag = Address[31:9];
        tagcomparW1 = tag_array[set];
        tagcomparW2 = tag_array[set];
        if (tagcomparW1 == tag)
        begin 
            hit = 1;
        end
        else if (tagcomparW2 == tag)
        begin 
            hit = 1;
        end
        else 
        begin
            hit = 0;
        end
    end
    
    always_ff @(posedge CLK) 
    begin
        if (write_enable) 
        begin
            if (lru[set_index]) 
            begin
                data_array_way1[set_index][block_offset] <= write_data;
                tag_array_way1[set_index] <= tag;
                lru[set_index] <= 0;
            end 
            else 
            begin
                data_array_way0[set_index][block_offset] <= write_data;
                tag_array_way0[set_index] <= tag;
                lru[set_index] <= 1;
            end
        end
    end
    
    
    always_ff @(posedge CLK) 
    begin
        AdjustOffset = Offset * 4;
        if (read_enable)
        begin
            if (hit == 1)
            begin 
                DataOut = data_arrayW1[set][offset];
                LRU[set] = 1;
            end
            if (hit == 2)
            begin 
                DataOut = data_arrayW2[set][offset];
                LRU[set] = 0;
            end
            else 
            begin
                
            end
        end
    end
endmodule
