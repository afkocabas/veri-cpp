# Verilator Setup

Base setup for developing SystemVerilog projects with Verilator and GTKWave.

## Features
- Generate headers and related translation units for developing test suites
- Compile `.sv` files and C++ test files (`.cc`) into executable binaries
- Generate waveform files for debugging

## Requirements
The `build.sh` script requires the following tools to be installed:

- `verilator`
- `gtkwave` (By default, the script tries to generate waveforms.)
- `g++-14`

The C++ compiler, C++ standard, compilation flags and waveform type can be changed by modifying the corresponding environment variables in `build.sh`.

## Use & Example
The `verilog` and `tests` directories include an `AndGate` example.

Since `obj_dir` is ignored, text editors or IDEs may report missing symbols. You can generate the required headers with:

`./build.sh 0 verilog/AndGate.sv` 

This command emits the headers into `obj_dir`. Header files can later be used to create verification suits in C++.

After tests being created, they can be used to generate final executable using following command:

`./build.sh 1 verilog/AndGate.sv tests/AndGate.cc`

This command emits binary executable named as `VAndGate`.

The script also supports  multiple `.sv` being passed, where the top level module is given as the last:

`./build.sh 1 file.sv file2.sv toplevel.sv TestSuit.cc`
