`timescale 1ns/1ps

module tb_top;
    import counter_base_pkg::*;

    counter_if intf();

    counter16 dut (
        .clk    (intf.clk),
        .reset  (intf.reset),
        .enable (intf.enable),
        .count  (intf.count)
    );

    initial begin
        counter_test test;
        test = new(intf);
        test.run();
    end
endmodule
