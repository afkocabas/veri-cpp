package cache_pkg;
  parameter int ADDRESS_SPACE_IN_BITS = 32;

  parameter int CPU_DATA_WIDTH_IN_BITS = 32;
  parameter int CPU_DATA_WIDTH_IN_BYTES = CPU_DATA_WIDTH_IN_BITS / 8;

  parameter int WORD_SIZE_IN_BYTES = CPU_DATA_WIDTH_IN_BYTES;
  parameter int WORD_SIZE_IN_BITS = WORD_SIZE_IN_BYTES * 8;

  parameter int CACHE_SIZE_IN_BYTES = 4 * 1024;
  parameter int CACHE_BLOCK_SIZE_IN_BYTES = 64;
  parameter int CACHE_BLOCK_SIZE_IN_BITS = CACHE_BLOCK_SIZE_IN_BYTES * 8;

  parameter int ASSOCIATIVITY = 1;  // 1 = direct-mapped

  parameter int NUM_OF_CACHE_LINES = CACHE_SIZE_IN_BYTES / CACHE_BLOCK_SIZE_IN_BYTES;
  parameter int NUM_OF_SETS = NUM_OF_CACHE_LINES / ASSOCIATIVITY;

  parameter int OFFSET_BITS = $clog2(CACHE_BLOCK_SIZE_IN_BYTES);
  parameter int INDEX_BITS = $clog2(NUM_OF_SETS);
  parameter int TAG_BITS = ADDRESS_SPACE_IN_BITS - INDEX_BITS - OFFSET_BITS;

  parameter int WORDS_PER_CACHE_BLOCK = CACHE_BLOCK_SIZE_IN_BYTES / WORD_SIZE_IN_BYTES;
  parameter int WORD_SELECT_BITS = $clog2(WORDS_PER_CACHE_BLOCK);

  parameter int BYTE_SELECT_BITS = $clog2(WORD_SIZE_IN_BYTES);

  // Type Definitions
  typedef logic [CACHE_BLOCK_SIZE_IN_BITS - 1:0] cacheblock_t;  // 512 bits at the moment.
  typedef logic [ADDRESS_SPACE_IN_BITS -1:0] address_t;  // 32 bits at the moment.

  typedef logic [OFFSET_BITS -1:0] offset_t;
  typedef logic [INDEX_BITS -1:0] idx_t;
  typedef logic [TAG_BITS -1:0] tag_t;
  typedef logic valid_t;
  typedef logic [WORD_SIZE_IN_BITS-1:0] word_t;  // 32 bits at the moment.
  typedef logic [WORD_SELECT_BITS-1:0] word_select_t;

  // LSB and MSB of fields in an memory address
  parameter int OFFSET_LSB = 0;
  parameter int OFFSET_MSB = OFFSET_BITS - 1;

  parameter int INDEX_LSB = OFFSET_BITS;
  parameter int INDEX_MSB = (INDEX_BITS + OFFSET_BITS) - 1;

  parameter int TAG_LSB = (INDEX_BITS + OFFSET_BITS);
  parameter int TAG_MSB = (TAG_BITS + INDEX_BITS + OFFSET_BITS) - 1;

  // Word and byte select bits are inside the offset bits
  parameter int WORD_SELECT_LSB = BYTE_SELECT_BITS;
  parameter int WORD_SELECT_MSB = (WORD_SELECT_LSB + WORD_SELECT_BITS) - 1;

  parameter int BYTE_SELECT_LSB = 0;
  parameter int BYTE_SELECT_MSB = BYTE_SELECT_BITS - 1;

  // Helper function to exract the word from a cache block.
  // Functions should be combinational.
  // `Automatic` keyword makes the entire function full combinational, so,
  // the variable defined inside the functions are not stored between the calls.
  function automatic word_t getWordFromCacheBlock(cacheblock_t block, word_select_t word_select);
    return block[word_select*WORD_SIZE_IN_BITS+:WORD_SIZE_IN_BITS];
  endfunction

  function automatic cacheblock_t getNewBlock(cacheblock_t block, word_select_t word_select,
                                              word_t write_data);
    block[word_select*WORD_SIZE_IN_BITS+:WORD_SIZE_IN_BITS] = write_data;
    return block;
  endfunction

endpackage
