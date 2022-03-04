`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HdlForBeginners
// Engineer:
//
// Create Date: 13.11.2021 13:55:40
// Design Name:
// Module Name: packet_gen
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

import ethernet_header_pkg::*;

module packet_gen
  #(
    parameter SOURCE_MAC = 48'he86a64e7e830,
    parameter DEST_MAC = 48'h080027fbdd65,
    parameter MII_WIDTH = 2,
    parameter PACKET_PAYLOAD_BYTES = 64

    )
   (
    input                  clk,
    input                  rst,

    input [7:0]            s_axis_tdata,
    input                  s_axis_tvalid,
    output                 s_axis_tready,

    output                  tx_en,
    output [MII_WIDTH-1:0] txd
    );


   // header and state buffers
   ethernet_header header;
   logic [$bits(ethernet_header)-1 : 0] header_buffer;
   logic [7:0]                          data_buffer;
   logic [7*8-1:0]                      preamble_buffer;
   logic [1*8-1:0]                      sfd_buffer;
   logic [4*8-1:0]                      fcs;
   logic [4*8-1:0]                      fcs_buffer;

   // Number of bytes transferred in each stage
   localparam HEADER_BYTES = $bits(ethernet_header)/8;
   localparam DATA_BYTES = PACKET_PAYLOAD_BYTES;
   localparam WAIT_BYTES = 12;
   localparam SFD_BYTES = 1;
   localparam PREAMBLE_BYTES = 7;
   localparam FCS_BYTES = 4;

   // RMII interface is MII_WIDTH bits wide, so divide by MII_WIDTH to get the correct
   // number of iterations per each stage
   localparam HEADER_LENGTH = HEADER_BYTES*8/MII_WIDTH;
   localparam WAIT_LENGTH = WAIT_BYTES*8/MII_WIDTH;
   localparam SFD_LENGTH = SFD_BYTES*8/MII_WIDTH;
   localparam PREAMBLE_LENGTH = PREAMBLE_BYTES*8/MII_WIDTH;
   localparam FCS_LENGTH = FCS_BYTES*8/MII_WIDTH;
   localparam DATA_LENGTH = DATA_BYTES*8/MII_WIDTH;



   // State machine
   typedef enum                         {IDLE, PREAMBLE, SFD, HEADER, DATA, FCS, WAIT}  state_type;

   state_type current_state = IDLE;
   state_type next_state    = IDLE;

   // Data fifo
   logic                                fifo_full;
   logic                                fifo_empty;
   logic [11:0]                         fifo_count;
   logic [7:0]                          fifo_out;
   logic                                fifo_rd_en;

   // de-assert ready when fifo is full
   assign s_axis_tready = ~fifo_full;

   // Get header
   eth_header_gen
     #(
       .SOURCE_MAC(SOURCE_MAC),
       .DEST_MAC(DEST_MAC),
       .PACKET_PAYLOAD_BYTES(PACKET_PAYLOAD_BYTES)
       )
   eth_header_gen
     (
      .output_header(header)

      );

   data_fifo data_fifo_i
     (
      .clk(clk),
      .srst(rst),
      .din(s_axis_tdata),
      .wr_en(s_axis_tvalid & s_axis_tready),
      .rd_en(fifo_rd_en),
      .dout(fifo_out),
      .full(fifo_full),
      .empty(fifo_empty),
      .data_count(fifo_count)
      );


   // count the time spent in each state
   logic [31:0]                         state_counter;

   always @(posedge clk)
     begin
	    if(rst) begin
           state_counter  <= '0;

	    end
	    else begin
           if (current_state != next_state) begin
              state_counter  <= '0;

           end
           else begin
              // otherwise increment counter and shift buffer
              state_counter <= state_counter  + 'd1;
           end
	    end
     end

   // 3 process state machine
   // 1) decide which state to go into next
   always @(*)
     begin
        case (current_state)
          IDLE   :
            begin
               // If there's enough data in fifo
               if (fifo_count >= PACKET_PAYLOAD_BYTES) begin
                  next_state = PREAMBLE;

               end
               else begin
                  next_state = current_state;

               end
            end
          PREAMBLE:
            begin
               if (state_counter == PREAMBLE_LENGTH-1) begin
                  next_state = SFD;
               end
               else begin
                  next_state = current_state;

               end
            end
          SFD:
            begin
               if (state_counter == SFD_LENGTH-1) begin
                  next_state = HEADER;
               end
               else begin
                  next_state = current_state;

               end
            end
          HEADER  :
            begin
               if (state_counter == HEADER_LENGTH-1) begin
                  next_state = DATA;
               end
               else begin
                  next_state = current_state;

               end
            end
          DATA  :
            begin
               if (state_counter == DATA_LENGTH-1) begin
                  next_state = FCS;
               end
               else begin
                  next_state = current_state;

               end
            end
          FCS  :
            begin
               if (state_counter == FCS_LENGTH-1) begin
                  next_state = WAIT;
               end
               else begin
                  next_state = current_state;

               end
            end
          WAIT   :
            begin
               if (state_counter == WAIT_LENGTH-1) begin
                  next_state = IDLE;
               end
               else begin
                  next_state = current_state;

               end
            end
          default:
            next_state = current_state;
        endcase
     end

   //2) register into that state
   always @(posedge clk)
     begin
	    if(rst) begin
           current_state <= IDLE;
	    end
	    else begin
           current_state <= next_state;
	    end

     end


   // state dependant variables
   logic [MII_WIDTH-1:0]                          tx_data;
   logic                                          tx_valid;
   logic                                          fcs_en;
   logic                                          fcs_rst;

   //3) drive output according to state
   always @(*)
     begin
        case (current_state)
          IDLE   :
            begin
               tx_valid = 0;
               tx_data  = 0;
               fcs_en   = 0;
               fcs_rst   = 1;

            end
          PREAMBLE  :
            begin
               tx_valid = 1;
               tx_data  = preamble_buffer[MII_WIDTH-1:0];
               fcs_en   = 0;
               fcs_rst   = 0;

            end
          SFD  :
            begin
               tx_valid = 1;
               tx_data  = sfd_buffer[MII_WIDTH-1:0];
               fcs_en   = 0;
               fcs_rst   = 0;
            end
          HEADER  :
            begin
               tx_valid = 1;
               tx_data  = header_buffer[MII_WIDTH-1:0];
               fcs_en   = 1;
               fcs_rst   = 0;

            end
          DATA  :
            begin
               tx_valid = 1;
               tx_data  = data_buffer[MII_WIDTH-1:0];
               fcs_en   = 1;
               fcs_rst   = 0;

            end
          FCS:
            begin
               tx_valid = 1;
               tx_data  = fcs_buffer[MII_WIDTH-1:0];
               fcs_en   = 0;
               fcs_rst  = 0;

            end
          WAIT   :
            begin
               tx_valid = 0;
               tx_data  = 0;
               fcs_en   = 0;
               fcs_rst  = 0;

            end
        endcase
     end

   // populate and shift buffers according to state
   always_ff@(posedge clk) begin
      if (rst == 1) begin
         header_buffer   <= 0;
         preamble_buffer <= 0;
         fifo_rd_en      <= 0;

      end
      else begin
         fifo_rd_en      <= 0;

         // buffer loading
         if (current_state == IDLE) begin
            header_buffer   <= header;
            preamble_buffer <= 56'h55555555555555;
            sfd_buffer      <= 8'hd5;
         end
         // and fcs when it's available
         if (next_state == FCS && current_state != FCS) begin
            fcs_buffer <= fcs;
         end
         // and fcs when it's available
         if (next_state == DATA && current_state != DATA) begin
            data_buffer <= fifo_out;
            fifo_rd_en  <= 1;

         end

         // shift buffers during those states
         if (current_state == HEADER) begin
            header_buffer <= header_buffer >> MII_WIDTH;
         end
         if (current_state == PREAMBLE) begin
            preamble_buffer <= preamble_buffer >> MII_WIDTH;
         end
         if (current_state == SFD) begin
            sfd_buffer <= sfd_buffer >> MII_WIDTH;
         end
         if (current_state == DATA && next_state == DATA ) begin
            if (state_counter[1:0] == 3) begin
               data_buffer <= fifo_out;
               fifo_rd_en  <= 1;

            end
            else begin
               data_buffer <= data_buffer >> MII_WIDTH;
            end
         end
         if (current_state == FCS) begin
            fcs_buffer <= fcs_buffer >> MII_WIDTH;
         end
      end
   end

   // crc generator
   crc_gen crc_gen_i
     (
      .clk(clk),
      .rst(rst || fcs_rst),

      .data_in(tx_data),
      .crc_en(fcs_en),
      .crc_out(fcs)

      );

   //drive tx interfaces
    assign tx_en = tx_valid;
    assign txd = tx_data;

endmodule
