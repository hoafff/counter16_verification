package gpio_counter_pkg;
    import uvm_pkg::*;
    import gpio_uvc_pkg::*;
    `include "uvm_macros.svh"

    `include "gpio_counter_sequences.sv"
    `include "gpio_counter_scoreboard.sv"
    `include "gpio_counter_env.sv"
    `include "gpio_counter_tests.sv"
endpackage
