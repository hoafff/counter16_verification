class counter_base_sequence extends uvm_sequence #(counter_item);
    `uvm_object_utils(counter_base_sequence)

    function new(string name = "counter_base_sequence");
        super.new(name);
    endfunction

    // Helper cho directed sequence:
    // tao mot transaction voi gia tri reset/enable xac dinh va gui xuong sequencer.
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
        // Giu reset trong 3 transaction, sau do nha reset va giu counter.
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
        // Directed stimulus: ta chu dong biet truoc tung kich ban can kiem tra.
        repeat (8) send_item(1'b0, 1'b1); // increment
        repeat (3) send_item(1'b0, 1'b0); // hold
        repeat (5) send_item(1'b0, 1'b1); // increment
        repeat (2) send_item(1'b1, 1'b1); // reset giua bai test
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
        // Tu 0000: 65535 lan tang se toi FFFF, lan tiep theo wrap ve 0000,
        // sau do tang them hai lan de chung minh DUT tiep tuc hoat dong binh thuong.
        repeat (16'hFFFF + 3)
            send_item(1'b0, 1'b1);
        repeat (2)
            send_item(1'b0, 1'b0);
    endtask
endclass

class counter_random_sequence extends counter_base_sequence;
    `uvm_object_utils(counter_random_sequence)

    int unsigned num_items = 200;

    function new(string name = "counter_random_sequence");
        super.new(name);
    endfunction

    task body();
        counter_item req;

        repeat (num_items) begin
            req = counter_item::type_id::create("req");
            start_item(req);

            // Constrained-random:
            // - reset xuat hien it de khong pha vo chuoi dem qua thuong xuyen;
            // - enable=1 xuat hien nhieu hon de tao nhieu transition count.
            if (!req.randomize() with {
                reset  dist {1'b0 := 95, 1'b1 := 5};
                enable dist {1'b0 := 30, 1'b1 := 70};
            }) begin
                `uvm_fatal("RAND_FAIL", "Khong randomize duoc counter_item")
            end

            finish_item(req);
        end
    endtask
endclass
