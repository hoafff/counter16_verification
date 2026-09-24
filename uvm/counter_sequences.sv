class counter_base_sequence extends uvm_sequence #(counter_item);
    `uvm_object_utils(counter_base_sequence)

    function new(string name = "counter_base_sequence");
        super.new(name);
    endfunction

    task send_item(bit reset, bit enable);
        counter_item req;
        req = counter_item::type_id::create("req");
        start_item(req);
        req.reset  = reset;
        req.enable = enable;
        finish_item(req);
    endtask
endclass

class counter_reset_sequence extends counter_base_sequence;
    `uvm_object_utils(counter_reset_sequence)

    function new(string name = "counter_reset_sequence");
        super.new(name);
    endfunction

    task body();
        repeat (3) send_item(1'b1, 1'b0);
        send_item(1'b0, 1'b0);
    endtask
endclass

class counter_smoke_sequence extends counter_base_sequence;
    `uvm_object_utils(counter_smoke_sequence)

    function new(string name = "counter_smoke_sequence");
        super.new(name);
    endfunction

    task body();
        repeat (8) send_item(1'b0, 1'b1); // increment
        repeat (3) send_item(1'b0, 1'b0); // hold
        repeat (5) send_item(1'b0, 1'b1); // increment
        repeat (2) send_item(1'b1, 1'b1); // mid-test reset
        send_item(1'b0, 1'b0);
        repeat (4) send_item(1'b0, 1'b1);
        repeat (2) send_item(1'b0, 1'b0);
    endtask
endclass

class counter_wrap_sequence extends counter_base_sequence;
    `uvm_object_utils(counter_wrap_sequence)

    function new(string name = "counter_wrap_sequence");
        super.new(name);
    endfunction

    task body();
        // From zero: 65535 increments -> FFFF, next -> 0000,
        // then two more increments -> 0002.
        repeat (16'hFFFF + 3)
            send_item(1'b0, 1'b1);
        repeat (2)
            send_item(1'b0, 1'b0);
    endtask
endclass
