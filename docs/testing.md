# Testing

A trace-based framework is provided to verify the core's behaviour against the [Spike](https://github.com/riscv-software-src/riscv-isa-sim) RISC-V ISA simulator. Some sample test cases are included to get started.

## How It Works

1. A test program is compiled from RV32I assembly into an ELF file.
2. Spike runs the ELF and produces a reference execution trace.
3. The core runs the same program and its trace is diffed against Spike's output.

## Adding a Test Case

Write the program as an RV32I assembly file and place it in `testing/tests/`.

Generate the instruction stream and reference trace:
```sh
testing/gen.sh
```

Run the tests:
```sh
testing/test.sh
```

Each test prints its name alongside a `PASS` or `FAIL` verdict.
