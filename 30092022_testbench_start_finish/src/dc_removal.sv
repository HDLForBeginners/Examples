`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 13.11.2021 14:32:12
// Design Name:
// Module Name: rst_gen
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


module dc_removal
  #(
    parameter DATA_WIDTH = 32
    )
   (
    input                   clk,
    input                   rst,
    input                   clk_en,

    // x in
    input [DATA_WIDTH-1:0]  s_axis_data_tdata,

    // y out
    output [DATA_WIDTH-1:0] m_axis_data_tdata


    );


   // Real-Time DC Removal
   // https://www.embedded.com/dsp-tricks-dc-removal/
   // Figure 13(b)


   // 973/1024 = 0.95
   localparam a_coeff_num = 973;
   localparam a_coeff_denom_pow2 = 10;


   logic signed [DATA_WIDTH-1:0] x_data;
   logic signed [DATA_WIDTH-1:0] y_data;
   logic signed [DATA_WIDTH-1:0] f_data;
   logic signed [DATA_WIDTH-1:0] f_data_q;
   logic signed [DATA_WIDTH-1:0] f_data_q_multa;

   // drive input signal
   assign x_data = s_axis_data_tdata;

   // f = x(n) + f_q*a
   assign f_data = x_data + f_data_q_multa;

   // fq*a = fq*a
   assign f_data_q_multa = f_data_q*a_coeff_num >>> a_coeff_denom_pow2;

   // y = f - f_q
   assign y_data = f_data - f_data_q;

   // f_q
   always_ff@(posedge clk) begin
      if (rst) begin
         f_data_q <= 0;

      end
      else if (clk_en) begin
         f_data_q <= f_data;

      end
   end

   assign m_axis_data_tdata = y_data;


endmodule
