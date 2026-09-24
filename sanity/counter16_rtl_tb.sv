`timescale 1ns/1ps

module counter16_rtl_tb;
    logic clk = 1'b0;
    logic reset = 1'b1;
    logic enable = 1'b0;
    logic [15:0] count;

    counter16 dut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .count(count)
    );

    always #5 clk = ~clk;

    task automatic check(input logic [15:0] expected, input string label);
        #1ps;
        if (count !== expected)
            $fatal(1, "[RTL_SANITY] %s: actual=0x%04h expected=0x%04h",
                   label, count, expected);
    endtask

    initial begin
        // Synchronous reset.
        repeat (2) @(posedge clk);
        check(16'h0000, "reset");
        @(negedge clk);
        reset = 1'b0;

        // Hold when disabled.
        repeat (3) begin
            @(posedge clk);
            check(16'h0000, "hold");
        end

        // Full 16-bit range and explicit wrap-around.
        @(negedge clk);
        enable = 1'b1;
        repeat (16'hFFFF) @(posedge clk);
        check(16'hFFFF, "max value");

        @(posedge clk);
        check(16'h0000, "wrap to zero");

        @(posedge clk);
        check(16'h0001, "increment after wrap");

        @(negedge clk);
        enable = 1'b0;
        repeat (2) @(posedge clk);
        check(16'h0001, "hold after wrap");

        $display("[RTL_SANITY] PASS");
        $finish;
    end
endmodule
