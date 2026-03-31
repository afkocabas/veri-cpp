import uart_pkg::*;

module uart_tx (
    input logic clk_i,
    input logic rstn_i,
    input logic start_i,
    input data_t data_i,
    input logic [31:0] cpb_i,
    input logic [31:0] cps_i,
    input logic done_ack_i,

    output logic busy_o,
    output logic done_o,

    output logic tx_o
);

  // Internal representation of the output signals. Signals are drived pure
  // combinational.
  logic busy_o_c, done_o_c, tx_o_c;

  // Internal registers and next state signals
  tx_state_t state_q, state_d;
  bit_idx_t bit_idx_q, bit_idx_d;

  logic [31:0] cpb_counter_q, cpb_counter_d;

  always_comb begin : output_comb
    data_d   = data_q;
    busy_o_c = !(state_q == IDLE || state_q == WAIT_ACK);
    done_o_c = '0;
    tx_o_c   = STOP_BIT;

    unique case (state_q)
      IDLE: begin
        if (start_i) begin
          data_d = data_i;
        end
      end
      TRANSMISSION_START: begin
        tx_o_c = START_BIT;
      end
      DATA_TRANSMISSION: begin
        tx_o_c = data_q[bit_idx_q];
      end
      TRANSMISSION_END: begin
        tx_o_c = STOP_BIT;
      end
      WAIT_ACK: begin
        done_o_c = 1'b1;
      end
    endcase
  end

  always_comb begin : counter_comb

    cpb_counter_d = cpb_counter_q;
    bit_idx_d = bit_idx_q;

    unique case (state_q)
      IDLE: begin
        if (start_i) begin
          cpb_counter_d = '0;
          bit_idx_d = '0;
        end
      end
      TRANSMISSION_START: begin
        if (cpb_counter_q == cpb_i - 1) begin
          cpb_counter_d = '0;
        end else begin
          cpb_counter_d = cpb_counter_q + 1;
        end
      end
      DATA_TRANSMISSION: begin
        if (cpb_counter_q == cpb_i - 1) begin
          cpb_counter_d = '0;
          bit_idx_d = bit_idx_q + 1;
        end else begin
          cpb_counter_d = cpb_counter_q + 1;
        end

      end
      // end
      TRANSMISSION_END: begin
        if (cpb_counter_q == cpb_i - 1) begin
          cpb_counter_d = '0;
        end else begin
          cpb_counter_d = cpb_counter_q + 1;
        end
      end
      WAIT_ACK: begin
        cpb_counter_d = '0;
        bit_idx_d = '0;
      end
    endcase
  end

  always_comb begin : fsm_comb
    state_d = state_q;

    unique case (state_q)
      IDLE: begin
        if (start_i) begin
          state_d = TRANSMISSION_START;
        end
      end
      TRANSMISSION_START: begin
        if (cpb_counter_q == cpb_i - 1) begin
          state_d = DATA_TRANSMISSION;
        end
      end
      DATA_TRANSMISSION: begin
        if (cpb_counter_q == cpb_i - 1 && bit_idx_q == DATA_WIDTH - 1) begin
          state_d = TRANSMISSION_END;
        end
      end
      TRANSMISSION_END: begin
        if (cpb_counter_q == cpb_i - 1) begin
          state_d = WAIT_ACK;
        end
      end
      WAIT_ACK: begin
        if (done_ack_i) begin
          state_d = IDLE;
        end
      end
    endcase
  end


  always_ff @(posedge clk_i or negedge rstn_i) begin : seq_logic
    if (!rstn_i) begin
      state_q <= IDLE;
      bit_idx_q <= '0;
      cpb_counter_q <= '0;
      data_q <= '0;
    end else begin
      state_q <= state_d;
      bit_idx_q <= bit_idx_d;
      cpb_counter_q <= cpb_counter_d;
      data_q <= data_d;
    end
  end


  // Drive output signals
  assign tx_o   = tx_o_c;
  assign done_o = done_o_c;
  assign busy_o = busy_o_c;

endmodule
