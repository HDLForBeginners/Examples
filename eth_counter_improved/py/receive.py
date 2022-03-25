import socket
import numpy

ETH_P_ALL=3 # not defined in socket module, sadly...
s=socket.socket(socket.AF_PACKET, socket.SOCK_RAW, socket.htons(ETH_P_ALL))
s.bind(("enp0s8", 0))

fpga_src_dest = b"\x08\x00\x27\xfb\xdd\x66\xe8\x6a\x64\xe7\xe8\x30"

with open("test.bin","wb") as f:
    for i in numpy.arange(1,1000):
        r=s.recv(2000)
        # Only receive packets from FPGA
        if r[0:12]==fpga_src_dest:
            # Trim off header
            f.write(r[14:])


with open("test.bin","rb") as f:
    a = numpy.fromfile(f, dtype='>i4')

a_diff = numpy.diff(a)

if (a_diff==1).all():
    print("All values are strictly increasing by 1 each time!")
else:
    print("ERROR! All values are NOT strictly increasing by 1 each time!")

    # If there are discontinuities, Check they are on packet boundaries
    a_diff_indices = numpy.where(a_diff > 1)

    # Each packet is 128 32b words
    #a_diff_indices should always be divisible by 128
    # add 1 because the diff chops off the first value
    packet_offsets = (a_diff_indices[0]+1)%128
    packet_numbers = (a_diff_indices[0]+1)//128


    print(f"Packets containing discontinuities: {packet_numbers}")
    print(f"Packets discontinuity locations: {packet_offsets}")
    if (packet_offsets==0).all():
        print("All discontinuities are at packet boundaries!")
    else:
        print("ERROR! Some discontinuities mid-packet!")
