class gpio_item extends uvm_sequence_item;
    // Pin-level GPIO transaction.
    // output_enable[i] = 1: pin i is OUTPUT and UVC drives drive_value[i].
    // output_enable[i] = 0: pin i is INPUT/Hi-Z and UVC only samples the pin.
    rand bit   [GPIO_WIDTH-1:0] drive_value;
    rand bit   [GPIO_WIDTH-1:0] output_enable;
         logic [GPIO_WIDTH-1:0] sampled_value;

    `uvm_object_utils_begin(gpio_item)
        `uvm_field_int(drive_value,   UVM_DEFAULT)
        `uvm_field_int(output_enable, UVM_DEFAULT)
        `uvm_field_int(sampled_value, UVM_DEFAULT | UVM_NOCOMPARE)
    `uvm_object_utils_end

    function new(string name = "gpio_item");
        super.new(name);
    endfunction
endclass
