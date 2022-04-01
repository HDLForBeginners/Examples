//////////////////////////////////////////////////////////////////////////////////
// Company: HDLForBeginners
// Engineer: Stacey
//
//////////////////////////////////////////////////////////////////////////////////

package ethernet_header_pkg;

   // Order matters
   // Must be defined in the file before being used.

   typedef struct      packed {
      // Ethernet Frame Header
      // no FCS, added later
      logic [1:0][7:0] eth_type_length;
      logic [5:0][7:0] mac_source;
      logic [5:0][7:0] mac_destination;
   } ethernet_header;



endpackage
