class counter_clock_gen;
    virtual counter_if vif;
    time half_period;

    function new(virtual counter_if vif, time half_period = 5ns);
        this.vif = vif;
        this.half_period = half_period;
    endfunction

    task run();
        vif.clk = 1'b0;
        forever #(half_period) vif.clk = ~vif.clk;
    endtask
endclass
