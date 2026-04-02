interface axi4lite_intf #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
);
  logic AWREADY = 0;
  logic AWVALID = 0;
  logic [ADDR_WIDTH-1:0] AWADDR = 0;
  logic [2:0] AWPROT = 0;

  logic WREADY = 0;
  logic WVALID = 0;
  logic [DATA_WIDTH-1:0] WDATA = 0;
  logic [DATA_WIDTH/8-1:0] WSTRB = 0;

  logic BREADY = 0;
  logic BVALID = 0;
  logic [1:0] BRESP = 0;

  logic ARREADY = 0;
  logic ARVALID = 0;
  logic [ADDR_WIDTH-1:0] ARADDR = 0;
  logic [2:0] ARPROT = 0;

  logic RREADY = 0;
  logic RVALID = 0;
  logic [DATA_WIDTH-1:0] RDATA = 0;
  logic [1:0] RRESP = 0;

  modport master(
      input AWREADY,
      output AWVALID,
      output AWADDR,
      output AWPROT,

      input WREADY,
      output WVALID,
      output WDATA,
      output WSTRB,

      output BREADY,
      input BVALID,
      input BRESP,

      input ARREADY,
      output ARVALID,
      output ARADDR,
      output ARPROT,

      output RREADY,
      input RVALID,
      input RDATA,
      input RRESP
  );

  modport slave(
      output AWREADY,
      input AWVALID,
      input AWADDR,
      input AWPROT,

      output WREADY,
      input WVALID,
      input WDATA,
      input WSTRB,

      input BREADY,
      output BVALID,
      output BRESP,

      output ARREADY,
      input ARVALID,
      input ARADDR,
      input ARPROT,

      input RREADY,
      output RVALID,
      output RDATA,
      output RRESP
  );
endinterface
