import cache_pkg::*;
import enums_pkg::*;

module cache_ctrl (
    cache_mem_if.master c_mem_if,
    cache_req_if.slave  c_req_if
);

  offset_t      offset_in;
  tag_t         tag_in;
  idx_t         idx_in;
  word_select_t word_select_in;

  // Current State Registers:
  cache_state_t state_q;

  cache_req_t   req_q;
  offset_t      offset_q;
  tag_t         tag_q;
  word_select_t word_select_q;
  word_t        wr_data_q;
  cacheblock_t  block_q;

  // Next State Signals
  cache_state_t state_d;
  cacheblock_t  block_d;
  cache_req_t   req_d;
  offset_t      offset_d;
  tag_t         tag_d;
  word_select_t word_select_d;
  word_t        wr_data_d;

  //---------------------------------//

  // Asssingments
  assign offset_in          = c_req_if.addr[OFFSET_MSB:OFFSET_LSB];
  assign tag_in             = c_req_if.addr[TAG_MSB:TAG_LSB];
  assign idx_in             = c_req_if.addr[INDEX_MSB:INDEX_LSB];
  assign word_select_in     = offset_in[WORD_SELECT_MSB:WORD_SELECT_LSB];

  assign c_req_if.req_ready = (state_q == IDLE);

  always_comb begin : state_logic
    // By default, the next state of the cache the current state.
    state_d = state_q;
    block_d = block_q;

    req_d = req_q;
    offset_d = offset_q;
    tag_d = tag_q;
    word_select_d = word_select_q;
    wr_data_d = wr_data_q;

    //  Memory interface signal clear
    c_mem_if.rd_idx = '0;

    c_mem_if.wr_en = '0;
    c_mem_if.wr_block = '0;

    // Cache request interface signal clear
    c_req_if.is_hit = '0;
    c_req_if.res_valid = '0;

    unique case (state_q)
      IDLE: begin
        if (c_req_if.req_valid) begin
          c_mem_if.rd_idx = idx_in;
          state_d = LOOKUP;

          req_d = c_req_if.req;
          offset_d = offset_in;
          tag_d = tag_in;
          word_select_d = word_select_in;
          wr_data_d = c_req_if.wr_data;
        end
      end
      LOOKUP: begin
        if (!c_mem_if.valid) begin
          state_d = LOOKUP;
        end else if (c_mem_if.valid && tag_q == c_mem_if.tag) begin
          state_d = HIT;
          block_d = c_mem_if.block;
        end else begin
          state_d = MISS;
        end
      end
      MISS: begin
        // TODO: Just report that to the CPU for now, no refill state.
        c_req_if.is_hit = '0;
        c_req_if.res_valid = '0;
        state_d = IDLE;
      end
      HIT: begin
        c_req_if.is_hit = 1'b1;
        c_req_if.res_valid = 1'b1;
        state_d = IDLE;
        if (req_q == READ) begin : read_hit
          c_req_if.rd_data   = getWordFromCacheBlock(block_q, word_select_q);
          c_req_if.res_valid = 1'b1;
        end else if (req_q == WRITE) begin : write_hit
          c_mem_if.wr_en = 1'b1;
          c_mem_if.wr_block = getNewBlock(block_q, word_select_q, wr_data_q);
        end
      end
    endcase
  end

  // Supports asynchronous reset
  always_ff @(posedge c_req_if.clk or posedge c_req_if.rst) begin : ctrl_handle
    if (c_req_if.rst) begin
      state_q <= IDLE;
      req_q <= READ;
      offset_q <= '0;
      tag_q <= '0;
      word_select_q <= '0;
      block_q <= '0;
      wr_data_q <= '0;
    end else begin
      state_q <= state_d;
      block_q <= block_d;
      req_q <= req_d;
      offset_q <= offset_d;
      tag_q <= tag_d;
      word_select_q <= word_select_d;
      wr_data_q <= wr_data_d;
    end
  end
endmodule
