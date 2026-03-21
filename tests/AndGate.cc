#include "VAndGate.h"
#include "verilated_vcd_c.h"
#include <algorithm>
#include <cstdio>
#include <memory>
#include <print>

static vluint64_t sim_time = 0;

const static std::vector<std::pair<int, int>> inputs = {{0, 0}, {0, 1}, {1, 0}, {1, 1}};

void dump(VAndGate* dut, VerilatedVcdC* tfp) {
  dut->eval();
  tfp->dump(sim_time++);
}

int main(int argc, char* argv[]) {

  // Create DUT and tracer
  auto dut              = std::make_unique<VAndGate>();
  auto traceFilePointer = std::make_unique<VerilatedVcdC>();

  // Enable the tracing
  Verilated::traceEverOn(true);

  // Associate the trace with the design under test
  dut->trace(traceFilePointer.get(), 99);

  // Create the the vaweform file
  traceFilePointer->open("wave.vcd");

  std::for_each(inputs.begin(), inputs.end(), [&](std::pair<int, int> inputPair) {
    dut->i1 = inputPair.first;
    dut->i2 = inputPair.second;
    dut->eval();
    dump(dut.get(), traceFilePointer.get());
  });

  std::println("The result is {}", dut->o);

  return 0;
}
