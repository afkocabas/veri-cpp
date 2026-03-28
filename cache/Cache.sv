import CachePackage::*;

// Simple direct-mapped cache.

// The bus width is word_t, width of a word -- 32 in this implementation.

// The cache supports simultaneous read and write operations.
// If a read and write occur in the same cycle to the same address,
// the write takes priority and its data is forwarded to the read output.
module Cache (
    input logic res,
    input logic clock,
    input logic read_enable,

    input address_t read_address,
    input address_t write_address,

    input logic  write_enable,
    input word_t write_data,

    output word_t read_data,
    output logic  is_Hit
);

  // Internal Blocks:  {
  cacheblock_t  data           [NUM_OF_CACHE_LINES];
  tag_t         tag            [NUM_OF_CACHE_LINES];
  valid_t       valid          [NUM_OF_CACHE_LINES];

  offset_t      rd_offset_in;
  offset_t      wr_offset_in;

  tag_t         rd_tag_in;
  tag_t         wr_tag_in;

  index_t       rd_index_in;
  index_t       wr_index_in;

  word_select_t rd_word_select;
  word_select_t wr_word_select;

  cacheblock_t  rdata;
  cacheblock_t  new_block;

  // ------------------ }

  // Assignments:     {

  // Read fields
  assign rd_offset_in   = read_address[OFFSET_MSB:OFFSET_LSB];
  assign rd_tag_in      = read_address[TAG_MSB:TAG_LSB];
  assign rd_index_in    = read_address[INDEX_MSB:INDEX_LSB];
  assign rd_word_select = rd_offset_in[WORD_SELECT_MSB:WORD_SELECT_LSB];

  assign rdata          = data[rd_index_in];

  // Write fields
  assign wr_offset_in   = write_address[OFFSET_MSB:OFFSET_LSB];
  assign wr_tag_in      = write_address[TAG_MSB:TAG_LSB];
  assign wr_index_in    = write_address[INDEX_MSB:INDEX_LSB];
  assign wr_word_select = wr_offset_in[WORD_SELECT_MSB:WORD_SELECT_LSB];

  // ---------------- }


  always_ff @(posedge clock) begin : reading
    // Reset logic goes here
    if (res) begin
      is_Hit <= '0;
      read_data <= '0;
    end else begin
      if (read_enable) begin
        if (write_enable && write_address == read_address) begin : simultaneous_read_write
          is_Hit <= 1;
          read_data <= write_data;
        end else begin : only_read
          if (valid[rd_index_in] && (tag[rd_index_in] == rd_tag_in)) begin  // Cache hit
            is_Hit <= 1;
            read_data <= getWordFromCacheBlock(rdata, rd_word_select);
          end else begin  // Cache miss.
            is_Hit <= 0;
          end
        end
        // Clear output signals
      end else begin
        is_Hit <= 0;
        read_data <= '0;
      end
    end
  end

  always_ff @(posedge clock) begin : writing
    if (res) begin
      valid <= '{default: 0};
      tag   <= '{default: 0};
      data  <= '{default: 0};
    end else begin
      // If write is enabled.
      if (write_enable) begin
        /*
        TODO: Simplified write-miss handling.
        On a write miss, this implementation allocates/overwrites the cache line locally,
        clears the line, and writes only the selected word, instead of fetching the full
        cache line from memory first.
        */
        if (valid[wr_index_in]) begin

          if (tag[wr_index_in] != wr_tag_in) begin  // Write miss, tag mismatch.

            // Set meta data
            tag[wr_index_in]   <= wr_tag_in;
            valid[wr_index_in] <= 1'b1;

            // Write the word
            data[wr_index_in]  <= getNewBlock('0, wr_word_select, write_data);

          end else begin  // Write hit, just adjust the corresponding word.
            data[wr_index_in][wr_word_select*WORD_SIZE_IN_BITS+:WORD_SIZE_IN_BITS] <= write_data;
          end
        end else begin  // Write miss, invalidated cache line.

          // Set meta data
          tag[wr_index_in]   <= wr_tag_in;
          valid[wr_index_in] <= 1'b1;

          // Write the word
          data[wr_index_in]  <= getNewBlock('0, wr_word_select, write_data);

        end
      end
    end
  end
endmodule
