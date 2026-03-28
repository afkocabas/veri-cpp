import CachePackage::*;

// Simple direct-mapped cache.

// The bus width is word_t, width of a word -- 32 in this implementation.

// The cache supports simultaneous read and write operations.
// If a read and write occur in the same cycle to the same address,
// the write takes priority and its data is forwarded to the read output.
module Cache (
    input logic rst_i,
    input logic clk_i,
    input logic read_en_i,

    input address_t read_addr,
    input address_t write_addr,

    input logic  write_en_i,
    input word_t write_data_i,

    output word_t read_data_o,
    output logic  is_hit_o
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
  assign rd_offset_in   = read_addr[OFFSET_MSB:OFFSET_LSB];
  assign rd_tag_in      = read_addr[TAG_MSB:TAG_LSB];
  assign rd_index_in    = read_addr[INDEX_MSB:INDEX_LSB];
  assign rd_word_select = rd_offset_in[WORD_SELECT_MSB:WORD_SELECT_LSB];

  assign rdata          = data[rd_index_in];

  // Write fields
  assign wr_offset_in   = write_addr[OFFSET_MSB:OFFSET_LSB];
  assign wr_tag_in      = write_addr[TAG_MSB:TAG_LSB];
  assign wr_index_in    = write_addr[INDEX_MSB:INDEX_LSB];
  assign wr_word_select = wr_offset_in[WORD_SELECT_MSB:WORD_SELECT_LSB];

  // ---------------- }


  always_ff @(posedge clk_i) begin : reading
    // Reset logic goes here
    if (rst_i) begin
      is_hit_o <= '0;
      read_data_o <= '0;
    end else begin
      if (read_en_i) begin
        if (write_en_i && write_addr == read_addr) begin : simultaneous_read_write
          is_hit_o <= 1;
          read_data_o <= write_data_i;
        end else begin : only_read
          if (valid[rd_index_in] && (tag[rd_index_in] == rd_tag_in)) begin  // Cache hit
            is_hit_o <= 1;
            read_data_o <= getWordFromCacheBlock(rdata, rd_word_select);
          end else begin  // Cache miss.
            is_hit_o <= 0;
          end
        end
        // Clear output signals
      end else begin
        is_hit_o <= 0;
        read_data_o <= '0;
      end
    end
  end

  always_ff @(posedge clk_i) begin : writing
    if (rst_i) begin
      valid <= '{default: 0};
      tag   <= '{default: 0};
      data  <= '{default: 0};
    end else begin
      // If write is enabled.
      if (write_en_i) begin
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
            data[wr_index_in]  <= getNewBlock('0, wr_word_select, write_data_i);

          end else begin  // Write hit, just adjust the corresponding word.
            data[wr_index_in][wr_word_select*WORD_SIZE_IN_BITS+:WORD_SIZE_IN_BITS] <= write_data_i;
          end
        end else begin  // Write miss, invalidated cache line.

          // Set meta data
          tag[wr_index_in]   <= wr_tag_in;
          valid[wr_index_in] <= 1'b1;

          // Write the word
          data[wr_index_in]  <= getNewBlock('0, wr_word_select, write_data_i);

        end
      end
    end
  end
endmodule
