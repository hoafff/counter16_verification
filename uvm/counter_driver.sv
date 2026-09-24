class counter_driver extends uvm_driver #(counter_item);
    `uvm_component_utils(counter_driver)

    virtual counter_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual counter_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "counter_driver could not get virtual interface")
    endfunction

    task run_phase(uvm_phase phase);
        counter_item req;
        forever begin
            seq_item_port.get_next_item(req);

            // Convert transaction fields into pin-level interface signals.
            @(vif.drv_cb);
            vif.drv_cb.reset  <= req.reset;
            vif.drv_cb.enable <= req.enable;

            // The DUT consumes this item on the next rising edge.
            @(posedge vif.clk);
            seq_item_port.item_done();
        end
    endtask
endclass
