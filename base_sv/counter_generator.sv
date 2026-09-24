class counter_generator;
    mailbox #(counter_transaction) outbox;
    mailbox #(bit)                 donebox;

    function new(mailbox #(counter_transaction) outbox,
                 mailbox #(bit) donebox);
        this.outbox = outbox;
        this.donebox = donebox;
    endfunction

    task send(bit enable);
        counter_transaction tr = new(enable);
        bit done;
        outbox.put(tr);
        // This acknowledgement makes one generated item correspond to one
        // completed DUT sampling edge, which keeps tests deterministic.
        donebox.get(done);
    endtask

    task send_repeat(bit enable, int unsigned cycles);
        repeat (cycles)
            send(enable);
    endtask
endclass
