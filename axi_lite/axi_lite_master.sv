`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: HDLForBeginners
//
// Module Name: axi_lite_master
// Client Project: HDLForBeginners
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module axi_lite_master
  #(
    parameter integer AXI_ADDR_WIDTH = 32,
    parameter integer AXI_DATA_WIDTH = 32
    )
   (
    input                                init_transaction,

    input wire                           M_AXI_ACLK,
    input wire                           M_AXI_ARESETN,

    // aw
    output wire [AXI_ADDR_WIDTH-1 : 0]   M_AXI_AWADDR,
    output wire [2 : 0]                  M_AXI_AWPROT,
    output wire                          M_AXI_AWVALID,
    input wire                           M_AXI_AWREADY,

    // w
    output wire [AXI_DATA_WIDTH-1 : 0]   M_AXI_WDATA,
    output wire [AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB,
    output wire                          M_AXI_WVALID,
    input wire                           M_AXI_WREADY,

    // b resp
    input wire [1 : 0]                   M_AXI_BRESP,
    input wire                           M_AXI_BVALID,
    output wire                          M_AXI_BREADY,

    // ar
    output wire [AXI_ADDR_WIDTH-1 : 0]   M_AXI_ARADDR,
    output wire [2 : 0]                  M_AXI_ARPROT,
    output wire                          M_AXI_ARVALID,
    input wire                           M_AXI_ARREADY,

    // r
    input wire [AXI_DATA_WIDTH-1 : 0]    M_AXI_RDATA,
    input wire [1 : 0]                   M_AXI_RRESP,
    input wire                           M_AXI_RVALID,
    output wire                          M_AXI_RREADY

    );

   // CAPITALS reserved for parameters and external signals.
   // internal signals are lowercase

   // why not parameter? can be accessed outside the module using module_instance_i.HSIZE
   // I don't want that, so localparam
   // Why don't I want that?
   // Not all of my parameters are designed to be changed by people outside
   // (don't know what they're for, valid ranges, etc).
   // generally parameters should be at the top if they're designed to be changed by users outside the module.
   localparam HSIZE = 640;
   localparam VSIZE = 480;


   // only include here signals that I drive (outputs). Inputs are not included (used later)


   // Why do I go to the effort of connecting up all of my outputs to duplicate internal outputs?!
   // I do this because the output signals are wires. Wires cannot be driven in an always_ff block,
   // If I want to drive these signals in a always block, I need to connect them up to logic signals first.
   // This is because the outputs are strictly OUTPUT signals. I can't use those signals in if statements
   // or combinitorial logic.
   // AFAIK this is a quirk of verilog/the syntesis tool. I think SystemVerilog is better with this now
   // but I'm demonstrating it here because it's the foolproof way of working with outputs.

   // aw
   logic [AXI_ADDR_WIDTH-1 : 0]          axi_awaddr;
   logic                                 axi_awvalid;

   // assign outputs to top level signals
   assign M_AXI_AWADDR = axi_awaddr;
   assign M_AXI_AWVALID = axi_awvalid;
   assign M_AXI_AWPROT =  0; // what's this? demonstrate going to find the answer

   // w
   logic [AXI_DATA_WIDTH-1 : 0]          axi_wdata;
   logic [AXI_DATA_WIDTH/8-1 : 0]        axi_wstrb;
   logic                                 axi_wvalid;
   assign M_AXI_WSTRB = axi_wstrb;
   assign M_AXI_WVALID = axi_wvalid;
   assign M_AXI_WDATA = axi_wdata;

   // b
   logic                                 axi_bready;
   logic                                 axi_berror;
   assign M_AXI_BREADY = axi_bready;

   // ar
   logic [AXI_ADDR_WIDTH-1 : 0]          axi_araddr;
   logic                                 axi_arvalid;
   assign M_AXI_ARADDR = axi_araddr;
   assign M_AXI_ARVALID = axi_arvalid;
   assign M_AXI_ARPROT = 0;

   // r
   logic [AXI_DATA_WIDTH-1 : 0]          axi_rready;
   logic                                 axi_rerror;
   assign M_AXI_RREADY = axi_rready;


   // These are all single-word transactions, so no LAST is needed.
   // It's implied the last is 1.

   // Write is done when b interface acknowledges write
   logic                                 write_done;
   assign write_done = axi_bready & M_AXI_BVALID; // BVALID is an input here

   logic                                 read_done;
   assign read_done = axi_rready & M_AXI_RVALID; // RVALID is alsoan input here


   // Write interfaces
   logic                                 init_transaction_i;

   // edge detect on input_fsync
   always_ff @(posedge M_AXI_ACLK)
     begin
        init_transaction_i <= init_transaction;
     end

   // This is how we do an edge detect.
   // Init WAS low (the delayed version has ~) and NOW it is NOT (so it went from 0 to 1).
   // This is a 1cc edge detect
   logic start;
   assign start = (init_transaction & ~init_transaction_i) ? 1 : 0;


   // State machine
   // write to registers
   typedef enum {IDLE, WR_REG_VDMACR, WR_REG_MM2S_HSIZE, WR_REG_MM2S_VSIZE, RD_REG_VDMACR, RD_REG_MM2S_HSIZE, RD_REG_MM2S_VSIZE}  my_state;

   my_state current_state = IDLE;
   my_state next_state    = IDLE;

   logic        start_write;
   logic        start_read;

   always_comb
     begin
        start_write = 0;
        start_read = 0;
        next_state  = current_state;

        case (current_state)
          IDLE   :
            begin
               if (start) begin
                  next_state  = WR_REG_VDMACR;
                  start_write = 1;

               end
            end
          WR_REG_VDMACR  :
            begin
               if (write_done) begin
                  next_state  = WR_REG_MM2S_HSIZE;
                  start_write = 1;

               end
            end
          WR_REG_MM2S_HSIZE   :
            begin
               if (write_done) begin
                  next_state = WR_REG_MM2S_VSIZE;
                  start_write = 1;

               end
            end
          WR_REG_MM2S_VSIZE   :
            begin
               if (write_done) begin
                  next_state = RD_REG_VDMACR;
                  start_read = 1;

               end
            end
          RD_REG_VDMACR  :
            begin
               if (read_done) begin
                  next_state = RD_REG_MM2S_HSIZE;
                  start_read = 1;

               end
            end
          RD_REG_MM2S_HSIZE   :
            begin
               if (read_done) begin
                  next_state = RD_REG_MM2S_VSIZE;
                  start_read = 1;

               end
            end
          RD_REG_MM2S_VSIZE   :
            begin
               if (read_done) begin
                  next_state = IDLE;

               end
            end
          default:
            next_state = current_state;

        endcase
     end

   // Register into next state
   always_ff @(posedge M_AXI_ACLK)
     begin
	    if(~M_AXI_ARESETN) begin
           current_state <= IDLE;
	    end
	    else begin
           current_state <= next_state;
	    end
     end

   // Define addresses and data values

   //aw
   always_comb
     begin
        axi_awaddr                         <= 0;
        case (current_state)
          WR_REG_VDMACR  :      axi_awaddr <= 'h30;
          WR_REG_MM2S_HSIZE   : axi_awaddr <= 'hA4;
          WR_REG_MM2S_VSIZE   : axi_awaddr <= 'hA0;
          default : axi_awaddr             <= 0;
        endcase
     end

   //w
   always_comb
     begin
        axi_wdata                         <= 0;
        case (current_state)
          WR_REG_VDMACR  :      axi_wdata <= 'h03;
          WR_REG_MM2S_HSIZE   : axi_wdata <= HSIZE;
          WR_REG_MM2S_VSIZE   : axi_wdata <= VSIZE;
          default : axi_wdata             <= 0;
        endcase
     end

   //ar
   always_comb
     begin
        axi_araddr                         <= 0;
        case (current_state)
          RD_REG_VDMACR  :      axi_araddr <= 'h30;
          RD_REG_MM2S_HSIZE   : axi_araddr <= 'hA4;
          RD_REG_MM2S_VSIZE   : axi_araddr <= 'hA0;
          default : axi_araddr             <= 0;
        endcase
     end

   //r expected values
   logic [AXI_DATA_WIDTH-1 : 0]    rdata_expected;
   always_comb
     begin
        rdata_expected                         <= 0;
        case (current_state)
          RD_REG_VDMACR  :      rdata_expected <= 'h03;
          RD_REG_MM2S_HSIZE   : rdata_expected <= HSIZE;
          RD_REG_MM2S_VSIZE   : rdata_expected <= VSIZE;
          default : rdata_expected             <= 0;
        endcase
     end

   // Address write interface
   always_ff @(posedge M_AXI_ACLK)
     begin
        // during reset, valid is low
	    if (M_AXI_ARESETN == 0 )
	      begin
	         axi_awvalid <= 1'b0;
	      end
	    else
	      begin
             // drive valid high at start of write
	         if (start_write)
	           begin
	              axi_awvalid <= 1'b1;
	           end

             // Having the inputs as capitals and outputs as lowercase really helps
             // in code clarity
             // In this if statement, I can see that the READY signal came in from outside
             // and the valid signal was driven by me.
             // At a glance I can ensure that I'm driving the correct signal
             // And ensure I'm checking the correct input signal.
             // hold high until ready is asserted
	         if (M_AXI_AWREADY && axi_awvalid)
	           begin
	              axi_awvalid <= 1'b0;
	           end
	      end
     end

   // Data write interface
   always_ff @(posedge M_AXI_ACLK)
     begin
        // during reset, valid is low
	    if (M_AXI_ARESETN == 0 )
	      begin
	         axi_wvalid <= 1'b0;
             axi_wstrb  <= 0;

	      end
	    else
	      begin
             // drive high at start of write
	         if (start_write)
	           begin
	              axi_wvalid <= 1'b1;
                  axi_wstrb <= 4'b1111; // strb all 1s
	           end

             // hold high until ready is asserted
	         if (M_AXI_WREADY && axi_wvalid)
	           begin
	              axi_wvalid <= 1'b0;
                  axi_wstrb  <= 0;
	           end
	      end
     end

   // Response channel with error check
   always_ff @(posedge M_AXI_ACLK)
     begin
        // during reset, ready is low
	    if (M_AXI_ARESETN == 0)
	      begin
	         axi_bready <= 1'b0;
             axi_berror <= 0;

	      end
        else begin
           // always be ready for response
           axi_bready <= 1'b1;

           // check error
	       if (M_AXI_BVALID && axi_bready) begin
              if (M_AXI_BRESP > 0) begin
                 axi_berror <= 1;
              end
              else begin
                 axi_berror <= 0;

              end
           end
        end
     end


   // Address read interface
   always_ff @(posedge M_AXI_ACLK)
     begin
        // during reset, valid is low
	    if (M_AXI_ARESETN == 0 )
	      begin
	         axi_arvalid <= 1'b0;
	      end
	    else
	      begin
             // drive valid high at start of write
	         if (start_read)
	           begin
	              axi_arvalid <= 1'b1;
	           end

	         if (M_AXI_ARREADY && axi_arvalid)
	           begin
	              axi_arvalid <= 1'b0;
	           end
	      end
     end

   // data read interface with error check
   always_ff @(posedge M_AXI_ACLK)
     begin
        // during reset, ready is low
	    if (M_AXI_ARESETN == 0)
	      begin
	         axi_rready <= 1'b0;
             axi_rerror <= 0;

	      end
        else begin
           // always be ready for data
           axi_rready <= 1'b1;

           // check error
	       if (M_AXI_RVALID && axi_rready) begin
              // if response is > 0
              if (M_AXI_RRESP > 0) begin
                 axi_rerror <= 1;
              end
              // or if data isn't what we expect
              else if (M_AXI_RDATA != rdata_expected) begin
                 axi_rerror <= 1;

              end
              else begin
                 axi_rerror <= 0;

              end
           end
        end
     end


endmodule
