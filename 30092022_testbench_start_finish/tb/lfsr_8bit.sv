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


module lfsr_8bit
  (
   input 	clk,
   input 	rst,
   input    clk_en,
   output [7:0] data
   );


   logic [8:0] 	lfsr = 8'b11111111;
   logic [3:0] 	lfsr_feedback;
   assign lfsr_feedback= {lfsr[7],lfsr[5:3]};

   always @(posedge clk)
     begin
	if(rst) begin
           lfsr <= 8'b11111111;

	end
	else if (clk_en) begin
           lfsr[7:1] <= lfsr[6:0];
           lfsr[0] <= ^lfsr_feedback;
	end
     end

   assign data = lfsr;

endmodule
