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
        int unsigned pin;

        forever begin
            @(vif.mon_cb);
            observed = gpio_item::type_id::create("observed");
            observed.drive_value   = vif.mon_cb.drive_value;
            observed.output_enable = vif.mon_cb.output_enable;
            observed.sampled_value = vif.mon_cb.gpio;

            // Generic GPIO electrical/logic sanity check:
            // when the UVC drives a pin, the resolved pin should match the
            // requested value. X/Z or another value indicates contention or
            // an unexpected external driver.
            for (pin = 0; pin < GPIO_WIDTH; pin++) begin
                if (observed.output_enable[pin] &&
                    observed.sampled_value[pin] !== observed.drive_value[pin]) begin
                    `uvm_warning("GPIO_CONTENTION",
                        $sformatf("pin=%0d drive=%b sampled=%b",
                                  pin,
                                  observed.drive_value[pin],
                                  observed.sampled_value[pin]))
                end
            end

            ap.write(observed);
        end
    endtask
endclass
