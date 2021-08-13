`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: HDLForBeginners
// Engineer: Stacey
//
// Create Date: 14.07.2021 13:47:50
// Design Name: uart_tx
// Module Name:
// Project Name: uart_tx
// Target Devices:
// Tool Versions:
// Description:
// transmits a supplied word over uart
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module uart_tx
  #(
    parameter CLKRATE = 100000000,
    parameter BAUD = 115200,
    parameter WORD_LENGTH = 8
    )
   (
    input 		    clk,
    input 		    rst,
    input [WORD_LENGTH-1:0] tx_data,
    input 		    tx_data_valid,
    output 		    tx_data_ready,
    output 		    UART_TX
    );

   // internal signals
   logic                    tx_data_ready_i;
   logic                    uart_tx_i = 1'b0;
   logic [WORD_LENGTH-1:0]  tx_data_i;


   // store tx_data_i when valid for use later
   always @(posedge clk)
     begin
	if(rst) begin
           tx_data_i <= '0;

	end
	else begin
           // don't store the data unless we're ready
           if (tx_data_valid & tx_data_ready_i) begin
              tx_data_i <= tx_data;

           end
	end
     end

   // Define our states
   typedef enum {IDLE, START, DATA, PARITY, STOP,WAIT}  my_state;

   my_state current_state = IDLE;
   my_state next_state    = IDLE;

   // Define tx signal constants
   localparam TX_IDLE = 1'b1;
   localparam TX_START = 1'b0;
   localparam TX_STOP = 1'b1;

   // counter parameters
   // count the baud
   localparam BAUD_COUNTER_MAX = CLKRATE/BAUD;
   localparam BAUD_COUNTER_SIZE = $clog2(BAUD_COUNTER_MAX);
   // count the data
   localparam DATA_COUNTER_MAX = WORD_LENGTH;
   localparam DATA_COUNTER_SIZE = $clog2(DATA_COUNTER_MAX);

   logic [BAUD_COUNTER_SIZE-1:0] uart_baud_counter;
   logic [DATA_COUNTER_SIZE-1:0] uart_data_counter;
   logic                         uart_baud_done;
   logic                         uart_data_done;

   // buffer to store tx data while shifting
   logic [WORD_LENGTH-1:0] 	 uart_data_shift_buffer;

   // UART Baud Clock
   always @(posedge clk)
     begin
	if(rst) begin
           uart_baud_counter <= '0;
	end
	else begin
           // Reset at state transition
           if (uart_baud_done) begin
              uart_baud_counter <= '0;

           end
           else begin
              uart_baud_counter <= uart_baud_counter + 'd1;

           end
	end
     end

   // baud clock is done
   assign uart_baud_done = (uart_baud_counter == BAUD_COUNTER_MAX-1) ? 1'b1 : 1'b0;

   // data counting and shifting
   always @(posedge clk)
     begin
	if(rst) begin
           uart_data_counter <= '0;
           uart_data_shift_buffer <= '0;

	end
	// note uart_baud_done is clk enable
	else if (uart_baud_done) begin
           // Reset at state transition
           if (current_state != next_state) begin
              uart_data_counter <= '0;
              uart_data_shift_buffer <= tx_data_i;

           end
           else begin
              // otherwise increment counter and shift buffer
              uart_data_counter <= uart_data_counter + 'd1;
              uart_data_shift_buffer <= uart_data_shift_buffer >> 1;
           end
	end
     end
   // uart_data_done indicates all bits are transmitted
   assign uart_data_done = (uart_data_counter == DATA_COUNTER_MAX-1) ? 1'b1 : 1'b0;

   // State Machine
   always @(*)
     begin
        case (current_state)
          IDLE   :
            begin
               if (tx_data_valid) begin
                  next_state = START;

               end
               else begin
                  next_state = current_state;

               end
            end
          START  :
            begin
               if (uart_baud_done) begin
                  next_state = DATA;
               end
               else begin
                  next_state = current_state;

               end
            end
          DATA   :
            begin
               if (uart_data_done & uart_baud_done) begin
                  next_state = PARITY;

               end
               else begin
                  next_state = current_state;

               end
            end
          PARITY :
            begin
               if (uart_baud_done) begin
                  next_state = STOP;
               end
               else begin
                  next_state = current_state;

               end
            end
          STOP   :
            begin
               if (uart_baud_done) begin
                  next_state = WAIT;
               end
               else begin
                  next_state = current_state;

               end
            end
          WAIT   :
            begin
               if (uart_baud_done) begin
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


   always @(posedge clk)
     begin
	if(rst) begin
           current_state <= IDLE;
	end
	else begin
           current_state <= next_state;
	end

     end

   always @(*)
     begin
        case (current_state)
          IDLE   :
            begin
               uart_tx_i = TX_IDLE;
            end
          START  :
            begin
               uart_tx_i = TX_START;
            end
          DATA   :
            begin
               uart_tx_i = uart_data_shift_buffer[0];
            end
          PARITY :
            begin
               uart_tx_i = ^tx_data_i;
            end
          STOP   :
            begin
               uart_tx_i = TX_STOP;

            end
          WAIT   :
            begin
               uart_tx_i = TX_IDLE;

            end
        endcase
     end

   assign tx_data_ready_i = (current_state == IDLE) ? 1'b1 : 1'b0;
   assign tx_data_ready = tx_data_ready_i;
   assign UART_TX = uart_tx_i;

   
   ////////////////////////////////////////////////////////////////////////////////
   ////////////////////////////////////////////////////////////////////////////////
   ////////////////////////////////////////////////////////////////////////////////
   //
   // Formal properties
   // {{{
   ////////////////////////////////////////////////////////////////////////////////
   ////////////////////////////////////////////////////////////////////////////////
   ////////////////////////////////////////////////////////////////////////////////
`ifdef	FORMAL
   // Register declarations, reset assertion
   // {{{
   reg	f_past_valid;
   reg [WORD_LENGTH-1:0] fv_data;

   initial	f_past_valid = 0;
   always @(posedge clk)
     f_past_valid <= 1;

   always @(*)
     if (!f_past_valid)
       assume(rst);
   // }}}
   ////////////////////////////////////////////////////////////////////////
   //
   // Input AXI-stream assumptions
   // {{{
   ////////////////////////////////////////////////////////////////////////
   //
   //
   always @(posedge clk)
     if (!f_past_valid || $past(rst))
       begin
	  assume(!tx_data_valid);
       end
     else if ($past(tx_data_valid && !tx_data_ready))
       begin
	  assume(tx_data_valid);
	  assume($stable(tx_data));
       end
   // }}}

   always @(*)
     if (f_past_valid)
       begin
	  assert(uart_data_counter < DATA_COUNTER_MAX);
	  assert(uart_baud_done == (uart_baud_counter == BAUD_COUNTER_MAX-1));
       end

   always @(*)
     if (f_past_valid)
       case(current_state)
	 IDLE:  assert(UART_TX);
	 START: assert(!UART_TX);
	 DATA:  begin
         end
	 PARITY: assert(UART_TX == ^tx_data_i);
	 STOP:  assert(UART_TX);
	 WAIT:  assert(UART_TX);
	 default: assert(0);
       endcase

   always @(*)
     if (f_past_valid)
       case(current_state)
	 DATA:  begin
	    assert(uart_data_counter < WORD_LENGTH);
	    assert(UART_TX == fv_data[uart_data_counter]);
	 end
	 default: begin end
       endcase

   always @(*)
     if (f_past_valid)
       assert(tx_data_ready == (current_state == IDLE));

   always @(posedge clk)
     if (tx_data_valid && tx_data_ready)
       fv_data <= tx_data;

   always @(*)
     if (f_past_valid && current_state != IDLE)
       assert(fv_data == tx_data_i);
   ////////////////////////////////////////////////////////////////////////
   //
   // Cover checks
   // {{{
   ////////////////////////////////////////////////////////////////////////
   //
   //

   reg	[2:0]	cvr_count;

   always @(posedge clk)
     if (rst)
       cvr_count <= 0;
     else if (tx_data_valid && tx_data_ready)
       begin
	  if (cvr_count == 0 && tx_data == 8'h01)
	    cvr_count <= 1;
	  else if (cvr_count == 1 && tx_data == 8'h7e)
	    cvr_count <= 2;
	  else if (cvr_count >= 2 && !(&cvr_count))
	    cvr_count <= cvr_count + 1;
       end

   always @(*)
     if (!rst)
       begin
	  cover(cvr_count == 1);
	  cover(cvr_count == 1 && current_state == START);
	  cover(cvr_count == 1 && current_state == DATA);
	  cover(cvr_count == 1 && current_state == PARITY);
	  cover(cvr_count == 1 && current_state == STOP);
	  cover(cvr_count == 1 && current_state == WAIT);
	  cover(cvr_count == 1 && current_state == IDLE);
	  cover(cvr_count == 2);
	  cover(cvr_count == 2 && current_state == START);
	  cover(cvr_count == 2 && current_state == DATA);		// @88
	  cover(cvr_count == 2 && current_state == PARITY);	// @149
	  cover(cvr_count == 2 && current_state == STOP);
	  cover(cvr_count == 2 && current_state == WAIT);
	  cover(cvr_count == 2 && current_state == IDLE);
	  cover(cvr_count == 3);
	  cover(cvr_count == 4);
       end
   // }}}
   // }}}
`endif
endmodule
