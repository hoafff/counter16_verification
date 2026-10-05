class gpio_counter_base_test extends uvm_test;
    `uvm_component_utils(gpio_counter_base_test)

    gpio_counter_env env;
    gpio_agent_config cfg;
    virtual gpio_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db#(virtual gpio_if)::get(this, "", "vif", vif))
            `uvm_fatal("GPIO_TEST_NOVIF", "gpio_counter_base_test could not get virtual interface")

        cfg = gpio_agent_config::type_id::create("cfg");
        cfg.vif       = vif;
        cfg.is_active = UVM_ACTIVE;

        // Configuration is supplied before env/agent build.
        uvm_config_db#(gpio_agent_config)::set(this, "env.agent", "cfg", cfg);

        env = gpio_counter_env::type_id::create("env", this);
    endfunction

    function void end_of_elaboration_phase(uvm_phase phase);
        super.end_of_elaboration_phase(phase);
        uvm_top.print_topology();
    endfunction

    task drain_monitor();
        repeat (2) @(vif.mon_cb);
    endtask
endclass

class gpio_counter_smoke_test extends gpio_counter_base_test;
    `uvm_component_utils(gpio_counter_smoke_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        gpio_counter_reset_sequence rst_seq;
        gpio_counter_smoke_sequence smoke_seq;

        phase.raise_objection(this);

        rst_seq   = gpio_counter_reset_sequence::type_id::create("rst_seq");
        smoke_seq = gpio_counter_smoke_sequence::type_id::create("smoke_seq");

        rst_seq.start(env.agent.sequencer);
        smoke_seq.start(env.agent.sequencer);

        drain_monitor();
        phase.drop_objection(this);
    endtask
endclass

class gpio_counter_wrap_test extends gpio_counter_base_test;
    `uvm_component_utils(gpio_counter_wrap_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        gpio_counter_reset_sequence rst_seq;
        gpio_counter_wrap_sequence wrap_seq;

        phase.raise_objection(this);

        rst_seq  = gpio_counter_reset_sequence::type_id::create("rst_seq");
        wrap_seq = gpio_counter_wrap_sequence::type_id::create("wrap_seq");

        rst_seq.start(env.agent.sequencer);
        wrap_seq.start(env.agent.sequencer);

        drain_monitor();
        phase.drop_objection(this);
    endtask
endclass

class gpio_counter_random_test extends gpio_counter_base_test;
    `uvm_component_utils(gpio_counter_random_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        gpio_counter_reset_sequence  rst_seq;
        gpio_counter_random_sequence random_seq;

        phase.raise_objection(this);

        rst_seq    = gpio_counter_reset_sequence::type_id::create("rst_seq");
        random_seq = gpio_counter_random_sequence::type_id::create("random_seq");

        rst_seq.start(env.agent.sequencer);
        random_seq.start(env.agent.sequencer);

        drain_monitor();
        phase.drop_objection(this);
    endtask
endclass
