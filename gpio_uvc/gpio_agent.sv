class gpio_agent extends uvm_agent;
    `uvm_component_utils(gpio_agent)

    gpio_agent_config cfg;
    gpio_sequencer    sequencer;
    gpio_driver       driver;
    gpio_monitor      monitor;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(gpio_agent_config)::get(this, "", "cfg", cfg))
            `uvm_fatal("GPIO_NOCFG", "gpio_agent could not get gpio_agent_config")

        if (cfg.vif == null)
            `uvm_fatal("GPIO_NOVIF", "gpio_agent_config.vif is null")

        monitor = gpio_monitor::type_id::create("monitor", this);
        uvm_config_db#(virtual gpio_if)::set(this, "monitor", "vif", cfg.vif);

        if (cfg.is_active == UVM_ACTIVE) begin
            sequencer = gpio_sequencer::type_id::create("sequencer", this);
            driver    = gpio_driver::type_id::create("driver", this);
            uvm_config_db#(virtual gpio_if)::set(this, "driver", "vif", cfg.vif);
        end
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        if (cfg.is_active == UVM_ACTIVE)
            driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
endclass
