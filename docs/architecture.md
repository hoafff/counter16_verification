# Architecture notes

## Three layers

1. **Object/class layer**: sequence/generator, sequencer, driver, monitor and scoreboard exchange SystemVerilog objects.
2. **Bridge**: a `virtual counter_if` is only a handle/reference used by a class to access the one real `counter_if` instance.
3. **Signal layer**: the interface instance carries `clk`, `reset`, `enable` and `count` to/from the RTL module.

A transaction object does **not** pass through the DUT. The driver converts transaction fields into signals. On the output side, the monitor samples signals and creates a new observed object for the scoreboard.

## Counter contract

- Width: 16 bits.
- Reset: synchronous, active high.
- `enable=0`: hold the previous count.
- `enable=1`: increment at every rising edge.
- `16'hFFFF` followed by an enabled rising edge becomes `16'h0000`.

## Why drive and monitor around the falling edge?

The DUT samples controls on `posedge clk`. The driver clocking block drives new controls on `negedge clk`, providing half a cycle of setup margin in simulation. The monitor clocking block samples the controls that belonged to the preceding `posedge` plus the resulting `count`, so driver and monitor do not race each other.

## Base SV versus UVM

| Role | Base SystemVerilog | UVM |
|---|---|---|
| Stimulus object | `counter_transaction` | `counter_item extends uvm_sequence_item` |
| Stimulus producer | `counter_generator` | `uvm_sequence` |
| Producer-to-driver transport | typed `mailbox` | sequencer + `seq_item_port/export` |
| Pin driving | `counter_driver` | `counter_driver extends uvm_driver` |
| Observation | `counter_monitor` | `counter_monitor extends uvm_monitor` |
| Checking | `counter_scoreboard` | `counter_scoreboard extends uvm_scoreboard` |
| Container | `counter_env` | `counter_env extends uvm_env` |
| Top-level scenario | `counter_test` | `uvm_test` |
