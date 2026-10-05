class gpio_counter_base_sequence extends gpio_base_sequence;
    `uvm_object_utils(gpio_counter_base_sequence)

    function new(string name = "gpio_counter_base_sequence");
        super.new(name);
    endfunction

    task drive_control(bit reset, bit enable);
        bit [GPIO_WIDTH-1:0] value;
        bit [GPIO_WIDTH-1:0] oe;

        value = '0;
        oe    = '0;

        // Counter16 demo mapping on one bidirectional GPIO bank:
        // pin 0     : OUTPUT -> reset
        // pin 1     : OUTPUT -> enable
        // pins 2..17: INPUT  <- count[15:0]
        value[0] = reset;
        value[1] = enable;
        oe[0]    = 1'b1;
        oe[1]    = 1'b1;

        // count pins remain oe=0, therefore the UVC releases them to Hi-Z.
        send_gpio(value, oe);
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
