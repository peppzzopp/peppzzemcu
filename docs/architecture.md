# Architecture

## Overview

- PEPPZZEMCU is a multicycle RV32I core. Each instruction takes multiple clock cycles to complete, passing through fetch, decode, execute, memory and writeback stages sequentially. 
- There is no pipelining.

## Core

- **ISA:** RV32I + Zicsr, Machine mode
- **Architecture:** Multicycle, single-issue
- **CPI:** 3–5 depending on instruction type
- **Initial PC:** `0x80000000`

## Bus

The core, memory, and peripherals communicate over an **AXI4-Lite** interconnect. A central peripheral AXI controller decodes the address and routes transactions to the appropriate subordinate.

## Memory Map

| Region      | Base         | Size   | Description              |
|-------------|--------------|--------|--------------------------|
| Instruction | `0x80000000` | 16 KB  | On-chip instruction ROM  |
| Data        | `0x20000000` | 32 KB  | On-chip data RAM         |
| GPIO        | `0x30000000` |   -    | GPIO peripheral          |
| Timer       | `0x30000100` | 4B     | Machine timer (MTIME)    |

## Peripherals

### GPIO
Mapped to the Tang Nano 9K's onboard LEDs. Exposes a data register and direction register at the base address.

### Timer
- Implements the RISC-V machine timer registers `mtime` and `mtimecmp`. A timer interrupt is raised when `mtime >= mtimecmp`.
- Software is responsible for increasing the `mtimecmp` appropriately.

## Interrupt & Trap Handling

Traps are handled synchronously. On an interrupt or exception, the core:

1. Saves the PC to `mepc`
2. Records the cause in `mcause`
3. Jumps to the trap vector in `mtvec`
4. `mtvec` register to be set in the software before enabling any traps.

Return from a trap is via `mret`, which restores execution from `mepc`.
