class counter_scoreboard;
    mailbox #(counter_sample) inbox;
    logic [15:0] expected;
    bit seen_reset;
    int unsigned pass_count;
    int unsigned fail_count;

    function new(mailbox #(counter_sample) inbox);
        this.inbox = inbox;
        this.expected = 16'h0000;
        this.seen_reset = 1'b0;
        this.pass_count = 0;
        this.fail_count = 0;
    endfunction

    task run();
        counter_sample sample;
        forever begin
            inbox.get(sample);

            if (sample.reset) begin
                expected = 16'h0000;
                seen_reset = 1'b1;
            end else if (seen_reset && sample.enable) begin
                expected = (expected == 16'hFFFF)
                         ? 16'h0000
                         : expected + 16'h0001;
            end

            if (seen_reset) begin
                if (sample.count !== expected) begin
                    fail_count++;
                    $error("[BASE_SV][SB] FAIL %s expected=0x%04h",
                           sample.sprint(), expected);
                end else begin
                    pass_count++;
                end
            end
        end
    endtask

    function void report();
        $display("[BASE_SV][SB] pass=%0d fail=%0d expected=0x%04h",
                 pass_count, fail_count, expected);
    endfunction
endclass
