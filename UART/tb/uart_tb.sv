`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2021 18:18:52
// Design Name: 
// Module Name: simple_increment_tb
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

module uart_tb(

	       );
   
   logic clk = 0;
   logic rst = 1;
   logic [7:0] tx_data;
   logic       tx_ready;
   logic       tx_valid;
   logic       tx_out;
   
   
   // Clock definition
   localparam CLK_PERIOD = 20000; // 50 Mhz (counter is in ps)
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

   always @(posedge clk)
     begin
	if(rst) begin
           tx_valid <= 1'b0;
	end
	else  begin
           tx_valid <= 1'b0;
           if (tx_ready) begin
              tx_valid <= 1'b1;
              
           end
	end
     end
   
   // UUT
   uart_tx uart_tx_i
     (
      .clk(clk),
      .rst(rst),
      .tx_data(tx_data),
      .tx_data_valid(tx_valid),
      .tx_data_ready(tx_ready),
      .UART_TX(tx_out)
      );

   // Gen input tx data
   lfsr_8bit  lfsr_8bit_i
     (
      .clk(clk),
      .rst(rst),
      .data(tx_data)
      
      );
   
endmodule
