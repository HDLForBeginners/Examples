import numpy as np
from scipy import signal
import matplotlib.pyplot as plt
sr = 3000
w, h = signal.freqz(b=[-0.5,2, -0.5], a=1)
x = w * sr * 1.0 / (2 * np.pi)
y = 20 * np.log10(abs(h))
plt.figure(figsize=(10,5))
plt.semilogx(x, y)
plt.ylabel('Amplitude [dB]')
plt.xlabel('Frequency [Hz]')
plt.title('Frequency response')
plt.grid(which='both', linestyle='-', color='grey')
plt.xticks([20, 50, 100, 200, 500, 1000, 2000, 5000, 10000, 20000], ["20", "50", "100", "200", "500", "1K", "2K", "5K", "10K", "20K"])
plt.show()

#from https://dsp.stackexchange.com/questions/49009/get-the-frequency-response-curve-from-fir-filter-coefficients-sampling-rate
