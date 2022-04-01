`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 13.11.2021 14:32:12
// Design Name:
// Module Name: pdm_microphone
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


module pdm_microphone
  #(
    parameter INPUT_FREQ = 100000000,
    parameter PDM_FREQ = 2400000

    )
   (
    input         clk,
    input         rst,

    output [31:0] mic_data,
    output        mic_data_valid,


    output        M_CLK,
    input         M_DATA,
    output        M_LRSEL

    );

   logic [2:0]      m_data_q;
   logic            m_clk_rising;

   // triple register data into clk domain
   always_ff@(posedge clk) begin
      if (rst) begin
         m_data_q       <= 0;

      end
      else begin
         m_data_q[0]   <= M_DATA;
         m_data_q[2:1] <= m_data_q[1:0];

      end
   end

   // clock gen
   pdm_clk_gen
     #(
       .INPUT_FREQ(INPUT_FREQ),
       .OUTPUT_FREQ(PDM_FREQ)

       )
   pdm_clk_gen_i
     (
      .clk(clk),
      .rst(rst),

      .M_CLK(M_CLK),
      .m_clk_rising(m_clk_rising)

      );

   logic [31:0] cic_out_data;
   logic        cic_out_valid;

   cic_compiler_0 cic_compiler
     (
      .aclk(clk),                              // input wire aclk
      .s_axis_data_tdata({7'b0,m_data_q[2]}),    // input wire [7 : 0] s_axis_data_tdata
      .s_axis_data_tvalid(m_clk_rising),         // input wire s_axis_data_tvalid
      .s_axis_data_tready(),   // output wire s_axis_data_tready

      .m_axis_data_tdata(cic_out_data),    // output wire [39 : 0] m_axis_data_tdata
      .m_axis_data_tvalid(cic_out_valid)  // output wire m_axis_data_tvalid
      );


   assign M_LRSEL = 0;
   assign mic_data = cic_out_data;
   assign mic_data_valid = cic_out_valid;

endmodule
