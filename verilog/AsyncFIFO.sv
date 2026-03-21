module AsyncFIFO #(
    // Parameters
    parameter int DATA_WIDTH = 8,
    parameter int FIFO_DEPTH = 8,

    parameter int ADDR_WIDTH = $clog2(FIFO_DEPTH)
) (
    input logic res,
    input logic write_clk,
    input logic read_clk,

    // Enable signals
    input logic write_en,
    input logic read_en,

    // Write output
    input logic [DATA_WIDTH -1:0] write_data,

    // Read input
    output logic [DATA_WIDTH -1:0] read_data,

    // Full-Empty logic
    output logic full,
    output logic empty
);

  // Type Definitions
  typedef logic [DATA_WIDTH-1:0] data_t;
  typedef logic [ADDR_WIDTH:0] count_t;
  typedef logic [ADDR_WIDTH:0] ptr_t;

  // Interal Registers
  data_t FIFO[FIFO_DEPTH];

  // Pointers
  ptr_t write_ptr;
  ptr_t read_ptr;

  // Look-ahead Pointers
  ptr_t next_write_ptr;
  ptr_t next_read_ptr;

  // Gray Coded Pointers
  ptr_t write_ptr_gray;
  ptr_t read_ptr_gray;

  // Look-ahead Gray Coded Pointers
  ptr_t next_write_ptr_gray;
  ptr_t next_read_ptr_gray;

  // 2 Flip-Flop Registers for the Synchronization
  ptr_t ff1_r, ff2_r;
  ptr_t ff1_w, ff2_w;

  // Flipped Register for Write Domain
  ptr_t flipped_ff2_w;

  // Next Write Pointer to Raise Full & Empty Flags.
  assign next_write_ptr = write_ptr + 1;
  assign next_read_ptr = read_ptr + 1;

  // Gray Code Convertions
  assign write_ptr_gray = (write_ptr >> 1) ^ write_ptr;
  assign read_ptr_gray = (read_ptr >> 1) ^ read_ptr;

  assign next_write_ptr_gray = (next_write_ptr >> 1) ^ next_write_ptr;
  assign next_read_ptr_gray = (next_read_ptr >> 1) ^ next_read_ptr;

  // Checking Wrap Around in Write Domain
  assign flipped_ff2_w = ff1_w ^ ((ptr_t'(1) << ADDR_WIDTH) | (ptr_t'(1) << (ADDR_WIDTH - 1)));

  // Read Logic
  always_ff @(posedge read_clk) begin : reading
    if (res) begin
      empty <= 1;
      ff1_r <= 0;
      ff2_r <= 0;
      read_ptr <= 0;
    end else begin
      // 2 Flip-Flop Pass. Synchronized ff2 register should be used.
      ff2_r <= ff1_r;
      ff1_r <= write_ptr_gray;

      if (empty) begin
        if (ff2_r != read_ptr_gray) empty <= 0;
      end

      if (read_en && ff2_r != read_ptr_gray) begin

        if (ff2_r == next_read_ptr_gray) empty <= 1;
        else empty <= 0;

        read_data <= FIFO[read_ptr[ADDR_WIDTH-1:0]];
        read_ptr  <= read_ptr + 1;
      end

    end
  end

  // Write Logic
  always_ff @(posedge write_clk) begin : writing
    if (res) begin
      full <= 0;
      ff1_w <= 0;
      ff2_w <= 0;
      write_ptr <= 0;
    end else begin
      // 2 Flip-Flop Pass. Synchronized ff2 register should be used have to be used.
      ff2_w <= ff1_w;
      ff1_w <= read_ptr_gray;

      if (full) begin
        if (flipped_ff2_w != write_ptr_gray) full <= 0;
      end

      if (write_en && flipped_ff2_w != write_ptr_gray) begin

        if (flipped_ff2_w == next_write_ptr_gray) full <= 1;
        else full <= 0;

        FIFO[write_ptr[ADDR_WIDTH-1:0]] <= write_data;
        write_ptr <= write_ptr + 1;

      end
    end
  end

endmodule
