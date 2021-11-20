`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.11.2021 13:30:52
// Design Name: 
// Module Name: debounce
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


module debounce
(
    input clk,
    input rst,
    input sw_in,
    output sw_out
    );
    
    localparam DEBOUNCE_LENGTH = 10;
    logic [DEBOUNCE_LENGTH-1:0] sw_in_q;
    logic sw_out_i;
    logic [DEBOUNCE_LENGTH-1:0] ones;
    assign ones = '1;
    
    always_ff@(posedge clk) begin
        if (rst==1) begin
            sw_in_q <= 0;
            sw_out_i <= 0;
            
        end
        else begin
            sw_in_q[0] <= sw_in;
            sw_in_q[DEBOUNCE_LENGTH-1:1] <= sw_in_q[DEBOUNCE_LENGTH-2:0];
            
            // if history is all ones and previously off, turn on
            if ((sw_in_q == ones) && (sw_out_i == 0)) begin
                sw_out_i <= 1;
                
            end
            
            // if history is all 0s and previously on, turn off
            if ((sw_in_q == 0) && (sw_out_i == 1)) begin
                sw_out_i <= 0;
                
            end
            
        end
    end
    
    assign sw_out = sw_out_i;
    
    
endmodule
