package gpio_uvc_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // Demo uses one GPIO bank:
    // pin 0 reset, pin 1 enable, pins 2..17 count[15:0].
    parameter int GPIO_WIDTH = 18;

    `include "gpio_item.sv"
    `include "gpio_config.sv"
    `include "gpio_sequences.sv"
    `include "gpio_sequencer.sv"
    `include "gpio_driver.sv"
    `include "gpio_monitor.sv"
    `include "gpio_agent.sv"
endpackage
