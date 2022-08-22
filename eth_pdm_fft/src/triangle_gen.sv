`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HDLForBeginners
// Engineer: Stacey
//
// Create Date: 14.07.2021 13:47:50
// Design Name: triangle_gen
// Module Name: triangle_gen
// Project Name: triangle_gen
// Target Devices:
// Tool Versions:
// Description:
// Increments a counter and and drives an output gpio pin
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module triangle_gen
  #(
    parameter WIDTH_POW2 = 10

    )
   (
    input                   clk,
    input                   rst,

    input                   triangle_out_ready,
    output [WIDTH_POW2-1:0] triangle_out,
    output                  triangle_out_valid,
    output                  triangle_out_last

    );

   // Initial value for the window counter
   localparam WINDOW_COUNTER_INITIAL = 2**(WIDTH_POW2-1);

   logic [WIDTH_POW2-1:0] window_counter;
   logic                  window_counter_valid;

   // Flag to check if we are counting down or up
   // This could be a state machine! But a flag will also do.
   // It is also a state machine, just not an explicit one.
   logic                        window_counter_down;
   logic                        window_done;

   assign window_done = ((window_counter == WINDOW_COUNTER_INITIAL) && ~window_counter_down) ? 1 : 0;

   // Valid when not reset
   assign window_counter_valid = ~rst;

   always_ff @(posedge clk)
     begin
	    if(rst) begin
           window_counter       <= WINDOW_COUNTER_INITIAL-1;
           window_counter_down  <= 1'b1;

	    end
	    else if (triangle_out_ready) begin
           if (window_counter_down) begin
              if (window_counter == 0) begin
                 // Done counting down, so switch direction
                 window_counter_down <= 0;
                 window_counter <= window_counter + 1;
              end
              else begin
                 // Otherwise, carry on down
                 window_counter <= window_counter - 1;
              end
           end
           else begin
              if (window_counter == WINDOW_COUNTER_INITIAL) begin
                 // Done counting up, so switch direction
                 window_counter_down <= 1;
                 window_counter <= window_counter - 1;

              end
              else begin
                 // Carry on up
                 window_counter <= window_counter + 1;

              end
           end


	    end
     end


   assign triangle_out = window_counter;
   assign triangle_out_valid = window_counter_valid;
   assign triangle_out_last = window_done;


endmodule
