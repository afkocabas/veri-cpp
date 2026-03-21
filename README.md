# Verilator Setup

Base setup for developing SystemVerilog projects with Verilator and GTKWave.

## Features
- Generate headers and related translation units for developing test suites
- Compile `.sv` files and C++ test files (`.cc`) into executable binaries
- Generate waveform files for debugging

## Requirements
The `build.sh` script requires the following tools to be installed:

- `verilator`
- `gtkwave`
- `g++-14`

The C++ compiler and waveform type can be changed by modifying the corresponding environment variables in `build.sh`.

## Example
The `verilog` and `tests` directories include an `AndGate` example.

Since `obj_dir` is ignored, text editors or IDEs may report missing symbols. You can generate the required headers with:

`build.sh 0 verilog/AndGate.sv` 

This command emits the headers into `obj_dir`.
