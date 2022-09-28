import numpy
from matplotlib import pyplot as plt


fs = 3e6
f0 = 1e3
N = 2**14

w = 2*numpy.pi*f0/fs*numpy.arange(0,N)

stim = numpy.cos(w)+1

print(stim)

IMPULSE_HEIGHT = numpy.amax(stim)
THRESHOLD = IMPULSE_HEIGHT/2

output_pdm = numpy.zeros(N)
running_sum = 0

with open('pdm_stimulus.txt', 'w') as fd:
    for i, sample in enumerate(stim):
        running_sum = running_sum + sample
        if running_sum > THRESHOLD:
            running_sum = running_sum - IMPULSE_HEIGHT
            output_pdm[i] = 1

        fd.write(f"{int(output_pdm[i])}\n")


ax = plt.plot(output_pdm)
ax = plt.plot(stim)
plt.show()
