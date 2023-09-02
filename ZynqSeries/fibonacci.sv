`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/08/2023 10:01:25 PM
// Design Name: 
// Module Name: fibonacci
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


module fibonacci
  #(
    parameter SEQ_BITS = 32
    )
   (
     
    input		  clk, 
    input		  rst, 
   
    input		  get_next_number, 
   
    output [SEQ_BITS-1:0] seq,
    output		  seq_valid
   
    );
   
   // calculates the next number in the fibonacci series
   
   // initial values in sequence
   // _i indicates an internal value
   logic [1:0][SEQ_BITS-1:0] seq_i;
   logic		     seq_valid_i;
   
   
   
   always_ff @(posedge clk) begin
      if (rst) begin
         seq_i[0] <= 0;
         seq_i[1] <= 1; 
         seq_valid_i <= 0;
         
      end
      else begin
         seq_valid_i <= 0;
         if (get_next_number) begin
            seq_valid_i <= 1;
            seq_i[1] <= seq_i[0];
            seq_i[0] <= seq_i[0] + seq_i[1];
         end
      end
   end
   
   
   assign seq = seq_i[1];
   assign seq_valid = seq_valid_i;
   
   
endmodule
