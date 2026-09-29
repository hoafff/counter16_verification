class counter_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(counter_scoreboard)

    // Day la uvm_analysis_imp: diem ket thuc nhan transaction tu analysis_port.
    // Ten analysis_imp duoc dung de tranh nham voi uvm_analysis_export.
    uvm_analysis_imp #(counter_item, counter_scoreboard) analysis_imp;

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

    function void write(counter_item t);
        // Reference model nho duoc dat ngay trong scoreboard vi DUT rat don gian.
        // Voi DUT phuc tap, phan predictor/reference model thuong nen tach rieng.
        if (t.reset) begin
            expected = 16'h0000;
            seen_reset = 1'b1;
        end else if (seen_reset && t.enable) begin
            expected = (expected == 16'hFFFF)
                     ? 16'h0000
                     : expected + 16'h0001;
        end

        // Scoreboard tra loi cau hoi: DUT co tao ket qua DUNG hay khong?
        if (seen_reset) begin
            if (t.count !== expected) begin
                fail_count++;
                `uvm_error("COUNT_MISMATCH",
                    $sformatf("reset=%0b enable=%0b actual=0x%04h expected=0x%04h",
                              t.reset, t.enable, t.count, expected))
            end else begin
                pass_count++;
            end
        end
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        `uvm_info("SB_SUMMARY",
                  $sformatf("pass=%0d fail=%0d final_expected=0x%04h",
                            pass_count, fail_count, expected),
                  UVM_NONE)

        if (fail_count != 0)
            `uvm_error("SB_FAILED", "Counter scoreboard detected mismatches")
    endfunction
endclass
