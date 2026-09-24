# Questions to be able to answer during the demo

1. **What is the DUT?** The `counter16` RTL module being verified.
2. **What does the sequence send?** A transaction object containing the intended control values; it does not send itself.
3. **Sequence vs sequencer?** The sequence creates the ordered stimulus; the sequencer arbitrates/serves sequence items to the driver.
4. **What goes from sequencer to driver?** A `counter_item` object handle through the UVM sequence-item TLM connection.
5. **Why not connect the driver class directly to DUT ports?** Classes are dynamic software-like objects, not structural HDL instances with module ports. They access the static signal interface through a virtual-interface handle.
6. **Interface vs virtual interface?** `counter_if intf()` is the real simulation interface instance containing signals. `virtual counter_if vif` is only a class handle pointing to that instance.
7. **Where does object-to-signal conversion happen?** In the driver.
8. **Where does signal-to-object conversion happen?** In the monitor.
9. **Why does the scoreboard receive monitor data instead of sequence data?** It must check what the DUT actually produced, not what the test intended to send.
10. **What happens at `16'hFFFF`?** On the next enabled rising edge the DUT explicitly wraps to `16'h0000`.
