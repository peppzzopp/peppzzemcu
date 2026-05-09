# Software
Running a program on the core requires firmware to be compiled into an instruction stream before synthesizing the design. This ensures it gets etched into instruction memory according to the linker script.

## Writing Software
It is recommended to separate application logic from startup logic.

The startup code is responsible for:
1. Initializing the `.text` and `.data` sections in memory
2. Setting up the stack
3. Populating `mtvec` with the trap handler address before enabling interrupts

The application code then implements the trap handlers as needed.

## Timer Interrupts
A timer interrupt fires whenever `mtime >= mtimecmp`. Since `mtime` is never reset to zero, the interrupt line stays high until `mtimecmp` is updated. The interrupt handler should read the current `mtimecmp`, add the desired interval, and write it back.

## Constraints
The project is not FPGA-specific and can be synthesized on any target. In the current setup, the GPIO is connected to the **Tang Nano 9K** through `constraints.cst`. To target a different board, replace it with the appropriate constraints file.

## Building
With startup and application logic in place under `software/`, run:

```sh
make all
```
This compiles the firmware, synthesizes the design with it etched into instruction memory, and flashes it to the connected FPGA. The directory structure must match the existing layout to remain compatible with the root Makefile.

**To be compatible with the core building makefile, a makefile should be presented in the `software/` directory that compiles and produces the instruction_stream.hex file**
