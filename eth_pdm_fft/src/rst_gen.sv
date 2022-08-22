`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 13.11.2021 14:32:12
// Design Name: 
// Module Name: rst_gen
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


module rst_gen(
    input clk_in,
    input rst_in,
    output rst_out

    );
    
    logic [2:0] rst_q;
    
    
    // Triple Register into clk_in domain
    always_ff@(posedge clk_in) begin
       rst_q[0] <= rst_in;
       rst_q[2:1] <= rst_q[1:0];
       
    end
    
    // internal reset 
    // only come out of reset when rst_q is all zeros
    assign rst_out = (rst_q == 0) ? 0 : 1;
    
    
endmodule
