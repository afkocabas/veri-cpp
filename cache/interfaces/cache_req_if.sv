import cache_pkg::*;
import enums_pkg::*;

interface cache_req_if (
    input clk,
    input rst
);

  address_t addr;
  cache_req_t req;

  logic is_hit;
  logic req_valid;
  logic req_ready;
  logic res_valid;

  word_t wr_data;
  word_t rd_data;

  modport master(
      input clk,
      input rst,

      output req_valid,
      output req,
      output addr,
      output wr_data,
      input rd_data,
      input is_hit,
      input req_ready,
      input res_valid
  );

  modport slave(
      input clk,
      input rst,

      input req_valid,
      input req,
      input addr,
      input wr_data,
      output rd_data,
      output is_hit,
      output req_ready,
      output res_valid
  );

endinterface
