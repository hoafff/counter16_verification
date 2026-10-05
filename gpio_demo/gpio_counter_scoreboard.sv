class gpio_counter_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(gpio_counter_scoreboard)

    uvm_analysis_imp #(gpio_item, gpio_counter_scoreboard) analysis_imp;

    logic [15:0] expected;
    bit seen_reset;
    bit gpio_mapping_active;
    int unsigned pass_count;
    int unsigned fail_count;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        analysis_imp = new("analysis_imp", this);
        expected            = 16'h0000;
        seen_reset          = 1'b0;
        gpio_mapping_active = 1'b0;
        pass_count          = 0;
        fail_count          = 0;
    endfunction

    function void write(gpio_item t);
        bit reset;
        bit enable;
        logic [15:0] count;
        bit direction_ok;

        direction_ok = (t.output_enable[1:0]  === 2'b11) &&
                       (t.output_enable[17:2] === 16'h0000);

        // Before the first sequence item, every generic GPIO pin is intentionally
        // INPUT/Hi-Z. Ignore that startup monitor sample. Once the Counter16
        // adapter mapping becomes active, a later direction error is real.
        if (!gpio_mapping_active) begin
            if (!direction_ok)
                return;
            gpio_mapping_active = 1'b1;
        end else if (!direction_ok) begin
            fail_count++;
            `uvm_error("GPIO_DIRECTION",
                $sformatf("Unexpected output_enable=0x%05h", t.output_enable))
            return;
        end

        // Consume resolved physical pin values, not just intended drive values.
        reset  = t.sampled_value[0];
        enable = t.sampled_value[1];
        count  = t.sampled_value[17:2];

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
                    $sformatf("pins=0x%05h count=0x%04h expected=0x%04h",
                              t.sampled_value, count, expected))
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

        if (!gpio_mapping_active)
            `uvm_error("GPIO_NO_ACTIVITY", "GPIO direction mapping never became active")

        if (fail_count != 0)
            `uvm_error("GPIO_SB_FAILED", "Pin-level GPIO Counter16 demo detected mismatches")
    endfunction
endclass
