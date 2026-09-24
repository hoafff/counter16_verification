`timescale 1ns/1ps

module tb_top;
    import uvm_pkg::*;
    import counter_uvm_pkg::*;

    counter_if intf();

    counter16 dut (
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
        uvm_config_db#(virtual counter_if)::set(null, "*", "vif", intf);
        run_test();
    end
endmodule
