# Mapping sơ đồ UVM sang code

Tài liệu này dùng khi present: mỗi node trên sơ đồ tương ứng với một file/class, còn mỗi mũi tên tương ứng với một kết nối hoặc lời gọi cụ thể trong code.

## 1. Luồng chính

```text
Test
  -> Sequence
  -> Sequencer
  -> Driver
  -> Interface
  -> DUT
  -> Monitor
  -> Scoreboard + Coverage

Assertions quan sát DUT song song ở mức signal/timing.
```

## 2. Node -> file

| Node trên sơ đồ | File |
|---|---|
| Transaction | `uvm/counter_item.sv` |
| Sequence | `uvm/counter_sequences.sv` |
| Sequencer | `uvm/counter_sequencer.sv` |
| Driver | `uvm/counter_driver.sv` |
| Interface | `common/counter_if.sv` |
| DUT | `rtl/counter16.sv` |
| Monitor | `uvm/counter_monitor.sv` |
| Scoreboard | `uvm/counter_scoreboard.sv` |
| Coverage | `uvm/counter_coverage.sv` |
| Assertions | `common/counter_assertions.sv` |
| Agent | `uvm/counter_agent.sv` |
| Environment | `uvm/counter_env.sv` |
| Test | `uvm/counter_tests.sv` |
| Top | `uvm/tb_top.sv` |

## 3. Mũi tên -> code

### Sequence -> Sequencer -> Driver

Driver lấy item bằng:

```systemverilog
seq_item_port.get_next_item(req);
...
seq_item_port.item_done();
```

Driver và Sequencer được nối trong `counter_agent.sv`:

```systemverilog
driver.seq_item_port.connect(sequencer.seq_item_export);
```

### Driver -> Interface

Đây là điểm object -> signal:

```systemverilog
vif.drv_cb.reset  <= req.reset;
vif.drv_cb.enable <= req.enable;
```

### Interface -> Monitor

Đây là điểm signal -> object:

```systemverilog
observed.reset  = vif.mon_cb.reset;
observed.enable = vif.mon_cb.enable;
observed.count  = vif.mon_cb.count;
```

Sau đó Monitor broadcast:

```systemverilog
ap.write(observed);
```

### Monitor -> Scoreboard + Coverage

Trong `counter_env.sv`:

```systemverilog
agent.monitor.ap.connect(scoreboard.analysis_imp);
agent.monitor.ap.connect(coverage.analysis_export);
```

Một analysis port có thể broadcast cùng transaction cho nhiều consumer.

## 4. Directed vs constrained-random

- `counter_smoke_sequence`: directed stimulus, biết trước scenario.
- `counter_wrap_sequence`: directed corner case để ép DUT đi qua FFFF -> 0000.
- `counter_random_sequence`: constrained-random stimulus để mở rộng không gian test.

## 5. Scoreboard vs Coverage vs Assertions

- Scoreboard: DUT có cho kết quả đúng không?
- Coverage: ta đã test đủ các tình huống mong muốn chưa?
- Assertions: quan hệ signal/timing theo từng chu kỳ có đúng property không?

## 6. Test chạy trên QuestaSim

Smoke:

```bat
scripts\run_uvm_questa.bat
```

Wrap:

```bat
scripts\run_uvm_wrap_questa.bat
```

Random:

```bat
scripts\run_uvm_random_questa.bat
```

Hoặc đặt trực tiếp:

```bat
set UVM_TESTNAME=counter_random_test
cd uvm
vsim -c -do run_questa.do
```

Khi chạy, `uvm_top.print_topology()` sẽ in hierarchy UVM thực tế để đối chiếu trực tiếp với sơ đồ.
