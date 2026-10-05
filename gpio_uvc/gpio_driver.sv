class gpio_driver extends uvm_driver #(gpio_item);
    `uvm_component_utils(gpio_driver)

    virtual gpio_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db#(virtual gpio_if)::get(this, "", "vif", vif))
            `uvm_fatal("GPIO_NOVIF", "gpio_driver could not get virtual interface")
    endfunction

    task run_phase(uvm_phase phase);
        gpio_item req;

        forever begin
            seq_item_port.get_next_item(req);

            // Transaction -> GPIO pins:
            // 1) output_enable selects OUTPUT versus INPUT/Hi-Z per pin.
            // 2) drive_value is visible on pins whose output_enable bit is 1.
            @(vif.drv_cb);
            vif.drv_cb.drive_value   <= req.drive_value;
            vif.drv_cb.output_enable <= req.output_enable;

            @(posedge vif.clk);
            seq_item_port.item_done();
        end
    endtask
endclass
