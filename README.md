\# FIR Accelerator — SystemVerilog



An ongoing digital design project building toward an eight-tap FIR filter.



\## Current implementation



\- Registered multiplier: two signed 16-bit inputs, signed 32-bit output.

\- Accumulator: signed 32-bit input, signed 35-bit running sum.

\- Both modules use an active-high synchronous reset.

\- The accumulator holds its value when enable is low.



The modules are currently tested independently. Filter integration is

the next development stage.



\## Verification



Self-checking SystemVerilog testbenches cover:



\- Multiplier: reset, positive and negative multiplication, registered

&#x20; output timing, boundary inputs, and multiplication by zero.

\- Accumulator: reset, signed accumulation, enable hold, and re-enabling.



\## Run the simulations



Developed using Vivado 2025.2.



1\. Open fir\_accelerator.xpr.

2\. Under Simulation Sources, set the desired testbench as Top:

&#x20;  - tb\_registered\_mult

&#x20;  - tb\_accumulator

3\. Run Behavioral Simulation.

4\. Check the Tcl Console for the testbench PASS message.



Close the current simulation before switching testbenches.



\## Next steps



\- Test accumulation beyond the 32-bit range.

\- Connect the multiplier and accumulator with appropriate control.

\- Implement the eight-tap FIR filter.

\- Add a Python reference model and automated verification.

\- Measure FPGA resource usage and timing.

