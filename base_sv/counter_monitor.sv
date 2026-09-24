class counter_monitor;
    virtual counter_if vif;
    mailbox #(counter_sample) outbox;

    function new(virtual counter_if vif,
                 mailbox #(counter_sample) outbox);
        this.vif = vif;
        this.outbox = outbox;
    endfunction

    task run();
        counter_sample sample;
        forever begin
            @(vif.mon_cb);
            sample = new();
            sample.reset  = vif.mon_cb.reset;
            sample.enable = vif.mon_cb.enable;
            sample.count  = vif.mon_cb.count;
            outbox.put(sample);
        end
    endtask
endclass
