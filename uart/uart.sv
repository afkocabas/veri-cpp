import uart_regblock_pkg::*;

module uart (
    input logic clk_i,
    input logic rstn_i,

    input  logic u_rx,
    output logic u_tx

);

  // Register blocks signals
  uart_regblock__in_t hwif_in;
  uart_regblock__out_t hwif_out;

  // Tx signals
  logic tx_done_ack;
  logic tx_busy;

  // Rx signals
  logic rx_done_ack;

  axi4lite_intf s_axil ();

  // Uart register block
  uart_regblock reg_block (
      .clk(clk_i),
      .rst(rstn_i),

      .s_axil(s_axil.slave),

      .hwif_in (hwif_in),
      .hwif_out(hwif_out)
  );

  uart_tx tx (
      .clk_i(clk_i),
      .rstn_i(rstn_i),
      .done_ack_i(tx_done_ack),
      .start_i(hwif_out.CFG.tx_en.value),
      .data_i(hwif_out.TDR.tx_data.value),
      .cpb_i(hwif_out.CPB.cpb_value.value),

      .done_o(hwif_out.CFG.tx_done.value),
      .busy_o(tx_busy),
      .tx_o  (u_tx)
  );

  uart_rx rx (
      .clk_i(clk_i),
      .rstn_i(rstn_i),
      .rx_i(u_rx),
      .done_ack_i(rx_done_ack),

      .cpb_i(hwif_out.CPB.cpb_value.value),

      .data_o (hwif_in.RDR.rx_data.next),
      .ready_o(hwif_in.CFG.rx_ready.next)
  );


  always_comb begin : placeholder_comb

  end

  always_ff @(posedge clk_i or negedge rstn_i) begin : placeholder_ff

  end

endmodule
