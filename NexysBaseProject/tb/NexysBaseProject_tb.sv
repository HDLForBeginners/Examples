`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 14.07.2021 18:18:52
// Design Name:
// Module Name: NexysBaseProject_tb
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

module NexysBaseProject_tb
  (

   );

   logic clk = 0;
   logic rst = 1;

   // Clock definition
   localparam CLK_PERIOD = 10; // 100 Mhz (counter is in ns)
   localparam RST_COUNT = 10; //Clock cycles that reset is high

   always begin
      clk   = #(CLK_PERIOD/2) ~clk;
   end

   // reset definition
   initial begin
      rst = 1;
      #(RST_COUNT*CLK_PERIOD);
      @(posedge clk);
      rst = 0;
   end

   // UUT
   NexysBaseProject_top NexysBaseProject_top_i
     (
      .CLK(clk),
      .RST_N(~rst)
      );


endmodule
