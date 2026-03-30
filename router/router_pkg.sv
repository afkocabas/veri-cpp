package router_pkg;

  typedef logic [7:0] data_t;
  typedef logic [3:0] id_t;

  typedef enum {
    OUT_0,
    OUT_1
  } dest_t;

  typedef enum {
    IDLE,
    RECIEVED
  } state_t;

  typedef struct packed {
    logic  vld;
    dest_t dest;
    data_t data;
    id_t   id;
  } pckg_t;

endpackage
