# Pin-level GPIO UVC demo with Counter16

Branch: `feature/gpio-uvc`

## Goal

Build a reusable **pin-level GPIO UVC** and use Counter16 only as a small demonstration DUT.

The GPIO-specific behavior is now explicit:

- configurable GPIO value per pin;
- input/output direction through `output_enable`;
- tri-state/Hi-Z release for input pins;
- monitoring of the **resolved physical pin value**;
- active/passive UVM agent mode.

The reusable UVC does not know Counter16 names such as `reset`, `enable` or `count`.
Those meanings exist only in `gpio_demo/`.

## GPIO transaction

```text
gpio_item
├── drive_value[17:0]      value requested on output pins
├── output_enable[17:0]    1 = OUTPUT, 0 = INPUT/Hi-Z
└── sampled_value[17:0]    resolved value observed on physical pins
```

This is the key difference from a normal digital transaction: direction and tri-state behavior are part of the GPIO abstraction.

## Counter16 demo pin mapping

One 18-pin GPIO bank is used:

```text
GPIO pin 0      OUTPUT  -> Counter16.reset
GPIO pin 1      OUTPUT  -> Counter16.enable
GPIO pins 2..17 INPUT   <- Counter16.count[15:0]
```

For pins 0 and 1:

```text
output_enable = 1
UVC driver -> drive_value -> physical GPIO pin -> Counter16
```

For pins 2..17:

```text
output_enable = 0
UVC releases pin to Z
Counter16.count -> physical GPIO pin -> monitor.sampled_value
```

The clock remains a testbench clock and is not treated as a GPIO pin.

## Architecture

```text
Counter-specific GPIO sequence
             |
             v
      gpio_item transaction
 drive_value + output_enable
             |
             v
+----------------------------------+
|          REUSABLE GPIO UVC       |
|                                  |
| gpio_sequencer -> gpio_driver    |
|                       |          |
|                       v          |
|                    gpio_if       |
|              drive / OE / Hi-Z   |
|                       |          |
| physical GPIO pins ---+          |
|                       |          |
|                 gpio_monitor     |
|                       |          |
+-----------------------|----------+
                        v
                 sampled_value
                        |
                        v
            Counter16 scoreboard
```

## Reusable UVC files

```text
gpio_uvc/
  gpio_if.sv          physical tri-state GPIO bank
  gpio_item.sv        value + direction/OE + sampled value
  gpio_config.sv      active/passive configuration
  gpio_sequences.sv   generic GPIO stimulus
  gpio_sequencer.sv
  gpio_driver.sv      transaction -> drive_value/OE
  gpio_monitor.sv     physical pins -> sampled_value
  gpio_agent.sv
  gpio_uvc_pkg.sv
```

The agent supports:

- `UVM_ACTIVE`: sequencer + driver + monitor
- `UVM_PASSIVE`: monitor only

## Counter16 demo files

```text
gpio_demo/
  gpio_counter_sequences.sv
  gpio_counter_scoreboard.sv
  gpio_counter_env.sv
  gpio_counter_tests.sv
  gpio_counter_pkg.sv
  tb_top_gpio.sv
  filelist.f
  run_questa.do
```

## Tests

Smoke:

```bat
scripts\run_gpio_uvc_questa.bat
```

Random:

```bat
scripts\run_gpio_uvc_questa.bat gpio_counter_random_test
```

Full wrap:

```bat
scripts\run_gpio_uvc_questa.bat gpio_counter_wrap_test
```

The wrap test proves:

```text
FFFE -> FFFF -> 0000 -> 0001
```

## What makes this GPIO-specific?

A generic UVM agent normally only proves a sequence/sequencer/driver/monitor structure.
This UVC additionally models the properties of GPIO pins themselves:

```text
per-pin value
+ per-pin direction/output-enable
+ Hi-Z when configured as input
+ resolved pin sampling
```

Therefore it is no longer just a `counter_agent` with GPIO names.
