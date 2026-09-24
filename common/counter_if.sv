`timescale 1ns/1ps

interface counter_if;
    logic        clk;
    logic        reset;
    logic        enable;
    logic [15:0] count;

    // Driver changes control signals on the falling edge. This leaves half a
    // clock period for them to settle before the DUT samples them on posedge.
    clocking drv_cb @(negedge clk);
        default input #1step output #0;
        output reset;
        output enable;
        input  count;
    endclocking

    // The monitor samples immediately before the same falling edge. Therefore
    // it sees the controls that were active at the preceding rising edge and
    // the count value produced by that edge, avoiding driver/monitor races.
    clocking mon_cb @(negedge clk);
        default input #1step output #0;
        input reset;
        input enable;
        input count;
    endclocking
endinterface
