from matplotlib import pyplot as plt
import numpy

with open('output_mic_data.log', 'r') as fd:
   content = fd.read()

with open('output_mic_data_avg.log', 'r') as fd:
    content_avg = fd.read()

pdm_data = []
nums_avg = []

for x in content.split(','):
     pdm_data.append(int(x))

for x in content_avg.split(','):
     nums_avg.append(int(x))


N = 512
fs = 3e6/64

window = numpy.hanning(N)

fft_data = numpy.fft.fftshift(numpy.abs(numpy.fft.fft(pdm_data[0:N]*window)))
x_data = numpy.arange(-N/2,N/2)*fs*2/N


ax = plt.plot(x_data,fft_data)
plt.show()
