#define LOG
#define FIFO_TESTBENCH_IMPLEMENTATION
#include "AsyncFIFO.hh"
#include <print>
#include <queue>

enum class STATUS { SUCCESS = 0, FAIL = 1 };

// Software model
using SW_FIFO = std::queue<FIFO_ITEM>;

// Function declarations
STATUS test_reset(FIFO_TestBench& fb);
STATUS test_single_read(FIFO_TestBench& fb, FIFO_ITEM expected);
STATUS test_first_write(FIFO_TestBench& fb, FIFO_ITEM item);
STATUS test_fill_until_full(FIFO_TestBench& fb);
STATUS test_drain_until_empty(FIFO_TestBench& fb);
STATUS test_fill_until_full(FIFO_TestBench& fb);

// Function definitions

STATUS test_fill_until_full(FIFO_TestBench& fb, SW_FIFO& swf) {
  // Write items in order
  int size = swf.size();
  for (int i = 0; i < size; i++) {
    FIFO_ITEM item = swf.front();
    fb.write(item);
    swf.pop();
  }

  // Expect FIFO to be full
  fb.expect_full();

  std::println("[SUCCESS]: Fill until full test passed.");

  return STATUS::SUCCESS;
};

STATUS test_reset(FIFO_TestBench& fb) {
  std::println("[TEST]: Reset test is issued.");
  fb.reset();
  fb.expect_empty();
  fb.expect_full(0);
  std::println("[SUCCESS]: Reset test passed.");

  return STATUS::SUCCESS;
}

STATUS test_single_read(FIFO_TestBench& fb, FIFO_ITEM expected) {
  std::println("[TEST]: Single read test is issued.");
  FIFO_ITEM item = fb.read();
  fb.expect_equal(item, expected, "Failed to read the element expected.");
  std::println("[SUCCESS]: Single read test passed.");

  return STATUS::SUCCESS;
};

STATUS test_first_write(FIFO_TestBench& fb, FIFO_ITEM item) {

  std::println("[TEST]: Single write test is issued.");
  fb.write(item);
  fb.wait_read_posedge(3);
  fb.expect_empty(false);
  std::println("[SUCCESS]: First write test passed.");

  return STATUS::SUCCESS;
};

int main(int argc, char* argv[]) {
  FIFO_TestBench fb;
  STATUS status;
  SW_FIFO swf;

  for (int i = 0; i < 8; i++)
    swf.push('a' + i);

  test_reset(fb);

  test_first_write(fb, 'c');
  test_single_read(fb, 'c');

  test_fill_until_full(fb, swf);

  return 0;
}
