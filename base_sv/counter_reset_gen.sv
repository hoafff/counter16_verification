class counter_reset_gen;
    virtual counter_if vif;

    function new(virtual counter_if vif);
        this.vif = vif;
    endfunction

    task apply_reset(int unsigned cycles = 2);
        // Change reset only on falling edges. The monitor samples the old value
        // at that same edge; the new reset then applies to the next DUT posedge.
        @(vif.drv_cb);
        vif.drv_cb.reset <= 1'b1;
        repeat (cycles) @(posedge vif.clk);
        @(vif.drv_cb);
        vif.drv_cb.reset <= 1'b0;
    endtask
endclass
