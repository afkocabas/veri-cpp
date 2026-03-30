package enums_pkg;

  typedef enum {
    IDLE,
    LOOKUP,
    HIT,
    MISS,
    RESPOND
  } cache_state_t;


  typedef enum {
    READ,
    WRITE
  } cache_req_t;

endpackage
