class gpio_agent_config extends uvm_object;
    `uvm_object_utils(gpio_agent_config)

    // ACTIVE  : sequencer + driver + monitor
    // PASSIVE : monitor only
    uvm_active_passive_enum is_active = UVM_ACTIVE;
    virtual gpio_if vif;

    function new(string name = "gpio_agent_config");
        super.new(name);
    endfunction
endclass
