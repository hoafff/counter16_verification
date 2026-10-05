timescale 1ns/1ps

module tb_top_gpio;
    import uvm_pkg::*;
    import gpio_uvc_pkg::*;
    import gpio_counter_pkg::*;

    logic clk = 1'b0;
    logic [15:0] count;

    gpio_if gpio_vif(.clk(clk));

    // Adapter between generic GPIO pins and Counter16-specific pins.
    counter16 dut (
        .clk    (clk),
        .reset  (gpio_vif.gpio_out[0]),
        .enable (gpio_vif.gpio_out[1]),
        .count  (count)
    );

    // Observe the 16-bit counter through the generic GPIO input bank.
    assign gpio_vif.gpio_in = count;

    counter16_assertions assertions_i (
        .clk    (clk),
        .reset  (gpio_vif.gpio_out[0]),
        .enable (gpio_vif.gpio_out[1]),
        .count  (count)
    );

    always #5ns clk = ~clk;

    initial begin
        uvm_config_db#(virtual gpio_if)::set(null, "*", "vif", gpio_vif);
        run_test();
    end
endmodule
