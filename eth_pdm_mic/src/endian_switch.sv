// HDLbits example excercise "vector2"
// https://hdlbits.01xz.net/wiki/Vector2


module endian_switch
    #(
    parameter BYTE_SIZE = 8,
    parameter INPUT_BYTES = 4
    )
    (
    input [INPUT_BYTES*BYTE_SIZE-1:0] in,
    
    // both array and flat versions are driven
    // connect up as required
    output [INPUT_BYTES*BYTE_SIZE-1:0] out,
    output [INPUT_BYTES-1:0][BYTE_SIZE-1:0] out_array
    
    );//


   // $size gives number of bits in a vector
   localparam NUM_BYTES = INPUT_BYTES;

   // generate variable
   genvar             i;
   generate
      for (i = 1;i<=NUM_BYTES;i++) begin : endian_switch_for  // loop name
         // mimics the same format as intermediate, but this just automatically expands based on the constants
         assign out[i*BYTE_SIZE-1 -: BYTE_SIZE] = in[(NUM_BYTES-i+1)*BYTE_SIZE-1 -: BYTE_SIZE];
         
         // Array driven too
         // for arrays, they are indexed in the same order as declared
         // out_array is declared as [INPUT_BYTES-1:0][BYTE_SIZE-1:0] 
         // so assign out_array[x][y] 
         // x -> INPUT_BYTES dimension
         // y -> BYTE_SIZE dimension.
         // right-side dimensions can be left off 
         // assign out_array[x] is OK (as seen below), but there is no way to index [y] on its own
         // so be careful to get the order right according to the application.
         // else manual dimension switch is required
         assign out_array[i-1] = in[(NUM_BYTES-i+1)*BYTE_SIZE-1 -: BYTE_SIZE];
      end
   endgenerate




endmodule
