`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.07.2021 18:18:52
// Design Name: 
// Module Name: simple_increment_tb
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

module lfsr_4bit_tb(

    );
    
    logic clk = 0;
    logic rst = 1;
    logic led;
    
    
    // Clock definition
    localparam CLK_PERIOD = 20000; // 50 Mhz (counter is in ps)
    localparam RST_COUNT = 10; //Clock cycles that reset is high
     
    always begin
        clk   = #(CLK_PERIOD/2) ~clk;
    end
       
    // reset definition
    initial begin
        rst = 1;
        #(RST_COUNT*CLK_PERIOD);
        @(posedge clk);
        rst = 0;
    end

    lfsr_4bit_top
    lfsr_4bit_top_i
    (
        .clk(clk),
        .rst(rst),
        .led(led)
        
        );
    
endmodule
