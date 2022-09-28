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


module pdm_clk_gen
  #(
    parameter INPUT_FREQ = 100000000,
    parameter OUTPUT_FREQ = 2_500_000 // 2.5M out

    )
   (
    input  clk,
    input  rst,

    output M_CLK,
    output m_clk_rising

    );

   logic   m_clk_rising_i;
   logic   m_clk_i;


   // generate clock
   // Clock wizard doesn't generate clocks < 5M.
   // for clocks < 5M, anything higher use the clock wizard
   // Why the clock wizard?
   // - The FPGA has dedocated clock routes that are designed specifically for clock signals
   // - These get the clocks where they need to go ASAP
   // - The tool knows these signals are clocks because of a create_clock constraint
   // - Or if the wizard was used to generate them
   // - This way the timing analyzer tool knows about them and can use them in the timing analysis

   // This clock is so slow that it doesn't need to be on the dedicated clock paths
   // All I am doing here is creating an output pulse on the rising edge of the clock
   // That is used in other logic. It behaves as an enable signal in the clk domain

   // M_CLK is taken off chip to the PDM microphone IC and is not used on the FPGA anywhere.


   localparam CLK_DIVIDE = INPUT_FREQ/OUTPUT_FREQ;

   // count clock samples
   logic [$clog2(CLK_DIVIDE)-1:0] clk_counter;

   always_ff@(posedge clk) begin
      if (rst) begin
         clk_counter    <= 0;
         m_clk_i        <= 0;
         m_clk_rising_i <= 0;

      end
      else begin
         m_clk_rising_i <= 0;

         if (clk_counter < (CLK_DIVIDE/2)-1) begin
            clk_counter <= clk_counter + 1;

         end
         else begin
            clk_counter    <= 0;
            m_clk_i        <= ~m_clk_i;
            m_clk_rising_i <= ~m_clk_i;

         end
      end
   end

   assign M_CLK = m_clk_i;
   assign m_clk_rising = m_clk_rising_i;


endmodule
