# GPIO UVC demo with Counter16

Branch: `feature/gpio-uvc`

## Goal

Build a reusable GPIO UVC and use Counter16 only as a small demonstration DUT.

The reusable UVC does **not** contain Counter16 names such as `reset`, `enable` or `count`.
Those meanings exist only in the demo adapter/test layer.

## Signal mapping used by the demo

```text
GPIO_OUT[0]  -> Counter16.reset
GPIO_OUT[1]  -> Counter16.enable

Counter16.count[15:0] -> GPIO_IN[15:0]
```

The clock remains a testbench clock and is not treated as a GPIO pin.

## Architecture

```text
gpio_counter_* sequence
          |
          v
+-----------------------+
|       GPIO UVC        |
| gpio_sequencer        |
|       |               |
| gpio_driver           |
|       |               |
|     gpio_if           |
|       |               |
| gpio_monitor ---------+------> analysis_port
+-------|---------------+             |
        |                             v
        |                   gpio_counter_scoreboard
        v
     Counter16
```

## Reusable UVC files

```text
gpio_uvc/
  gpio_if.sv
  gpio_item.sv
  gpio_config.sv
  gpio_sequences.sv
  gpio_sequencer.sv
  gpio_driver.sv
  gpio_monitor.sv
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

This separation is the important UVC idea:

- `gpio_uvc/` understands generic GPIO transactions.
- `gpio_demo/` gives GPIO bits Counter16-specific meaning.

## Tests

Smoke:

```bat
scripts\run_gpio_uvc_questa.bat
```

Explicit smoke:

```bat
scripts\run_gpio_uvc_questa.bat gpio_counter_smoke_test
```

Random:

```bat
scripts\run_gpio_uvc_questa.bat gpio_counter_random_test
```

Full 16-bit wrap:

```bat
scripts\run_gpio_uvc_questa.bat gpio_counter_wrap_test
```

The wrap test intentionally performs enough increments to prove:

```text
FFFE -> FFFF -> 0000 -> 0001
```

## What each UVC block demonstrates

| Block | UVM responsibility |
|---|---|
| `gpio_item` | Generic GPIO transaction |
| `gpio_sequence` | Creates transaction objects |
| `gpio_sequencer` | Arbitrates sequence items |
| `gpio_driver` | Converts transaction -> output pins |
| `gpio_monitor` | Converts pins -> observed transaction |
| `gpio_agent` | Packages driver/sequencer/monitor and supports active/passive mode |
| `gpio_agent_config` | Carries UVC mode and virtual interface |
| Counter demo scoreboard | Interprets GPIO bits and checks Counter16 behavior |

## Main point for presentation

A Counter16-specific agent knows the semantic names `reset`, `enable` and `count`.

The GPIO UVC instead knows only:

```text
gpio_out
gpio_in
```

The mapping to a particular DUT is done outside the UVC. This is what makes the component reusable.
