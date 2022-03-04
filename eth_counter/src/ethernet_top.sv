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


module ethernet_top(
    input CLK,
    input RST_N,
    output ETH_MDC,
    inout ETH_MDIO,
    output ETH_RSTN,
    inout ETH_CRSDV,
    input ETH_RXERR,
    inout [1:0] ETH_RXD,
    output ETH_TXEN,
    output [1:0] ETH_TXD,
    output ETH_REFCLK,
    input ETH_INTN
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
   logic  packet_enable;
   logic [63:0] packet_timer;

   // if simulating, send packets more often
`ifdef XILINX_SIMULATOR
   localparam packet_max = 5000;
`else
   localparam packet_max = 1_000_000;
`endif
   parameter PACKET_PAYLOAD_BYTES = 128;

   // increment the timer and create an enable pulse when reaching max
   always_ff@(posedge eth_clk) begin
      if (eth_rst == 1) begin
         packet_timer <= 0;
         packet_enable <= 0;

      end
      else begin
         packet_enable <= 0;

         if (packet_timer == packet_max) begin
            packet_timer <= 0;
            packet_enable <= 1;

         end
         else begin
            packet_timer <= packet_timer + 1;
         end
      end
   end

   logic [7:0] s_axis_tdata;
   logic       s_axis_tvalid;
   logic       s_axis_tready;
   assign s_axis_tdata = packet_timer[7:0];
   assign s_axis_tvalid = packet_timer < PACKET_PAYLOAD_BYTES ? 1 : 0;

   packet_gen
     #(
       .PACKET_PAYLOAD_BYTES(PACKET_PAYLOAD_BYTES),
       .DEST_MAC(48'h080027fbdd66)
       )
 packet_gen_i
     (
      .clk(eth_clk),
      .rst(eth_rst),
      .s_axis_tdata(s_axis_tdata),
      .s_axis_tvalid(s_axis_tvalid),
      .s_axis_tready(),
      .tx_en(ETH_TXEN),
      .txd(ETH_TXD)
      );


endmodule
