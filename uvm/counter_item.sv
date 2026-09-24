class counter_item extends uvm_sequence_item;
    rand bit reset;
    rand bit enable;
    logic [15:0] count;

    `uvm_object_utils_begin(counter_item)
        `uvm_field_int(reset,  UVM_DEFAULT)
        `uvm_field_int(enable, UVM_DEFAULT)
        `uvm_field_int(count,  UVM_DEFAULT | UVM_NOCOMPARE)
    `uvm_object_utils_end

    function new(string name = "counter_item");
        super.new(name);
    endfunction
endclass
