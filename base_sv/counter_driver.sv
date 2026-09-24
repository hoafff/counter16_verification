class counter_driver;
    virtual counter_if vif;
    mailbox #(counter_transaction) inbox;
    mailbox #(bit)                 donebox;
    int unsigned driven_items;

    function new(virtual counter_if vif,
                 mailbox #(counter_transaction) inbox,
                 mailbox #(bit) donebox);
        this.vif = vif;
        this.inbox = inbox;
        this.donebox = donebox;
        this.driven_items = 0;
    endfunction

    task run();
        counter_transaction tr;
        forever begin
            inbox.get(tr);
            @(vif.drv_cb);
            vif.drv_cb.enable <= tr.enable;

            // Wait until the DUT has sampled the driven value.
            @(posedge vif.clk);
            driven_items++;
            donebox.put(1'b1);
        end
    endtask
endclass
