package CachePackage;
  parameter int ADDRESS_SPACE_IN_BITS = 32;

  parameter int CPU_DATA_WIDTH_IN_BITS = 32;
  parameter int CPU_DATA_WIDTH_IN_BYTES = CPU_DATA_WIDTH_IN_BITS / 8;

  parameter int WORD_SIZE_IN_BYTES = CPU_DATA_WIDTH_IN_BYTES;

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
  parameter int WORD_OFFSET_BITS = $clog2(WORDS_PER_CACHE_BLOCK);
endpackage
