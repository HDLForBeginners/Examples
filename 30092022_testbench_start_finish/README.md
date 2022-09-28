

This code is companion code for the video "Reading from and writing to file: My PDM testbench from start to finish"
https://youtu.be/PGTaECnh7ZA


To run this code, download and install Vivado 2021.1 or higher from here
https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/2021-1.html

You need to register and fill in a form, but the download is free.

Once installed, open and go to Tools -> Run Tcl Script

Navigate to 30_sep_2022_testbench_start_finish.tcl in the same directory as this readme file.

Once it is finished running, check for errors in the Tcl Console window tab on the bottom left.

Click Simultion -> Run Simulation -> Run Behavioural Simulation on the left

Select the module of interest in the "Scope" window, and the signals of interest in the "Objects" window, and drag accross to the simulation waveform viewer.

Click the Play button (blue triangle button) to run the simulation.

Folder breakdown:
py: Python code
src: synthesizable SystemVerilog code
tb: testbench SystemVerilog code
xdc: constraints
ip: IP cores
