class gpio_base_sequence extends uvm_sequence #(gpio_item);
    `uvm_object_utils(gpio_base_sequence)

    function new(string name = "gpio_base_sequence");
        super.new(name);
    endfunction

    task send_gpio(bit [GPIO_WIDTH-1:0] value);
        gpio_item req;
        req = gpio_item::type_id::create("req");
        start_item(req);
        req.gpio_out = value;
        finish_item(req);
    endtask
endclass

// Generic sequence used to prove that the UVC itself is not Counter16-specific.
class gpio_random_sequence extends gpio_base_sequence;
    `uvm_object_utils(gpio_random_sequence)

    int unsigned num_items = 100;

    function new(string name = "gpio_random_sequence");
        super.new(name);
    endfunction

    task body();
        gpio_item req;
        repeat (num_items) begin
            req = gpio_item::type_id::create("req");
            start_item(req);
            if (!req.randomize())
                `uvm_fatal("GPIO_RAND", "Could not randomize gpio_item")
            finish_item(req);
        end
    endtask
endclass
