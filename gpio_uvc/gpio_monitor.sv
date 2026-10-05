class gpio_monitor extends uvm_monitor;
    `uvm_component_utils(gpio_monitor)

    virtual gpio_if vif;
    uvm_analysis_port #(gpio_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual gpio_if)::get(this, "", "vif", vif))
            `uvm_fatal("GPIO_NOVIF", "gpio_monitor could not get virtual interface")
    endfunction

    task run_phase(uvm_phase phase);
        gpio_item observed;

        forever begin
            @(vif.mon_cb);
            observed = gpio_item::type_id::create("observed");
            observed.gpio_out = vif.mon_cb.gpio_out;
            observed.gpio_in  = vif.mon_cb.gpio_in;
            ap.write(observed);
        end
    endtask
endclass
