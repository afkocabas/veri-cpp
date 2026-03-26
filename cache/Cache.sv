import CachePackage::*;

// Simple read-only direct mapped cache with 4 kb data capacity.
module Cache (
    input logic     res,
    input logic     clock,
    input logic     read_enable,
    input address_t address,

    output data_t read_data
);

  // Internal Blocks:   {
  cacheblock_t data      [NUM_OF_CACHE_LINES];
  offset_t     offset    [NUM_OF_CACHE_LINES];
  tag_t        tag       [NUM_OF_CACHE_LINES];

  offset_t     offset_in;
  tag_t        tag_in;
  index_t      index_in;
  // ------------------ }

  // Assignments:    {
  assign offset_in = address[];
  assign tag_in    = address[];
  assign index_in  = address[];
  // ----------------}


  always_ff @(posedge clock) begin : read_data
    if (res) begin

    end else begin

    end

  end

endmodule
