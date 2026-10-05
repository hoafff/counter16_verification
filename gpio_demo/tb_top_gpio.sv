`timescale 1ns/1ps

module tb_top_gpio;
    import uvm_pkg::*;
    import gpio_uvc_pkg::*;
    import gpio_counter_pkg::*;

    logic clk = 1'b0;
    logic [15:0] count;

    // Default WIDTH=18 matches gpio_uvc_pkg::GPIO_WIDTH.
    gpio_if gpio_vif(.clk(clk));

    // Pin-level adapter:
    //   gpio[0]     -> reset   (UVC drives)
    //   gpio[1]     -> enable  (UVC drives)
    //   gpio[17:2] <- count    (DUT drives)
    counter16 dut (
        .clk    (clk),
        .reset  (gpio_vif.gpio[0]),
        .enable (gpio_vif.gpio[1]),
        .count  (count)
    );

    // External/DUT drive on GPIO input pins. The UVC keeps OE=0 here,
    // therefore its own driver is Hi-Z and no bus contention occurs.
    assign gpio_vif.gpio[17:2] = count;

    counter16_assertions assertions_i (
        .clk    (clk),
        .reset  (gpio_vif.gpio[0]),
        .enable (gpio_vif.gpio[1]),
        .count  (count)
    );

    always #5ns clk = ~clk;

    initial begin
        uvm_config_db#(virtual gpio_if)::set(null, "*", "vif", gpio_vif);
        run_test();
    end
endmodule
