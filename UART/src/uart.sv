`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HDLForBeginners
// Engineer: Stacey
// 
// Create Date: 14.07.2021 13:47:50
// Design Name: uart_tx
// Module Name: 
// Project Name: uart_tx
// Target Devices: 
// Tool Versions: 
// Description: 
// transmits a supplied word over uart
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart
  #(
    parameter CLKRATE = 100000000,
    parameter BAUD = 115200,
    parameter WORD_LENGTH = 8
    )
   (
    input 		    clk,
    input 		    rst,
    input [WORD_LENGTH-1:0] tx_data,
    input 		    tx_data_valid,
    input 		    tx_data_last,
    output 		    tx_data_ready,
    output 		    UART_TX
    );
   
    logic           tx_data_fifo_m_axis_tlast;
    logic           tx_data_fifo_m_axis_tready;
    logic           tx_data_fifo_m_axis_tvalid;
    logic [WORD_LENGTH-1:0] tx_data_fifo_m_axis_tdata;
   
   tx_fifo 
    tx_data_fifo_i(
   // unused
  .wr_rst_busy(),      // output wire wr_rst_busy
  .rd_rst_busy(),      // output wire rd_rst_busy
  .s_aclk(clk),                // input wire s_aclk
  .s_aresetn(~rst),          // input wire s_aresetn
  // slave
  .s_axis_tvalid(tx_data_valid),  // input wire s_axis_tvalid
  .s_axis_tready(tx_data_ready),  // output wire s_axis_tready
  .s_axis_tdata(tx_data),    // input wire [7 : 0] s_axis_tdata
  .s_axis_tlast(tx_data_last),    // input wire s_axis_tlast
  //master
  .m_axis_tvalid(tx_data_fifo_m_axis_tvalid),  // output wire m_axis_tvalid
  .m_axis_tready(tx_data_fifo_m_axis_tready),  // input wire m_axis_tready
  .m_axis_tdata(tx_data_fifo_m_axis_tdata),    // output wire [7 : 0] m_axis_tdata
  .m_axis_tlast(tx_data_fifo_m_axis_tlast)    // output wire m_axis_tlast
);
   
 uart_tx
  #(
     .CLKRATE(CLKRATE),
     .BAUD(BAUD),
     .WORD_LENGTH(WORD_LENGTH)
    )
    uart_tx_i
   (
     .clk(clk),
     .rst(rst),
     .tx_data(tx_data_fifo_m_axis_tdata),
     .tx_data_valid(tx_data_fifo_m_axis_tvalid),
     .tx_data_ready(tx_data_fifo_m_axis_tready),
     .UART_TX(UART_TX)
    );
    
endmodule
