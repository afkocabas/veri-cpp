import router_pkg::*;

module router (
    input pckg_t pckg_i,
    input clk,
    input rst,

    output pckg_t out0,
    output pckg_t out1
);

  // State Registers
  state_t state_q;
  state_t state_d;

  pckg_t  pckg_q;
  pckg_t  pckg_d;

  always_comb begin : pckg_comb
    // Default assingment
    pckg_d = pckg_q;

    unique case (state_q)
      IDLE: begin
        if (pckg_i.vld) begin
          pckg_d = pckg_i;
        end
      end
    endcase

  end

  always_comb begin : state_comb
    state_d = state_q;
    out0 = '0;
    out1 = '0;

    unique case (state_q)
      IDLE: begin
        if (pckg_i.vld) begin
          state_d = RECIEVED;
        end
      end
      RECIEVED: begin
        if (pckg_q.dest == OUT_0) begin
          out0 = pckg_q;
        end else begin
          out1 = pckg_q;
        end
        state_d = IDLE;
      end
    endcase
  end


  always_ff @(posedge clk) begin : blockName
    if (rst) begin
      state_q <= IDLE;
      pckg_q  <= '0;
    end else begin
      // Load the next state to the current state register
      state_q <= state_d;
      pckg_q  <= pckg_d;
    end
  end



endmodule

