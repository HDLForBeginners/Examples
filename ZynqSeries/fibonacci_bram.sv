`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/08/2023 10:01:25 PM
// Design Name: 
// Module Name: fibonacci_bram
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


module fibonacci_bram
  (
   
   input	 clk, 
   input	 rst, 
  
   output [31:0] BRAM_addr,
   output	 BRAM_clk,
   output [31:0] BRAM_din,
   input [31:0]	 BRAM_dout,
   output	 BRAM_en,
   output	 BRAM_rst,
   output [3:0]	 BRAM_we
  
   );
   
   localparam	 BRAM_DEPTH = 2048;
   localparam	 SEQ_BITS = 32;
   localparam	 CLK_MHZ = 100;
   
   logic [SEQ_BITS-1:0]	seq_num;
   logic		seq_valid;
   
   logic [31:0]		address;
   logic [31:0]		counter;
   
   logic		get_next_number;
   assign get_next_number = (counter == 1) ? 1 : 0;
   
   localparam		COUNTER_MAX = CLK_MHZ*500000;
   
   fibonacci
     #(
       .SEQ_BITS(SEQ_BITS)
       ) 
   fibonacci_i
     (
      .clk(clk),
      .rst(rst | address == BRAM_DEPTH-1),

      .get_next_number(get_next_number),
      .seq(seq_num),
      .seq_valid(seq_valid)

      );
   
   
   always_ff @(posedge clk) begin
      if (rst) begin
         address <= 0;
         
      end
      else begin
         if (seq_valid) begin
            if (address < BRAM_DEPTH-1) begin
               address <= address + 1;
            end
            else begin
               address <= 0;
               
            end            
         end
      end
   end 
   
   always_ff @(posedge clk) begin
      if (rst) begin
         counter <= 0; 
         
      end
      else begin
         if (counter < COUNTER_MAX-1) begin
            counter <= counter + 1;
         end 
         else begin
            counter <= 0;
         end
      end
   end 
   
   
   assign BRAM_addr = address << 2;
   assign BRAM_clk = clk;
   assign BRAM_din = seq_num;
   assign BRAM_en = 1;
   assign BRAM_rst = rst;
   assign BRAM_we = {4{seq_valid}};
   
   
endmodule
