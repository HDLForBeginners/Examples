`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 15.11.2021 16:17:08
// Design Name:
// Module Name: ethernet_tb
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


module ethernet_tb(

    );


   // Clock definition
   localparam CLK_PERIOD = 10; // 50 Mhz (counter is in ns)
   localparam RST_COUNT = 10; //Clock cycles that reset is high

   logic clk = 0;
   logic rst;

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

   logic [7:0] lsfr_data;
   logic       lsfr_clk;


   // Gen input data
   lfsr_8bit  lfsr_8bit_i
     (
      .clk(lsfr_clk),
      .rst(1'b0),
      .clk_en(1'b1),
      .data(lsfr_data)

      );


   ethernet_top ethernet_top_i
     (
      .CLK(clk),
      .RST_N(~rst),

      .M_CLK(lsfr_clk),
      .M_DATA(lsfr_data[0]),
      .M_LRSEL()

      );

endmodule
