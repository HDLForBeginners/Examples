`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 18.09.2021 12:06:18
// Design Name: 
// Module Name: led_flash
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


module led_flash(
    input clk,
    input rst_n,
    output led
    );
    
    parameter [63:0] CLK_RATE = 100000000;
    parameter [63:0]  FLASH_RATE_ON_MS = 1000;
    parameter [63:0]  FLASH_RATE_OFF_MS = 1000;    
    
    parameter [63:0]  FLASH_RATE_ON_CYCLES = CLK_RATE*FLASH_RATE_ON_MS/1000;
    parameter [63:0]  FLASH_RATE_OFF_CYCLES = CLK_RATE*FLASH_RATE_OFF_MS/1000;
    
    logic [31:0] flash_counter;
    logic on_not_off_flag;
    
    
    
    always_ff@(posedge clk, negedge rst_n) begin
       if (rst_n == 0) begin
           flash_counter <= 0;
           on_not_off_flag <= 0;
           
       end
       else begin
           if (on_not_off_flag) begin
               if (flash_counter < FLASH_RATE_ON_CYCLES-1) begin
                   flash_counter <= flash_counter + 1;
                   
               end  
               else begin
                   flash_counter <= 0;
                   on_not_off_flag <= ~on_not_off_flag;
                   
               end
           end
           else begin
               if (flash_counter < FLASH_RATE_OFF_CYCLES-1) begin
                   flash_counter <= flash_counter + 1;
                   
               end  
               else begin
                   flash_counter <= 0;
                   on_not_off_flag <= ~on_not_off_flag;
               
               end
           end  
       end
    end
    
    assign led = on_not_off_flag;
    
    
    
    
endmodule
