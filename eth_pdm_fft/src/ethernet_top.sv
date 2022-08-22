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

   // PDM MICROPHONE

   localparam MIC_DATA_INT = 1;
   localparam MIC_DATA_FRAC = 31;

   logic [MIC_DATA_INT-1:-MIC_DATA_FRAC] mic_data;
   logic                                 mic_data_valid;
   logic                                 mic_clk_enable;


   // 2.4M out
   pdm_microphone
     #(
       .INPUT_FREQ(50_000_000),
       .PDM_FREQ(2_400_000) // 2.4M out

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


   parameter PACKET_PAYLOAD_WORDS = 256;
   parameter WORD_BYTES = 4;
   localparam WINDOW_INT = 1;
   localparam WINDOW_FRAC = 16;

   logic [WINDOW_INT-1:-WINDOW_FRAC] window_out;
   logic                             window_out_valid;
   logic                             window_out_last;
   logic                             window_out_ready;


   parzen
     #(
       .WINDOW_SIZE_POW2($clog2(PACKET_PAYLOAD_WORDS)),
       .INTERNAL_FRAC(16),
       .OUTPUT_INT(WINDOW_INT),
       .OUTPUT_FRAC(WINDOW_FRAC)
       )
   parzen_i
     (
      .clk(eth_clk),
      .rst(eth_rst),

      .window_out_ready(window_out_ready),
      .window_out(window_out),
      .window_out_valid(window_out_valid),
      .window_out_last(window_out_last)

      );

   assign window_out_ready = windowed_data_ready & mic_data_valid;

   // combined axi stream interface
   // Apply window by multiplying mic data with parzen
   localparam WINDOWED_DATA_INT = MIC_DATA_INT + WINDOW_INT;
   localparam WINDOWED_DATA_FRAC = MIC_DATA_FRAC + WINDOW_FRAC;

   logic [WINDOWED_DATA_INT-1:-WINDOWED_DATA_FRAC] windowed_data_fullscale;
   logic [MIC_DATA_INT-1:-MIC_DATA_FRAC]           windowed_data;
   logic                                           windowed_data_valid;
   logic                                           windowed_data_last;
   logic                                           windowed_data_ready;


   assign windowed_data_valid = mic_data_valid & window_out_valid;
   assign windowed_data_last = window_out_last;
   assign windowed_data_fullscale = mic_data*window_out;

   // reduce to MIC_DATA size
   assign windowed_data = windowed_data_fullscale[MIC_DATA_INT-1:-MIC_DATA_FRAC];



   localparam FFT_DATA_INT = 10;
   localparam FFT_DATA_FRAC = MIC_DATA_FRAC;

   logic [95:0]                                    fft_data_fullscale;
   logic [FFT_DATA_INT-1:-FFT_DATA_FRAC]           fft_data_re;
   logic [FFT_DATA_INT-1:-FFT_DATA_FRAC]           fft_data_im;
   logic [FFT_DATA_INT*2-1:-FFT_DATA_FRAC*2]       fft_data_re_sq;
   logic [FFT_DATA_INT*2-1:-FFT_DATA_FRAC*2]       fft_data_im_sq;
   logic [FFT_DATA_INT-1:-FFT_DATA_FRAC]           fft_data;
   logic [31:0]                                    fft_data_byteswapped;
   logic                                           fft_data_valid;
   logic                                           fft_data_sq_valid;
   logic                                           fft_data_last;
   logic                                           fft_data_ready;
   logic                                           fft_data_sq_last;
   logic                                           fft_data_sq_ready;
   logic [FFT_DATA_INT*2:-FFT_DATA_FRAC*2]         fft_data_sum_squares;


   assign fft_data_ready = 1;


   xfft_0  xfft_0_i
     (
      .aclk(eth_clk),                                                // input wire aclk
      .s_axis_config_tdata(1),                  // input wire [7 : 0] s_axis_config_tdata
      .s_axis_config_tvalid(1),                // input wire s_axis_config_tvalid
      .s_axis_config_tready(s_axis_config_tready),                // output wire s_axis_config_tready
      .s_axis_data_tdata({32'b0,windowed_data}),                      // input wire [63 : 0] s_axis_data_tdata
      .s_axis_data_tvalid(windowed_data_valid),                    // input wire s_axis_data_tvalid
      .s_axis_data_tready(windowed_data_ready),                    // output wire s_axis_data_tready
      .s_axis_data_tlast(windowed_data_last),                      // input wire s_axis_data_tlast
      .m_axis_data_tdata(fft_data_fullscale),                      // output wire [95 : 0] m_axis_data_tdata
      .m_axis_data_tvalid(fft_data_valid),                    // output wire m_axis_data_tvalid
      .m_axis_data_tready(fft_data_ready),                    // input wire m_axis_data_tready
      .m_axis_data_tlast(fft_data_last),                      // output wire m_axis_data_tlast
      .event_frame_started(event_frame_started),                  // output wire event_frame_started
      .event_tlast_unexpected(event_tlast_unexpected),            // output wire event_tlast_unexpected
      .event_tlast_missing(event_tlast_missing),                  // output wire event_tlast_missing
      .event_status_channel_halt(event_status_channel_halt),      // output wire event_status_channel_halt
      .event_data_in_channel_halt(event_data_in_channel_halt),    // output wire event_data_in_channel_halt
      .event_data_out_channel_halt(event_data_out_channel_halt)  // output wire event_data_out_channel_halt
      );


   assign fft_data_re = fft_data_fullscale[40:0];
   assign fft_data_im = fft_data_fullscale[88:48];
   assign fft_data_re_sq  = fft_data_re*fft_data_re;
   assign fft_data_im_sq  = fft_data_im*fft_data_im;
   assign fft_data_sum_squares = fft_data_re_sq + fft_data_im_sq;


   endian_switch #( .BYTE_SIZE(8), .INPUT_BYTES(WORD_BYTES) ) endian_switch_data ( .in(fft_data_sum_squares[FFT_DATA_INT*2-1 -: 32]), .out(fft_data_byteswapped) );


   packet_gen
     #(
       .PACKET_PAYLOAD_WORDS(PACKET_PAYLOAD_WORDS),
       .WORD_BYTES(WORD_BYTES),
       .DEST_MAC(48'h080027fbdd65)
       )
   packet_gen_i
     (
      .clk(eth_clk),
      .rst(eth_rst),
      .s_axis_tdata(fft_data_byteswapped),
      .s_axis_tvalid(fft_data_valid),
      .s_axis_tlast(fft_data_last),
      .s_axis_tready(fft_data_ready),
      .tx_en(ETH_TXEN),
      .txd(ETH_TXD)
      );


endmodule
