class counter_env;
    virtual counter_if vif;

    mailbox #(counter_transaction) gen2drv;
    mailbox #(bit)                 drv_done;
    mailbox #(counter_sample)      mon2sb;

    counter_generator  gen;
    counter_driver     drv;
    counter_monitor    mon;
    counter_scoreboard sb;
    counter_clock_gen  clk_gen;
    counter_reset_gen  rst_gen;

    function new(virtual counter_if vif);
        this.vif = vif;
        gen2drv = new();
        drv_done = new();
        mon2sb  = new();

        gen     = new(gen2drv, drv_done);
        drv     = new(vif, gen2drv, drv_done);
        mon     = new(vif, mon2sb);
        sb      = new(mon2sb);
        clk_gen = new(vif, 5ns);
        rst_gen = new(vif);
    endfunction

    task start();
        fork
            clk_gen.run();
            drv.run();
            mon.run();
            sb.run();
        join_none
    endtask
endclass
