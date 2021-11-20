`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.11.2021 14:00:19
// Design Name: 
// Module Name: edge_detect
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


module edge_detect(
    input clk,
    input rst,
    input data_in,
    output data_out
    );
    
    
    logic data_in_q;
    
    always_ff@(posedge clk) begin
        if (rst) begin
            data_in_q <= 0;
        end
        else begin
            data_in_q <= data_in;
            
        end
    end
    
    assign data_out = (data_in != data_in_q) ? data_in : 0;
    
    
endmodule
