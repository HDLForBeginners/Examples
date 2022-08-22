import socket
import struct
import numpy as np
from matplotlib import pyplot as plt
from matplotlib import animation

ETH_P_ALL=3 # not defined in socket module, sadly...
s=socket.socket(socket.AF_PACKET, socket.SOCK_RAW, socket.htons(ETH_P_ALL))
s.bind(("eth0", 0))

fpga_src_dest = b"\x08\x00\x27\xfb\xdd\x65\xe8\x6a\x64\xe7\xe8\x30"
sample_bytes = 4
sample_rate = 2.4e6//64

fig = plt.figure()
ax = plt.axes(xlim=(0, 256), ylim=(0, np.log( 2**28)))
line, = ax.plot([], [], lw=2)

# initialization function: plot the background of each frame
def init():
    line.set_data([], [])
    return line,


# animation function.  This is called sequentially
def animate(i):
    r=s.recv(2000)
    # Only receive packets from FPGA
    if r[0:12]==fpga_src_dest:
        x = np.arange(0,256)
        y = np.frombuffer(r[14:], ">i4")
        line.set_data(x, np.fft.fftshift(np.log(np.abs(y))))
        return line,

# call the animator.  blit=True means only re-draw the parts that have changed.
anim = animation.FuncAnimation(fig, animate, init_func=init,
                               frames=20000, interval=10)


plt.show()
