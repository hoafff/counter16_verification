`timescale 1ns/1ps

module counter16_assertions (
    input logic        clk,
    input logic        reset,
    input logic        enable,
    input logic [15:0] count
);

    // Neu reset duoc sample o posedge, ket qua sau canh do phai la 0000.
    property p_reset_clears_count;
        @(posedge clk)
        reset |=> (count == 16'h0000);
    endproperty

    a_reset_clears_count:
        assert property (p_reset_clears_count)
        else $error("ASSERT_RESET: count khong ve 0000 sau reset");

    // Khi khong reset va enable=0, counter phai giu nguyen gia tri.
    property p_hold_when_disabled;
        @(posedge clk)
        (!reset && !enable) |=> (count == $past(count));
    endproperty

    a_hold_when_disabled:
        assert property (p_hold_when_disabled)
        else $error("ASSERT_HOLD: count thay doi khi enable=0");

    // Khi enable=1 va chua toi FFFF, counter phai tang dung 1.
    property p_increment_when_enabled;
        @(posedge clk)
        (!reset && enable && count != 16'hFFFF)
        |=> (count == ($past(count) + 16'h0001));
    endproperty

    a_increment_when_enabled:
        assert property (p_increment_when_enabled)
        else $error("ASSERT_INC: count khong tang dung 1");

    // Corner case: FFFF + 1 phai wrap ve 0000.
    property p_wrap_at_max;
        @(posedge clk)
        (!reset && enable && count == 16'hFFFF)
        |=> (count == 16'h0000);
    endproperty

    a_wrap_at_max:
        assert property (p_wrap_at_max)
        else $error("ASSERT_WRAP: count khong wrap tu FFFF ve 0000");

endmodule
