// Top level module
module cache (
    input clk,
    input rst
);
  // Create the interfaces
  cache_mem_if mem_if (
      .clk(clk),
      .rst(rst)
  );

  cache_req_if req_if (
      .clk(clk),
      .rst(rst)
  );

  cache_mem mem (.ctrl_if(mem_if.slave));

  cache_ctrl ctrl (
      .c_mem_if(mem_if.master),
      .c_req_if(req_if.slave)
  );


  // Ctreate the instances
endmodule
