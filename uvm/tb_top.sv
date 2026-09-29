`timescale 1ns/1ps

module tb_top;
    import uvm_pkg::*;
    import counter_uvm_pkg::*;

    // Interface that: mot instance chua cac signal noi testbench voi DUT.
    counter_if intf();

    counter16 dut (
        .clk    (intf.clk),
        .reset  (intf.reset),
        .enable (intf.enable),
        .count  (intf.count)
    );

    // SVA duoc dat ngoai DUT de verification logic khong lam thay doi RTL can test.
    counter16_assertions assertions_i (
        .clk    (intf.clk),
        .reset  (intf.reset),
        .enable (intf.enable),
        .count  (intf.count)
    );

    initial begin
        intf.clk    = 1'b0;
        intf.reset  = 1'b1;
        intf.enable = 1'b0;
        forever #5ns intf.clk = ~intf.clk;
    end

    initial begin
        // Dua interface that vao config_db; driver/monitor/test se lay ra qua vif.
        uvm_config_db#(virtual counter_if)::set(null, "*", "vif", intf);
        run_test();
    end
endmodule
