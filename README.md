# Verilator Setup

Base setup for developing SystemVerilog projects with Verilator and GTKWave.

## Features
- Generate headers and related translation units for developing test suites
- Compile `.sv` files and C++ test files (`.cc`) into executable binaries
- Generate waveform files for debugging

## Requirements
The `veri.sh` script requires the following tools to be installed:

- `verilator`
- `gtkwave` (By default, the script tries to generate waveforms.)
- `g++-14`

The C++ compiler, C++ standard, compilation flags and waveform type can be changed by modifying the corresponding environment variables in `veri.sh`.

## Use & Example
The repository includes several directories with examples. Supported options can be listed using:

`./veri.sh help`

### Generate Headers
`./veri.sh gen andGate/AndGate.sv` 

This command generates the headers into `obj_dir`. Header files can later be used to create verification suites in C++.

### Build Executable
After creating the tests, they can be used to generate final executable using following command:

`./veri.sh build andGate/AndGate.sv andGate/AndGate.cc`

This command generates binary executable named as `VAndGate`.

### Multiple Systemverilog Files as Arguments
The script also supports multiple `.sv` files. The top-level module must be provided last:

`./veri.sh build file.sv file2.sv toplevel.sv TestSuit.cc`

### Warnings
- The `obj_dir` directory is ignored in the repository, so IDEs or text editors may report missing symbols in `.cc` files.
- Required headers can be generated manually using the veri script with `gen` option.
