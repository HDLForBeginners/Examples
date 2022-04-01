`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 12.11.2021 22:54:19
// Design Name:
// Module Name: ethernet_top
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


module ethernet_top
  (
   input        CLK,
   input        RST_N,

   // Microphone
   output       M_CLK,
   input        M_DATA,
   output       M_LRSEL,


   output       ETH_MDC,
   inout        ETH_MDIO,
   output       ETH_RSTN,
   inout        ETH_CRSDV,
   input        ETH_RXERR,
   inout [1:0]  ETH_RXD,
   output       ETH_TXEN,
   output [1:0] ETH_TXD,
   output       ETH_REFCLK,
   input        ETH_INTN
   );


    logic rst;

  rst_gen rst_gen_i(
     .clk_in(CLK),
     .rst_in(~RST_N),
     .rst_out(rst)

    );

    logic eth_clk;
    logic eth_rst;

    // Boot Mode config
    // Mode 111
    assign ETH_CRSDV  = (eth_rst) ? 1 : 1'bz;
    assign ETH_RXD[0] = (eth_rst) ? 1 : 1'bz;
    assign ETH_RXD[1] = (eth_rst) ? 1 : 1'bz;

    // No mdio interface
    assign ETH_MDC = 0;

  eth_rst_gen eth_rst_gen_i(
     .clk(CLK),
     .rst(rst),
     .eth_clk_out(eth_clk),
     .eth_rst_out(eth_rst),
     .ETH_REFCLK(ETH_REFCLK),
     .ETH_RSTN(ETH_RSTN)
    );

   // Timer to generate a packet after every interval
   logic [63:0] packet_timer;

   // if simulating, send packets more often
`ifdef XILINX_SIMULATOR
   localparam packet_max = 2_000;
`else
   localparam packet_max = 600;
`endif

   logic [31:0] mic_data;
   logic        mic_data_valid;

   pdm_microphone
     #(
       .INPUT_FREQ(50_000_000),
       .PDM_FREQ(2_400_000) // 2.4k out

       )
   pdm_microphone_i
     (
      .clk(eth_clk),
      .rst(eth_rst),

      .mic_data(mic_data),
      .mic_data_valid(mic_data_valid),

      .M_CLK(M_CLK),
      .M_DATA(M_DATA),
      .M_LRSEL(M_LRSEL)

      );


   parameter PACKET_PAYLOAD_WORDS = 128;
   parameter WORD_BYTES = 4;

   logic [WORD_BYTES*8-1:0] s_axis_tdata;
   logic                    s_axis_tvalid;
   logic                    s_axis_tready;
   logic                    s_axis_tlast;

   // increment the timer and create an enable pulse when reaching max
   always_ff@(posedge eth_clk) begin
      if (eth_rst == 1) begin
         packet_timer  <= 0;

      end
      else if (s_axis_tready) begin

         if (s_axis_tvalid) begin
            if (packet_timer == packet_max) begin
               packet_timer <= 0;

            end
            else begin
               packet_timer <= packet_timer + 1;
            end
         end
      end
   end

   assign s_axis_tvalid = mic_data_valid;
   assign s_axis_tlast = packet_timer == PACKET_PAYLOAD_WORDS-1;
   endian_switch #( .BYTE_SIZE(8), .INPUT_BYTES(WORD_BYTES) ) endian_switch_data ( .in(mic_data), .out(s_axis_tdata) );

   packet_gen
     #(
       .PACKET_PAYLOAD_WORDS(PACKET_PAYLOAD_WORDS),
       .WORD_BYTES(WORD_BYTES),
       .DEST_MAC(48'h080027fbdd66)
       )
   packet_gen_i
     (
      .clk(eth_clk),
      .rst(eth_rst),
      .s_axis_tdata(s_axis_tdata),
      .s_axis_tvalid(s_axis_tvalid),
      .s_axis_tlast(s_axis_tlast),
      .s_axis_tready(s_axis_tready),
      .tx_en(ETH_TXEN),
      .txd(ETH_TXD)
      );


endmodule
