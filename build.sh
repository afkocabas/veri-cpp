#!/bin/bash

# Exporting the latest g++ compiler
export CXX=g++-14
export CC=gcc-14

# Flags to be passed to the c++ compiler used by verilator
COMPILER=verilator
FLAGS=" -std=c++23"
TARGET_DIR="obj_dir"

# Parsing the parameters passed.

# Usage function
function usage() {
  echo "[USAGE]: ${0} [\"0 TOP_LEVEL_MODULE\" to generate headers | \"1 TOP_LEVEL_MODULE TEST_BENCH_CC\" to get final executable]"
  exit 1
}

# Creates .h and .cpp files
function generateHeaders() {
  $COMPILER --cc $ALL_MODULES --top-module $BASE_NAME &&
    echo "[SUCCESS]: Headers generated successfully."
}

# WARN: It attempts to generate vaweforms by default.
function buildTestbenchExecutable() {
  $COMPILER --cc $ALL_MODULES --top-module $BASE_NAME --exe $TEST_BENCH_CC -Mdir $TARGET_DIR --trace &&
    make -C $TARGET_DIR -f $TOP_LEVEL_MAKE CXX="$CXX" CXXFLAGS+="$FLAGS" &&
    echo "[SUCCESS]: Top level module ${TOP_LEVEL_MODULE} and test bench ${TEST_BENCH_CC} compiled successfully." &&
    echo "[SUCCESS]: Executable ${EXE} emitted."
}

function parseArguments() {
  args=("$@")

  NUM_PARAMETERS=$#
  OPTION="${args[0]}"
  TEST_BENCH_CC="${args[$NUM_PARAMETERS-1]}"
  TOP_LEVEL_MODULE=""
  ALL_MODULES=""

  if [[ $OPTION == 0 ]]; then
    TOP_LEVEL_MODULE="${args[$NUM_PARAMETERS-1]}"
    ALL_MODULES="${args[@]:1}"
  else
    TOP_LEVEL_MODULE="${args[$NUM_PARAMETERS-2]}"
    ALL_MODULES=("${args[@]:1:${#args[@]}-2}")
  fi

  # Generating file names to be emitted.
  BASE_PATH=$(basename $TOP_LEVEL_MODULE)
  BASE_NAME="${BASE_PATH%.*}"
  EXE="V${BASE_NAME}"
  TOP_LEVEL_MAKE="${EXE}.mk"
}

# Main function
function main() {
  parseArguments "$@"

  case "$OPTION" in
  0)
    if [[ $# < 1 ]]; then
      usage
    fi
    generateHeaders
    ;;
  1)
    if [[ $# < 2 ]]; then
      usage
    fi
    buildTestbenchExecutable
    ;;
  *)
    usage
    ;;
  esac
}

# Passing all parameters to the main function as is.
main "$@"
