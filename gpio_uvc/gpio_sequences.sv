class gpio_base_sequence extends uvm_sequence #(gpio_item);
    `uvm_object_utils(gpio_base_sequence)

    function new(string name = "gpio_base_sequence");
        super.new(name);
    endfunction

    // Generic helper: one transaction defines both GPIO direction and value.
    task send_gpio(
        bit [GPIO_WIDTH-1:0] drive_value,
        bit [GPIO_WIDTH-1:0] output_enable
    );
        gpio_item req;
        req = gpio_item::type_id::create("req");
        start_item(req);
        req.drive_value   = drive_value;
        req.output_enable = output_enable;
        finish_item(req);
    endtask
endclass

// Generic GPIO random traffic: both pin direction and driven value can vary.
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
