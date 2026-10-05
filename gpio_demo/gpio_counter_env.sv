class gpio_counter_env extends uvm_env;
    `uvm_component_utils(gpio_counter_env)

    gpio_agent              agent;
    gpio_counter_scoreboard scoreboard;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent      = gpio_agent::type_id::create("agent", this);
        scoreboard = gpio_counter_scoreboard::type_id::create("scoreboard", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.monitor.ap.connect(scoreboard.analysis_imp);
    endfunction
endclass
