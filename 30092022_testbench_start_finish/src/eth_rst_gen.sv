`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 13.11.2021 14:32:12
// Design Name:
// Module Name: eth_rst_gen
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


module eth_rst_gen(
    input clk,
    input rst,
    output eth_clk_out,
    output eth_rst_out,
    output ETH_REFCLK,
    output ETH_RSTN
    );

    logic locked;
    logic eth_rst;
    logic eth_clk;


    // 50M clk gen
  clk_wiz_0 gen_50M
   (
    .clk_out1(eth_clk),         // output clk_out1
    .clk_out2(ETH_REFCLK),     // output clk_out2
    .reset(rst),            // input reset
    .locked(locked),           // output locked
    .clk_in1(clk));         // input clk_in1


`ifdef XILINX_SIMULATOR
   // So simulation doesn't have to wait so long to come out of reset
   localparam WAIT_CYCLES_50M = 20;
`else
   // synthesis uses full 40ms
   localparam WAIT_CYCLES_50M = 2000000; // 40ms
`endif
    logic [31:0] wait_counter_50M;

    // Generate output reset signals in 50M domain
    always_ff@(posedge eth_clk) begin
        // remain in reset until global reset is released
        if (rst) begin
            eth_rst <= 1;
            wait_counter_50M <= 0;
        end
        else begin
            // PLL locked
            if (locked) begin
                // remain in rst till counter is done
                if (wait_counter_50M < WAIT_CYCLES_50M-1) begin
                    eth_rst <= 1;
                    wait_counter_50M <= wait_counter_50M + 1;
                end
                else begin
                    eth_rst <= 0;
                end
            end
            // PLL not locked. Remain in reset until locked
            else begin
                eth_rst <= 1;
                wait_counter_50M <= 0;


            end
        end
    end

    assign ETH_RSTN = ~eth_rst;
    assign eth_clk_out = eth_clk;
    assign eth_rst_out = eth_rst;

endmodule
