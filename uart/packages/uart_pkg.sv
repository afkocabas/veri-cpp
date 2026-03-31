package uart_pkg;

  typedef logic [7:0] data_t;
  typedef enum {
    IDLE,
    TRANSMISSION_START,
    DATA_TRANSMISSION,
    TRANSMISSION_END,
    WAIT_ACK
  } tx_state_t;

  // Parameters
  parameter logic START_BIT = 0;
  parameter logic STOP_BIT = 1;
  parameter int DATA_WIDTH = $bits(data_t);

  // Number of bits required for counter
  parameter int COUNTER_BITS = $clog2(DATA_WIDTH);

  typedef logic [COUNTER_BITS - 1:0] bit_idx_t;

endpackage
