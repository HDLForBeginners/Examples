
# Create clock:
create_clock -name <clock_name> -period <period> [get_ports <clock port>]

# Pin Location
set_property PACKAGE_PIN <pin name> [get_ports <port>]

# IO Standard
# Example: set_property IOSTANDARD LVDS_25 [get_ports [list data_p* data_n*]]
set_property IOSTANDARD <IO standard> [get_ports <ports>]
      
