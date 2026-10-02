# FIR Accelerator — SystemVerilog

An eight-tap FIR filter implemented in SystemVerilog using a shared
multiply–accumulate datapath. The current configuration computes an
eight-sample moving average.

This project explores signed arithmetic, pipeline timing, finite-state
machine control, and self-checking RTL verification.

## Filter operation

For each accepted input sample, the filter computes:

y[n] = (x[n] + x[n-1] + ... + x[n-7]) / 8

The sample history starts at zero after reset. One multiplier and
accumulator process the eight taps sequentially.

## Current implementation

- `registered_mult`: signed 16 × 16-bit multiplication with a registered
  32-bit output.
- `accumulator`: signed 35-bit running sum with enable and synchronous clear.
- `sample_delay_line`: stores the eight most recent accepted 16-bit samples.
- `mac_unit`: connects the multiplier and accumulator, aligning product
  validity with the registered product.
- `fir_controller`: sequences sample loading, accumulator clearing,
  eight tap operations, pipeline draining, and result capture.
- `fir_top`: integrates the datapath and controller.

All sequential modules use an active-high synchronous reset.
Clearing the MAC resets its sum and discards pending products.

## Interface and numeric format

An input is accepted on a rising clock edge when both `in_valid` and
`in_ready` are high. The filter processes one output at a time.

`out_valid` pulses for one clock cycle when a new result is available.
`y_out` holds the result until the next output. There is no output
backpressure interface.

| Signal/value | Format |
|---|---|
| `x_in` | Signed 16-bit integer |
| Coefficient | Signed 16-bit value scaled by 2^15 |
| Product | Signed 32-bit value |
| `y_out` | Signed 35-bit value scaled by 2^15 |

Each coefficient is currently `4096`, representing `4096 / 32768 = 1/8`.

To interpret the output:

```text
output value = signed(y_out) / 32768
```

For example, a raw output of `327680` represents `10`.
The output retains fractional precision; conversion to a 16-bit integer,
rounding, and saturation are not yet implemented.

## Verification

Self-checking SystemVerilog testbenches cover:

- **Multiplier:** reset, positive and negative multiplication, registered
  output timing, signed boundary inputs, and multiplication by zero.
- **Accumulator:** reset, signed accumulation, enable hold, and re-enabling.
- **Sample delay line:** sample ordering, enable hold, negative samples,
  and reset.
- **MAC:** valid-product timing, invalid-input gaps, consecutive valid
  inputs, idle hold, and clearing with products pending.
- **Integrated FIR:** impulse response, negative input, constant-input
  response, output-valid pulse duration, and output hold.

The integrated tests passed in behavioral simulation:

| Test | Expected interpreted output |
|---|---|
| Input `80`, followed by zeros | Eight outputs of `10`, then `0` |
| Input `-20` with zero history | `-2.5` |
| Repeated input `80` after reset | `10, 20, …, 80`, then remains `80` |

These are directed functional tests; randomized verification is planned.

## Run the simulations

Developed using **Vivado 2025.2**.
Project target: **Kintex-7 xc7k70tfbv676-1**.

1. Open `fir_accelerator.xpr`.
2. Under **Simulation Sources**, set the desired testbench as Top:
   - `tb_registered_mult`
   - `tb_accumulator`
   - `tb_sample_delay_line`
   - `tb_mac_unit`
   - `tb_fir_top`
3. Run **Behavioral Simulation**.
4. In the Tcl Console, enter:

   ```tcl
   run all
   ```

5. Check for the final PASS message. For the integrated testbench:

   ```text
   PASS: All full-filter checks passed.
   ```

The default 1000 ns simulation duration is too short for the complete
FIR test sequence. `run all` continues until the testbench finishes.

Close the current simulation before switching testbenches.

## Synthesis status

FPGA resource usage and timing have not yet been measured.
Use `fir_top` as the synthesis top.

The current coefficient is a power of two, so synthesis may replace
multiplication with fixed wiring shifts rather than use a DSP block.

## Next steps

- Run synthesis and inspect resource usage.
- Add clock constraints and evaluate implementation timing.
- Add a Python reference model and randomized comparison tests.
- Extend verification to signed limits and reset during processing.
- Support distinct coefficients for each tap.
- Define output rounding and saturation for a narrower interface.
- Automate simulation and document reproducible results.
