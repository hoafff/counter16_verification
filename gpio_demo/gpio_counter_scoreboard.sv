class gpio_counter_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(gpio_counter_scoreboard)

    uvm_analysis_imp #(gpio_item, gpio_counter_scoreboard) analysis_imp;

    logic [15:0] expected;
    bit seen_reset;
    int unsigned pass_count;
    int unsigned fail_count;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        analysis_imp = new("analysis_imp", this);
        expected   = 16'h0000;
        seen_reset = 1'b0;
        pass_count = 0;
        fail_count = 0;
    endfunction

    function void write(gpio_item t);
        bit reset;
        bit enable;
        logic [15:0] count;

        // Adapter semantics live here, outside the reusable GPIO UVC.
        reset  = t.gpio_out[0];
        enable = t.gpio_out[1];
        count  = t.gpio_in[15:0];

        if (reset) begin
            expected   = 16'h0000;
            seen_reset = 1'b1;
        end else if (seen_reset && enable) begin
            expected = (expected == 16'hFFFF)
                     ? 16'h0000
                     : expected + 16'h0001;
        end

        if (seen_reset) begin
            if (count !== expected) begin
                fail_count++;
                `uvm_error("GPIO_COUNT_MISMATCH",
                    $sformatf("gpio_out=0x%04h count=0x%04h expected=0x%04h",
                              t.gpio_out, count, expected))
            end else begin
                pass_count++;
            end
        end
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info("GPIO_SB_SUMMARY",
                  $sformatf("pass=%0d fail=%0d final_expected=0x%04h",
                            pass_count, fail_count, expected),
                  UVM_NONE)

        if (fail_count != 0)
            `uvm_error("GPIO_SB_FAILED", "GPIO-driven Counter16 demo detected mismatches")
    endfunction
endclass
