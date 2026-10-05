class gpio_counter_base_sequence extends gpio_base_sequence;
    `uvm_object_utils(gpio_counter_base_sequence)

    function new(string name = "gpio_counter_base_sequence");
        super.new(name);
    endfunction

    task drive_control(bit reset, bit enable);
        bit [GPIO_WIDTH-1:0] value;
        value = '0;

        // Counter16 mapping used only by this demo:
        // GPIO_OUT[0] -> reset
        // GPIO_OUT[1] -> enable
        value[0] = reset;
        value[1] = enable;
        send_gpio(value);
    endtask
endclass

class gpio_counter_reset_sequence extends gpio_counter_base_sequence;
    `uvm_object_utils(gpio_counter_reset_sequence)

    function new(string name = "gpio_counter_reset_sequence");
        super.new(name);
    endfunction

    task body();
        repeat (3) drive_control(1'b1, 1'b0);
        drive_control(1'b0, 1'b0);
    endtask
endclass

class gpio_counter_smoke_sequence extends gpio_counter_base_sequence;
    `uvm_object_utils(gpio_counter_smoke_sequence)

    function new(string name = "gpio_counter_smoke_sequence");
        super.new(name);
    endfunction

    task body();
        repeat (8) drive_control(1'b0, 1'b1);
        repeat (3) drive_control(1'b0, 1'b0);
        repeat (5) drive_control(1'b0, 1'b1);
        repeat (2) drive_control(1'b1, 1'b0);
        drive_control(1'b0, 1'b0);
        repeat (4) drive_control(1'b0, 1'b1);
        repeat (2) drive_control(1'b0, 1'b0);
    endtask
endclass

class gpio_counter_wrap_sequence extends gpio_counter_base_sequence;
    `uvm_object_utils(gpio_counter_wrap_sequence)

    function new(string name = "gpio_counter_wrap_sequence");
        super.new(name);
    endfunction

    task body();
        // 65535 increments reach FFFF; the next one wraps to 0000.
        repeat (16'hFFFF + 3)
            drive_control(1'b0, 1'b1);
        repeat (2)
            drive_control(1'b0, 1'b0);
    endtask
endclass

class gpio_counter_random_sequence extends gpio_counter_base_sequence;
    `uvm_object_utils(gpio_counter_random_sequence)

    int unsigned num_items = 200;

    function new(string name = "gpio_counter_random_sequence");
        super.new(name);
    endfunction

    task body();
        bit reset;
        bit enable;

        repeat (num_items) begin
            if (!std::randomize(reset, enable) with {
                reset  dist {1'b0 := 95, 1'b1 := 5};
                enable dist {1'b0 := 30, 1'b1 := 70};
            })
                `uvm_fatal("GPIO_DEMO_RAND", "Could not randomize reset/enable")
            drive_control(reset, enable);
        end
    endtask
endclass
