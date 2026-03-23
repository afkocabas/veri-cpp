#include <print>
#define FIFO_TESTBENCH_IMPLEMENTATION
#include "AsyncFIFO.hh"

enum class STATUS { SUCCESS = 0, FAIL = 1 };

// Function declarations
STATUS test_reset(FIFO_TestBench& fb);
STATUS test_single_read(FIFO_TestBench& fb, FIFO_ITEM expected);
STATUS test_single_write(FIFO_TestBench& fb, FIFO_ITEM item);
STATUS test_fill_until_full(FIFO_TestBench& fb);
STATUS test_drain_until_empty(FIFO_TestBench& fb);

// Function definitions
STATUS test_reset(FIFO_TestBench& fb) {
  std::println("[TEST] Reset test is issued.");
  fb.reset();
  fb.expect_empty();
  fb.expect_full(0);
  std::println("[SUCCESS]: Reset test passed.");

  return STATUS::SUCCESS;
}

STATUS test_single_read(FIFO_TestBench& fb, FIFO_ITEM expected) {
  std::println("[TEST] Single read test is issued.");
  FIFO_ITEM item = fb.read();
  fb.expect_equal(item, expected, "Failed to read c.");
  std::println("[SUCCESS]: Single read test passed.");

  return STATUS::SUCCESS;
};

STATUS test_single_write(FIFO_TestBench& fb, FIFO_ITEM item) {

  std::println("[TEST] Single write test is issued.");
  fb.write(item);
  // WARN: 25 here looks like a magic number. See why it works.
  fb.global_tick(25);
  fb.expect_empty(false);
  std::println("[SUCCESS]: Single write test passed.");

  return STATUS::SUCCESS;
};

int main(int argc, char* argv[]) {
  FIFO_TestBench fb;
  STATUS status;

  test_reset(fb);

  test_single_write(fb, 'c');

  test_single_read(fb, 'c');

  fb.global_tick(25);

  return 0;
}
