class counter_base_test extends uvm_test;
    `uvm_component_utils(counter_base_test)

    counter_env env;
    virtual counter_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = counter_env::type_id::create("env", this);
        if (!uvm_config_db#(virtual counter_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "counter_base_test could not get virtual interface")
    endfunction

    task drain_monitor();
        // Sequence completion occurs after the DUT consumed the last item at a
        // rising edge. Wait for falling edges so the monitor and scoreboard can
        // publish/check that final result before the objection is dropped.
        repeat (2) @(vif.mon_cb);
    endtask
endclass

class counter_smoke_test extends counter_base_test;
    `uvm_component_utils(counter_smoke_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        counter_reset_sequence rst_seq;
        counter_smoke_sequence smoke_seq;

        phase.raise_objection(this);
        rst_seq   = counter_reset_sequence::type_id::create("rst_seq");
        smoke_seq = counter_smoke_sequence::type_id::create("smoke_seq");

        rst_seq.start(env.agent.sequencer);
        smoke_seq.start(env.agent.sequencer);
        drain_monitor();
        phase.drop_objection(this);
    endtask
endclass

class counter_wrap_test extends counter_base_test;
    `uvm_component_utils(counter_wrap_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        counter_reset_sequence rst_seq;
        counter_wrap_sequence wrap_seq;

        phase.raise_objection(this);
        rst_seq  = counter_reset_sequence::type_id::create("rst_seq");
        wrap_seq = counter_wrap_sequence::type_id::create("wrap_seq");

        rst_seq.start(env.agent.sequencer);
        wrap_seq.start(env.agent.sequencer);
        drain_monitor();
        phase.drop_objection(this);
    endtask
endclass
