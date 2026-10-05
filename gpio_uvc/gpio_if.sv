timescale 1ns/1ps

interface gpio_if #(parameter int WIDTH = 16) (input logic clk);
    // gpio_out: UVC -> DUT/environment
    // gpio_in : DUT/environment -> UVC
    logic [WIDTH-1:0] gpio_out = '0;
    logic [WIDTH-1:0] gpio_in;

    // Driver changes outputs on negedge so the DUT can sample them safely
    // on the following posedge.
    clocking drv_cb @(negedge clk);
        default input #1step output #0;
        output gpio_out;
        input  gpio_in;
    endclocking

    // Monitor samples the values that belonged to the preceding DUT posedge.
    // With input #1step it samples before the driver updates gpio_out.
    clocking mon_cb @(negedge clk);
        default input #1step output #0;
        input gpio_out;
        input gpio_in;
    endclocking
endinterface
