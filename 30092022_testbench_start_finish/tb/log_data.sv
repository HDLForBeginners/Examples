`timescale 1ps / 1ps


module log_data
  #(
    parameter FILENAME = "output.log",
    parameter LENGTH = 29

    )
   (
    input                     clk,
    input                     rst,
    input signed [LENGTH-1:0] data,
    input                     data_valid

    );


   integer                    output_err_file;

   initial begin
      output_err_file  = $fopen(FILENAME, "w");


   end


   always@(posedge clk) begin
      if (rst) begin

      end
      else begin
         if (data_valid) begin
            $fwrite(output_err_file,"%d,",data);
         end
      end
   end



endmodule
