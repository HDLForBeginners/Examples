`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HDLForBeginners
// Engineer: Stacey
//
// Create Date: 14.07.2021 13:47:50
// Design Name: parzen
// Module Name: parzen
// Project Name: parzen
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


module parzen
  #(
    parameter WINDOW_SIZE_POW2 = 10,
    parameter INTERNAL_FRAC = 16,
    parameter OUTPUT_INT = 1,
    parameter OUTPUT_FRAC = 16
    )
   (
    input                              clk,
    input                              rst,

    input                              window_out_ready,
    output [OUTPUT_INT-1:-OUTPUT_FRAC] window_out,
    output                             window_out_valid,
    output                             window_out_last

    );



   // Sizes
   // When multiplying, the sizes add.
   // B * B is B_SIZE + B_SIZE
   // B2 * B is B2_SIZE + B_SIZE;
   localparam B_INT  = WINDOW_SIZE_POW2;
   localparam B2_INT = B_INT + B_INT;
   localparam B3_INT = B2_INT + B_INT;
   localparam B_SCALED_INT = B_INT + 3;

   // When multiplying, the fractionals add with the same rules
   localparam B_FRAC  = INTERNAL_FRAC;
   localparam B2_FRAC = B_FRAC + B_FRAC;
   localparam B3_FRAC = B2_FRAC + B_FRAC;
   localparam B_SCALED_FRAC = B_FRAC;

   //Signals

   logic [WINDOW_SIZE_POW2-1:0]        triangle_q0;
   logic                               triangle_valid_q0;
   logic                               triangle_last_q0;
   logic [WINDOW_SIZE_POW2-1:0]        triangle_q1;
   logic                               triangle_valid_q1;
   logic                               triangle_last_q1;
   logic [WINDOW_SIZE_POW2-1:0]        triangle_q2;
   logic                               triangle_valid_q2;
   logic                               triangle_last_q2;
   logic [WINDOW_SIZE_POW2-1:0]        triangle_q3;
   logic                               triangle_valid_q3;
   logic                               triangle_last_q3;

   // also could be
   // logic [3:0][WINDOW_SIZE_POW2-1:0]  triangle;
   // logic [3:0]                        triangle_valid;
   // And indexed with
   // triangle[3] to indicate the q3 signal
   // triangle[3][2:0] to bit-slice the 3 lsbs of the q3 signal


   // I'm creating individual signals instead of using arrays
   // to keep it simple
   logic [B_INT-1:-B_FRAC]             abs_n_q0;
   logic                               abs_n_valid_q0;

   logic [B_INT-1:-B_FRAC]             b_q0;
   logic                               b_valid_q0;

   // Also need delayed versions of b
   logic [B_INT-1:-B_FRAC]             b_q1;
   logic                               b_valid_q1;
   logic [B_INT-1:-B_FRAC]             b_q2;
   logic                               b_valid_q2;

   logic [B2_INT-1:-B2_FRAC]           b2_q0;
   logic                               b2_valid_q0;

   // And Delayed version of b2
   logic [B2_INT-1:-B2_FRAC]           b2_q1;
   logic                               b2_valid_q1;
   logic [B2_INT-1:-B2_FRAC]           b2_q2;
   logic                               b2_valid_q2;

   logic [B3_INT-1:-B3_FRAC]           b3_q1;
   logic                               b3_valid_q1;

   logic [B3_INT-1:-B3_FRAC]           b3_q2;
   logic                               b3_valid_q2;

   // create scaled values
   logic [B_SCALED_INT-1:-B_SCALED_FRAC] c6b1_q2;
   logic [B_SCALED_INT-1:-B_SCALED_FRAC] c6b2_q2;
   logic [B_SCALED_INT-1:-B_SCALED_FRAC] c6b3_q2;
   logic [B_SCALED_INT-1:-B_SCALED_FRAC] c2b3_q2;
   logic                                 cnbn_valid_q2;

   logic [B_SCALED_INT-1:-B_SCALED_FRAC] f1_q2;
   logic [B_SCALED_INT-1:-B_SCALED_FRAC] f2_q2;
   logic                                 fn_valid_q2;

   logic signed [B_SCALED_INT-1:-B_SCALED_FRAC] f1_q3;
   logic signed [B_SCALED_INT-1:-B_SCALED_FRAC] f2_q3;
   logic                                        fn_valid_q3;


   logic [B_SCALED_INT-1:-B_SCALED_FRAC] one_const;
   logic [B_SCALED_INT-1:-B_SCALED_FRAC] two_const;

   // RULES FOR KEEPING SIGNALS IN SYNC
   // assign, the q value stays the same
   // always@(*) block, the q value stays the same
   // always@(clk) block, the q value goes up by one.
   // All operations must occur with the same q value signals!


   // Stage 0
   triangle_gen
     #(
       .WIDTH_POW2(WINDOW_SIZE_POW2)

       )
   triangle_gen_i
     (
      .clk(clk),
      .rst(rst),

      .triangle_out_ready(window_out_ready),
      .triangle_out(triangle_q0),
      .triangle_out_valid(triangle_valid_q0),
      .triangle_out_last(triangle_last_q0)

      );

   // abs_n
   assign abs_n_q0[B_INT-1:0] = triangle_q0;
   assign abs_n_q0[-1:-B_FRAC] = '0;
   assign abs_n_valid_q0 = triangle_valid_q0;


   //  b = {|n|}/{N/2} = |n| >> (N-1)
   // |n| is abs_n
   // N is WINDOW_SIZE_POW2
   assign b_q0 =  abs_n_q0 >>> (WINDOW_SIZE_POW2 - 1);
   assign b_valid_q0 = abs_n_valid_q0;


   assign b2_q0 = b_q0 * b_q0;
   assign b2_valid_q0 = b_valid_q0;


   // Stage 1
   // Use registered versions of b and b2 for b3
   assign b3_q1 = b_q1 * b2_q1;
   assign b3_valid_q1 = b_valid_q1 * b2_valid_q1;


   // Stage 2

   // Up to now, I've been working with full-scale numbers to create my b values
   // But I need to make them all B Size to combine

   assign c6b1_q2 = b_q2[B_INT-1:-B_FRAC]*6;
   assign c6b2_q2 = b2_q2[B_INT-1:-B_FRAC]*6;
   assign c6b3_q2 = b3_q2[B_INT-1:-B_FRAC]*6;
   assign c2b3_q2 = b3_q2[B_INT-1:-B_FRAC]*2;
   assign cnbn_valid_q2 = b3_valid_q2;



   // Polynomials

   assign one_const[B_SCALED_INT-1:0] = 1;
   assign one_const[-1:-B_SCALED_FRAC] = '0;

   assign two_const[B_SCALED_INT-1:0] = 2;
   assign two_const[-1:-B_SCALED_FRAC] = '0;

   assign f1_q2       = one_const + c6b3_q2  - c6b2_q2  ;
   assign f2_q2       = two_const + c6b2_q2  - c6b1_q2  - c2b3_q2 ;
   assign fn_valid_q2 = cnbn_valid_q2;

   // Stage 3
   assign window_out = !window_out_valid ? '0 :
                       (triangle_q3[WINDOW_SIZE_POW2-1:WINDOW_SIZE_POW2-2] > 0) ? f2_q3 :
                       f1_q3;
   assign window_out_valid = fn_valid_q3;
   assign window_out_last = triangle_last_q3;



   always_ff @(posedge clk)
     begin
        if(rst) begin
           triangle_q1      <= '0;
           triangle_q2      <= '0;
           triangle_q3      <= '0;
           triangle_last_q1 <= 0;
           triangle_last_q2 <= 0;
           triangle_last_q3 <= 0;

           b_q1             <= '0;
           b_valid_q1       <= '0;
           b_q2             <= '0;
           b_valid_q2       <= '0;
           b2_q1            <= '0;
           b2_valid_q1      <= '0;
           b2_q2            <= '0;
           b2_valid_q2      <= '0;
           b3_q2            <= '0;
           b3_valid_q2      <= '0;
           f1_q3            <= '0;
           f2_q3            <= '0;
           fn_valid_q3      <= '0;


        end
        else if (window_out_ready) begin
           triangle_q1 <= triangle_q0;
           triangle_q2 <= triangle_q1;
           triangle_q3 <= triangle_q2;
           triangle_last_q1 <= triangle_last_q0;
           triangle_last_q2 <= triangle_last_q1;
           triangle_last_q3 <= triangle_last_q2;
           b_q1        <= b_q0;
           b_valid_q1  <= b_valid_q0;
           b_q2        <= b_q1;
           b_valid_q2  <= b_valid_q1;
           b2_q1       <= b2_q0;
           b2_valid_q1 <= b2_valid_q0;
           b2_q2       <= b2_q1;
           b2_valid_q2 <= b2_valid_q1;
           b3_q2       <= b3_q1;
           b3_valid_q2 <= b3_valid_q1;
           f1_q3       <= f1_q2;
           f2_q3       <= f2_q2;
           fn_valid_q3 <= fn_valid_q2;

        end
     end


endmodule
