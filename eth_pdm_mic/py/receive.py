import socket
import numpy
import wave
import soundfile as sf
import struct

from matplotlib import pyplot as plt

ETH_P_ALL=3 # not defined in socket module, sadly...
s=socket.socket(socket.AF_PACKET, socket.SOCK_RAW, socket.htons(ETH_P_ALL))
s.bind(("enp0s8", 0))

fpga_src_dest = b"\x08\x00\x27\xfb\xdd\x66\xe8\x6a\x64\xe7\xe8\x30"
sample_bytes = 4
sample_rate = 2.4e6//64


with open("test.bin","wb") as f:
    for i in numpy.arange(1,10000):
        r=s.recv(2000)
        # Only receive packets from FPGA
        if r[0:12]==fpga_src_dest:
            # Trim off header
            f.write(r[14:])



with open("test.bin","rb") as f:
    a = numpy.fromfile(f,">i4")

    a.astype("float32")

    # remove offset and normalise
    a = a-numpy.mean(a)
    a = a/numpy.amax(a)
    a = a*(2**((sample_bytes*8)-1))-1

    # convert back to int
    a = a.astype('<i4')

    # save to wav file
    with wave.open("output.wav", "w") as fa:
        # 2 Channels.
        fa.setnchannels(1)
        # 2 bytes per sample.
        fa.setsampwidth(sample_bytes)
        fa.setframerate(sample_rate)
        fa.writeframes(a)
