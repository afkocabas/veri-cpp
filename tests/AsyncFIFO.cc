#include "VAsyncFIFO.h"
#include <cstdint>
#include <cstdlib>
#include <memory>
#include <print>

// Definitions
#define WHP 2
#define RHP 4

// Typedefs
using FIFO_ITEM = uint8_t;

struct FIFO_TestBench {

  // Half Periods of the signals
  const static int write_half_period = WHP;
  const static int read_half_period  = RHP;

  // Design Under Test (DUT)
  std::unique_ptr<VAsyncFIFO> fifo;

  // Simulation clock counter for global domain
  vluint64_t sim_time = 0;

  // Previous clock histories to detect edges
  bool prev_write_clock = 0;
  bool prev_read_clock  = 0;

  // Clock domains for write and read operations
  void toggle_write();
  void toggle_read();

  // Global clock domain where default increment is 1.
  void global_tick(int cycles = 1);

  // Evaluates the module.
  void eval() const;

  // Holds reset for `cycles` cycles and deasserts.
  void reset(int cycles = 1);

  // Is write|read clock at positive edge
  bool is_write_posedge() const;
  bool is_read_posedge() const;

  // Saving previous read and write clocks
  void save_prev_read();
  void save_prev_write();

  // Wait helpers
  void wait_write_posedge();
  void wait_read_posedge();

  // Write and read operations
  void write(FIFO_ITEM data);
  FIFO_ITEM read();

  // Expectation functions
  void expect_equal(FIFO_ITEM actual, FIFO_ITEM expected, std::string message);
  void expect_full(bool full = true);
  void expect_empty(bool empty = true);
};

// FIFO_TestBench Function Definitions

/*
 WARN: For now, FIFO_TestBench::expect_equal exits when it fails to match actual and expected.
*/
inline void FIFO_TestBench::expect_equal(FIFO_ITEM actual, FIFO_ITEM expected, std::string message) {
  if (actual != expected) {
    std::println("Actual: %d, Expected: %d. %s\n", actual, expected, message.c_str());
    exit(1);
  }
};
inline void FIFO_TestBench::expect_full(bool full) { expect_equal(fifo->full, full, "FIFO full flag mismatch occured."); };
inline void FIFO_TestBench::expect_empty(bool empty) { expect_equal(fifo->empty, empty, "FIFO empty flag mismatch occured."); };

void FIFO_TestBench::wait_write_posedge() {
  do {
    global_tick(1);
  } while (!is_write_posedge());
};

void FIFO_TestBench::wait_read_posedge() {
  do {
    global_tick(1);
  } while (!is_read_posedge());
};

inline void FIFO_TestBench::toggle_write() { fifo->write_clk = !fifo->write_clk; };
inline void FIFO_TestBench::toggle_read() { fifo->read_clk = !fifo->read_clk; };

inline bool FIFO_TestBench::is_write_posedge() const { return prev_write_clock == 0 && fifo->write_clk == 1; }
inline bool FIFO_TestBench::is_read_posedge() const { return prev_read_clock == 0 && fifo->read_clk == 1; }

inline void FIFO_TestBench::save_prev_read() { prev_read_clock = fifo->read_clk; };
inline void FIFO_TestBench::save_prev_write() { prev_write_clock = fifo->write_clk; }

inline void FIFO_TestBench::eval() const { fifo->eval(); }

void FIFO_TestBench::global_tick(int cycles) {
  for (int i = 0; i < cycles; i++) {

    // Saving the previous state of DUT.
    save_prev_read();
    save_prev_write();

    // Check domains and evaluate
    if (sim_time % write_half_period == 0) toggle_write();
    if (sim_time % read_half_period == 0) toggle_read();
    eval();

    // Clocks
    sim_time++;
  }
}

void FIFO_TestBench::reset(int cycles) {

  fifo->write_clk  = 0;
  fifo->read_clk   = 0;
  fifo->res        = 1;
  fifo->read_en    = 0;
  fifo->write_en   = 0;
  fifo->write_data = 0;

  eval();

  global_tick(cycles);

  fifo->res = 0;
  eval();

  global_tick(cycles);
}

void FIFO_TestBench::write(FIFO_ITEM data) {

  fifo->write_en   = 1;
  fifo->write_data = data;

  wait_write_posedge();

  fifo->write_en = 0;
};

FIFO_ITEM FIFO_TestBench::read() {
  fifo->read_en = 1;

  wait_read_posedge();

  fifo->read_en = 0;

  return fifo->read_data;
}
