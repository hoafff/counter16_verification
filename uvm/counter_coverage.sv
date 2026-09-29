class counter_coverage extends uvm_subscriber #(counter_item);
    `uvm_component_utils(counter_coverage)

    counter_item sample_item;

    covergroup counter_cg;
        option.per_instance = 1;

        cp_reset: coverpoint sample_item.reset {
            bins inactive = {1'b0};
            bins active   = {1'b1};
        }

        cp_enable: coverpoint sample_item.enable {
            bins hold      = {1'b0};
            bins increment = {1'b1};
        }

        // Chia mien count thanh cac vung co y nghia thay vi tao 65536 bins rieng le.
        cp_count_value: coverpoint sample_item.count {
            bins zero      = {16'h0000};
            bins low       = {[16'h0001:16'h000F]};
            bins middle    = {[16'h0010:16'hFFFD]};
            bins near_wrap = {16'hFFFE};
            bins max_value = {16'hFFFF};
        }

        // Transition bins giup chung minh ta da di qua corner case wrap-around.
        cp_count_transition: coverpoint sample_item.count {
            bins to_max     = (16'hFFFE => 16'hFFFF);
            bins wrap       = (16'hFFFF => 16'h0000);
            bins after_wrap = (16'h0000 => 16'h0001);
        }

        reset_enable_cross: cross cp_reset, cp_enable;
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        counter_cg = new();
    endfunction

    function void write(counter_item t);
        // Subscriber nhan cung observed item ma scoreboard nhan tu monitor.
        sample_item = t;
        counter_cg.sample();
    endfunction

    function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        // Coverage tra loi cau hoi: "Ta da test du cac tinh huong mong muon chua?"
        `uvm_info("COV_SUMMARY",
                  $sformatf("functional coverage = %0.2f%%",
                            counter_cg.get_inst_coverage()),
                  UVM_NONE)
    endfunction
endclass
