class counter_test;
    virtual counter_if vif;
    counter_env env;

    function new(virtual counter_if vif);
        this.vif = vif;
        this.env = new(vif);
    endfunction

    task run_smoke();
        $display("[BASE_SV][TEST] smoke test start");

        env.gen.send_repeat(1'b1, 8);  // increment for 8 sampled edges
        env.gen.send_repeat(1'b0, 3);  // hold for 3 sampled edges
        env.gen.send_repeat(1'b1, 6);  // increment again

        // Assert reset while enable is still high to prove reset priority.
        env.rst_gen.apply_reset(2);

        env.gen.send_repeat(1'b1, 4);
        env.gen.send_repeat(1'b0, 2);
    endtask

    task run_wrap();
        $display("[BASE_SV][TEST] 16-bit wrap test start");
        // Starting from zero after reset: 65535 increments -> FFFF,
        // one additional increment -> 0000, then two more -> 0002.
        env.gen.send_repeat(1'b1, 16'hFFFF + 3);
        env.gen.send_repeat(1'b0, 2);
    endtask

    task run();
        vif.reset  = 1'b1;
        vif.enable = 1'b0;
        env.start();
        env.rst_gen.apply_reset(3);

        if ($test$plusargs("WRAP"))
            run_wrap();
        else
            run_smoke();

        // Sequence acknowledgements happen at posedge; allow monitor/scoreboard
        // to observe the last result on following falling edges.
        repeat (2) @(vif.mon_cb);
        env.sb.report();

        if (env.sb.fail_count != 0)
            $fatal(1, "[BASE_SV][TEST] FAILED");
        else
            $display("[BASE_SV][TEST] PASSED");

        $finish;
    endtask
endclass
