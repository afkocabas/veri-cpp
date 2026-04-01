package uart_pkg;

  parameter int DATA_W = 8;

  typedef logic [DATA_W - 1:0] data_t;
  typedef logic [31:0] cpb_t;

  typedef enum {
    IDLE,
    TRANSMISSION_START,
    DATA_TRANSMISSION,
    TRANSMISSION_END,
    WAIT_ACK
  } tx_state_t;

  typedef enum {
    RX_IDLE,
    RECIEVE_START,
    DATA_RECIEVE,
    RECIEVE_STOP,
    RX_WAIT_ACK
  } rx_state_t;

  // Parameters
  parameter logic START_BIT = 0;
  parameter logic STOP_BIT = 1;

  // Number of bits required for counter
  parameter int CNT_NBITS = $clog2(DATA_W);

  typedef logic [CNT_NBITS - 1:0] bit_idx_t;
  typedef logic [CNT_NBITS - 1:0] bit_cnt_t;

endpackage
