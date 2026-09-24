class counter_monitor extends uvm_monitor;
    `uvm_component_utils(counter_monitor)

    virtual counter_if vif;
    uvm_analysis_port #(counter_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual counter_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "counter_monitor could not get virtual interface")
    endfunction

    task run_phase(uvm_phase phase);
        counter_item observed;
        forever begin
            @(vif.mon_cb);
            observed = counter_item::type_id::create("observed");
            observed.reset  = vif.mon_cb.reset;
            observed.enable = vif.mon_cb.enable;
            observed.count  = vif.mon_cb.count;
            ap.write(observed);
        end
    endtask
endclass
