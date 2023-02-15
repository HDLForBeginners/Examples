`timescale 1ns/1ns

//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Stacey Rieck
//
// Create Date: 13.11.2021 14:32:12
// Design Name:
// Module Name: axi_lite_master_tb
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


module axi_lite_master_tb
  (   );

   logic CLK = 0;
   logic  RESET_N;

   localparam FREQUENCY = 50.0E6;
   localparam clk_period = (1/FREQUENCY)/1e-9;

   always begin
      CLK = #(clk_period/2) ~CLK;
   end

   initial
	 begin
        RESET_N=0;
		#100
          RESET_N=1;
	 end


   localparam AXI_ADDR_WIDTH = 32;
   localparam AXI_DATA_WIDTH = 32;

   wire [AXI_ADDR_WIDTH-1 : 0] M_AXI_AWADDR;
   wire [2 : 0]                M_AXI_AWPROT;
   wire                        M_AXI_AWVALID;
   wire                        M_AXI_AWREADY;

   // w
   wire [AXI_DATA_WIDTH-1 : 0] M_AXI_WDATA;
   wire [AXI_DATA_WIDTH/8-1 : 0] M_AXI_WSTRB;
   wire                          M_AXI_WVALID;
   wire                          M_AXI_WREADY;

   // b resp
   wire [1 : 0]                  M_AXI_BRESP;
   wire                          M_AXI_BVALID;
   wire                          M_AXI_BREADY;

   // ar
   wire [AXI_ADDR_WIDTH-1 : 0]   M_AXI_ARADDR;
   wire [2 : 0]                  M_AXI_ARPROT;
   wire                          M_AXI_ARVALID;
   wire                          M_AXI_ARREADY;

   // r
   wire [AXI_DATA_WIDTH-1 : 0]   M_AXI_RDATA;
   wire [1 : 0]                  M_AXI_RRESP;
   wire                          M_AXI_RVALID;
   wire                          M_AXI_RREADY;

   logic                         init_transaction;
   logic [31:0]                  init_counter;

   always_ff @(posedge CLK)
     begin
        if (~RESET_N) begin
           init_transaction <= 0;
           init_counter     <= 0;
        end
        else begin
           init_counter     <= init_counter+1;
           init_transaction <= 0;

           if (init_counter == 10) begin
              init_transaction <= 1;

           end
        end

     end

   axi_lite_master
     #(
       .AXI_ADDR_WIDTH(32),
       .AXI_DATA_WIDTH(32)
       )
   axi_lite_master_i
     (
      .init_transaction(init_transaction),

      .M_AXI_ACLK(CLK),
      .M_AXI_ARESETN(RESET_N),

      // aw
      .M_AXI_AWADDR(M_AXI_AWADDR),
      .M_AXI_AWPROT(M_AXI_AWPROT),
      .M_AXI_AWVALID(M_AXI_AWVALID),
      .M_AXI_AWREADY(M_AXI_AWREADY),

      // w
      .M_AXI_WDATA(M_AXI_WDATA),
      .M_AXI_WSTRB(M_AXI_WSTRB),
      .M_AXI_WVALID(M_AXI_WVALID),
      .M_AXI_WREADY(M_AXI_WREADY),

      // b resp
      .M_AXI_BRESP(M_AXI_BRESP),
      .M_AXI_BVALID(M_AXI_BVALID),
      .M_AXI_BREADY(M_AXI_BREADY),

      // ar
      .M_AXI_ARADDR(M_AXI_ARADDR),
      .M_AXI_ARPROT(M_AXI_ARPROT),
      .M_AXI_ARVALID(M_AXI_ARVALID),
      .M_AXI_ARREADY(M_AXI_ARREADY),

      // r
      .M_AXI_RDATA(M_AXI_RDATA),
      .M_AXI_RRESP(M_AXI_RRESP),
      .M_AXI_RVALID(M_AXI_RVALID),
      .M_AXI_RREADY(M_AXI_RREADY)

      );


   // Zynq PS wrapper
   // Initialises PS subsystem

   axi_vdma_0 axi_vdma_i
     (
      .s_axi_lite_aclk(CLK),        // input wire s_axi_lite_aclk
      .m_axi_mm2s_aclk(CLK),        // input wire m_axi_mm2s_aclk
      .m_axis_mm2s_aclk(CLK),      // input wire m_axis_mm2s_aclk
      .m_axi_s2mm_aclk(CLK),        // input wire m_axi_s2mm_aclk
      .s_axis_s2mm_aclk(CLK),      // input wire s_axis_s2mm_aclk
      .axi_resetn(RESET_N),                  // input wire axi_resetn
      .s_axi_lite_awvalid(M_AXI_AWVALID),  // input wire s_axi_lite_awvalid
      .s_axi_lite_awready(M_AXI_AWREADY),  // output wire s_axi_lite_awready
      .s_axi_lite_awaddr(M_AXI_AWADDR),    // input wire [8 : 0] s_axi_lite_awaddr
      .s_axi_lite_wvalid(M_AXI_WVALID),    // input wire s_axi_lite_wvalid
      .s_axi_lite_wready(M_AXI_WREADY),    // output wire s_axi_lite_wready
      .s_axi_lite_wdata(M_AXI_WDATA),      // input wire [31 : 0] s_axi_lite_wdata
      .s_axi_lite_bresp(M_AXI_BRESP),      // output wire [1 : 0] s_axi_lite_bresp
      .s_axi_lite_bvalid(M_AXI_BVALID),    // output wire s_axi_lite_bvalid
      .s_axi_lite_bready(M_AXI_BREADY),    // input wire s_axi_lite_bready
      .s_axi_lite_arvalid(M_AXI_ARVALID),  // input wire s_axi_lite_arvalid
      .s_axi_lite_arready(M_AXI_ARREADY),  // output wire s_axi_lite_arready
      .s_axi_lite_araddr(M_AXI_ARADDR),    // input wire [8 : 0] s_axi_lite_araddr
      .s_axi_lite_rvalid(M_AXI_RVALID),    // output wire s_axi_lite_rvalid
      .s_axi_lite_rready(M_AXI_RREADY),    // input wire s_axi_lite_rready
      .s_axi_lite_rdata(M_AXI_RDATA),      // output wire [31 : 0] s_axi_lite_rdata
      .s_axi_lite_rresp(M_AXI_RRESP)      // output wire [1 : 0] s_axi_lite_rresp
      );


endmodule
