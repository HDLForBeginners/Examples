`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.09.2021 12:30:56
// Design Name: 
// Module Name: led_flash_tb
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


module led_flash_tb(

    );
    
       logic clk = 0;
       logic rst = 1;
       
       // Clock definition
       localparam CLK_PERIOD = 10; // 100 Mhz (counter is in ns)
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
    

 led_flash 
 led_flash_i(
     .clk(clk),
     .rst_n(~rst),
     .led()
    );
endmodule
