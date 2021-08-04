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
   logic       tx_last;
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

    localparam PACKET_COUNTER_MAX = 10;
    localparam PACKET_COUNTER_SIZE = $clog2(PACKET_COUNTER_MAX);
    
    logic [PACKET_COUNTER_SIZE-1:0] packet_counter;
    
   always @(posedge clk)
     begin
	if(rst) begin
           packet_counter <= '0;
           
	end
	else begin
           // don't store the data unless we're ready
           if (tx_last & tx_valid & tx_ready) begin
              packet_counter <= '0;
              end
           else if (tx_valid & tx_ready) begin
              packet_counter <= packet_counter + 'd1;;
              
           end
	end
    end

   assign tx_last = (packet_counter == PACKET_COUNTER_MAX-1) ? 1'b1 : 1'b0;
   // UUT
   uart uart_i
     (
      .clk(clk),
      .rst(rst),
      .tx_data(tx_data),
      .tx_data_valid(tx_valid),
      .tx_data_ready(tx_ready),
      .tx_data_last(tx_last),
      .UART_TX(tx_out)
      );

   // Gen input tx data
   lfsr_8bit  lfsr_8bit_i
     (
      .clk(clk),
      .rst(rst),
      .clk_en(tx_ready),
      .data(tx_data)
      
      );
      
  assign tx_valid = ~rst;
   
endmodule
