# PEPPZZEMCU

A multicycle RV32I soft-core implementation in **verilog** targeting the **Sipeed Tang Nano 9K FPGA**.

## Extensions

- **Zicsr** — CSR read/write access
- **Machine mode** — M-mode privilege level
- **Interrupt & trap handling** — synchronous traps, timer/external interrupts
- **Privileged instructions** — `ecall`, `ebreak`, `mret`

## Design

- The core uses a multicycle architecture connected over an AXI4-Lite bus. A peripheral AXI controller manages the memory map, with a GPIO peripheral wired to the Tang Nano 9K's onboard LEDs.
- Timer and GPIO peripherals are populated.
- See [`architecture`](docs/architecture.md) for more details.

## Limitations

- Not pipelined — expect 3–5 CPI depending on the workload.
- Behaviour outside tested scenarios is undefined.

## Demo

- Startup and application code lives in `software/`.
- It is a separate project at [@peppzzartos](https://github.com/peppzzopp/peppzzartos), a custom RTOS with a working port to PEPPZZEMCU.
- Flash it to a Tang Nano 9K to see the LEDs blink.
- For running different program, see [`software`](docs/software.md)

## Building
- Clone the repository and run `make all`.
- This compiles the firmware in `software/` and etches it into the core's instruction memory before flashing the connected FPGA.
- Constraints are currently provided only for the **Tang Nano 9K**.
- The toolchain is entirely opensource **yosys**, **next-pnr** paired with **project apicula** and **openFPGALoader**.
- See [`software`](docs/software.md) for more details.

## Other Modes
- Debug and performance measurement testbenches are also provided.
- Run `make sim` to get the execution trace in **address_trace.txt** and open gtkwave for debugging.
- Run `make perf` to get the trap overhead of [peppzzartos](https://github.com/peppzzopp/peppzzartos) in **performance_log.txt**

## Testing

- A trace-based testing framework is included under `testing/`. 
- It runs the core and diffs the output against the [Spike](https://github.com/riscv-software-src/riscv-isa-sim) RISC-V ISA simulator. 
- See [`testing`](docs/testing.md) for more details.
