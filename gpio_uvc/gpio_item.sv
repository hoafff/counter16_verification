class gpio_item extends uvm_sequence_item;
    // Generic GPIO transaction: one output bank and one input bank.
    // Nothing here knows about Counter16, reset or enable.
    rand bit   [GPIO_WIDTH-1:0] gpio_out;
         logic [GPIO_WIDTH-1:0] gpio_in;

    `uvm_object_utils_begin(gpio_item)
        `uvm_field_int(gpio_out, UVM_DEFAULT)
        `uvm_field_int(gpio_in,  UVM_DEFAULT | UVM_NOCOMPARE)
    `uvm_object_utils_end

    function new(string name = "gpio_item");
        super.new(name);
    endfunction
endclass
