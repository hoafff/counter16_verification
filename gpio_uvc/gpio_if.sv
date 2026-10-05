`timescale 1ns/1ps

interface gpio_if #(parameter int WIDTH = 18) (input logic clk);
    // A real GPIO bank is bidirectional. The UVC drives a pin only when
    // output_enable[i] == 1. Otherwise that pin is released to high impedance
    // so the DUT/environment can drive it as an input.
    tri   [WIDTH-1:0] gpio;
    logic [WIDTH-1:0] drive_value   = '0;
    logic [WIDTH-1:0] output_enable = '0;

    genvar i;
    generate
        for (i = 0; i < WIDTH; i++) begin : gen_gpio_tristate
            assign gpio[i] = output_enable[i] ? drive_value[i] : 1'bz;
        end
    endgenerate

    // Driver changes value/direction at negedge, leaving half a cycle before
    // the DUT consumes output pins at the following posedge.
    clocking drv_cb @(negedge clk);
        default input #1step output #0;
        output drive_value;
        output output_enable;
        input  gpio;
    endclocking

    // Monitor observes the resolved physical pin values plus the UVC drive
    // state. input #1step avoids a race with the driver at the same negedge.
    clocking mon_cb @(negedge clk);
        default input #1step output #0;
        input drive_value;
        input output_enable;
        input gpio;
    endclocking
endinterface
