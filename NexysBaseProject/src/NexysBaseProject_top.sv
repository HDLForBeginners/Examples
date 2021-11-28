//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 14.07.2021 18:18:52
// Design Name:
// Module Name: NexysBaseProject_top
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

`include "../src/version.vh"

module NexysBaseProject_top
   (
    input         CLK,
    input         RST_N,

    // // Switches
    // input [15:0]  SW,
     input         BTNC,
    // input         BTNU,
    // input         BTNL,
    // input         BTNR,
    // input         BTND,

    // // PMOD headers
    // // Can be both inputs and outputs
    // // Set to input to be safe
    // input [10:1]  JA,
    // input [10:1]  JB,
    // input [10:1]  JC,
    // input [10:1]  JD,
    // input [4:1]   XA_N,
    // input [4:1]   XA_P,

    // // LEDs
    // output [15:0] LED,
    // output        LED16_B,
    // output        LED16_G,
    // output        LED16_R,
    // output        LED17_B,
    // output        LED17_G,
    // output        LED17_R,

    // //7 segment display
    // output        CA,
    // output        CB,
    // output        CC,
    // output        CD,
    // output        CE,
    // output        CF,
    // output        CG,
    // output        DP,
    // output [7:0]  AN,

    // // VGA
    // output [3:0]  VGA_R,
    // output [3:0]  VGA_G,
    // output [3:0]  VGA_B,
    // output        VGA_HS,
    // output        VGA_VS,

    // // SD Card
    // output        SD_RESET,
    // input         SD_CD,
    // inout         SD_SCK,
    // inout         SD_CMD,
    // inout [3:0]   SD_DAT,

    // // Accelerometer
    // input         ACL_MISO,
    // output        ACL_MOSI,
    // output        ACL_SCLK,
    // output        ACL_CSN,
    // input [2:1]   ACL_INT,

    // // Temperature Sensor
    // output        TMP_SCL,
    // inout         TMP_SDA,
    // input         TMP_INT,
    // input         TMP_CT,

    // // Microphone
    // output        M_CLK,
    // input         M_DATA,
    // output        M_LRSEL,

    // // PWM Audio Amplifier
    // output        AUD_PWM,
    // output        AUD_SD,

    // // UART
    // input         UART_TXD_IN,
    // input         UART_RTS,
    // output        UART_RXD_OUT,
    // output        UART_CTS,

    // // USB HID
    // inout         PS2_CLK,
    // inout         PS2_DATA,

    // // Ethernet
    // output        ETH_MDC,
    // inout         ETH_MDIO,
     output        ETH_RSTN,
    // inout         ETH_CRSDV,
    // input         ETH_RXERR,
    // inout [1:0]   ETH_RXD,
    // output        ETH_TXEN,
    // output [1:0]  ETH_TXD,
     output        ETH_REFCLK
    // input         ETH_INTN

    // // QSPI Flash
    // output        QSPI_CSN,
    // inout [3:0]   QSPI_DQ



    );

   // Reset Generate
   logic          rst;

   rst_gen rst_gen_i
     (
      .clk_in(CLK),
      .rst_in(~RST_N),
      .rst_out(rst)

     );

   // Ethernet clk and reset generate
   logic          eth_clk;
   logic          eth_rst;

   eth_rst_gen eth_rst_gen_i
     (
      .clk(CLK),
      .rst(rst),
      .eth_clk_out(eth_clk),
      .eth_rst_out(eth_rst),
      .ETH_REFCLK(ETH_REFCLK),
      .ETH_RSTN(ETH_RSTN)
      );

   // Debounce on buttons
   logic          btn_c_debounce;
   logic          btn_c_i;
   logic          count_en;

   debounce debounce_sw
     (
      .clk(clk),
      .rst(~rst_n),
      .sw_in(BTNC),
      .sw_out(btn_c_debounce)
      );

   edge_detect edge_detect_i
     (
      .clk(clk),
      .rst(~rst_n),
      .data_in(btn_c_debounce),
      .data_out(btn_c_i)
      );

endmodule
