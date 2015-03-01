# Clock management
## Input
* 100 MHz waveform
* desired data rate (on output link) - selected using LCD and pushbuttons.
Frequency can be regulated within 1% error (using 2 significant digits).
It can be regulated from 1bit/s to 100 Mbit/s.
## Output
Waveform (50% duty cycle) with frequency as close to input as possible.

Output is not guaranteed to be equal to selected, but it will be close.
Error is big especialy in high frequencies (10Mbps+), due to limited capabilities of PLL's on FPGA.

## Internal operation
* external clock frequency is changed using 3 PLL's inside FPGA - each one with 8 different waves,
* using LUT's and multiplexers the correct waveform is selected,
* frequency is divided by integer (taken also from LUT) using counter,
* global clock buffer for frequeny output - to make sure it can run rest of FPGA's FF's.

LUT was calculated using Matlab script (in script folder) - it calculates which waveform to choose and divisor to have the closest match to input.

Frequency output vs requested:
![Frequency output vs requested](https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png "Frequency output vs requested")

Frequency error in %:
![Frequency error in %](https://github.com/adam-p/markdown-here/raw/master/src/common/images/icon48.png "Frequency error in %")

