`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HDLForBeginners
// Engineer: Stacey
// 
// Create Date: 14.07.2021 13:47:50
// Design Name: lfsr_4bit
// Module Name: lfsr_4bit_top
// Project Name: lfsr_4bit
// Target Devices: 
// Tool Versions: 
// Description: 
// Increments a counter and and drives an output gpio pin
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module lfsr_4bit_top(
    input clk,
    input rst,
    output led
    );
    
    
    logic [3:0] lfsr;
    
    always @(posedge clk)
    begin
       if(rst) begin
           lfsr <= 4'b11111;
 
       end
       else begin
           lfsr[3] <= lfsr[2]; 
           lfsr[2] <= lfsr[1]; 
           lfsr[1] <= lfsr[0]; 
           lfsr[0] <= lfsr[2]^lfsr[3];           
       end
    end
    
    assign led = (lfsr > 4'd10) ? 1'b1 : 1'b0;
            
endmodule
