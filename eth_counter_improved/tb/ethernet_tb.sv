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
   localparam CLK_PERIOD = 5; // 100 Mhz (counter is in ns)
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


 ethernet_top ethernet_top_i(
    .CLK(clk),
    .RST_N(~rst)
    );
    
endmodule
