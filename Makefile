# Define Verilog source files to keep commands clean
V_SOURCES = src/core/*.v src/memory/*.v src/peripherals/*.v src/bus/*.v src/*.v

# Define distinct testbenches for debugging and profiling
TB_SIM = sim/debug_tb.v
TB_PERF = sim/performance.v

.PHONY: all flash sim perf clean sw building synthesis route pack

# ==============================================================================
# DEFAULT COMMAND: make (Builds software, synthesizes, and flashes FPGA)
# ==============================================================================
all: flash

building: 
	mkdir -p build

# Centralized Software Build: Compiles OS, copies hex and elf to root
sw: building
	make timing DEVICE=riscv --directory=software/
	riscv-none-elf-objcopy -O verilog --verilog-data-width=4 --change-addresses -0x80000000 software/build/timing/peppzzartos.elf instruction_stream.hex

# ==============================================================================
# TASK 1: FPGA SYNTHESIS & FLASHING (make flash)
# ==============================================================================
synthesis: sw
	yosys -p "read_verilog -I src/core $(V_SOURCES); synth_gowin -top system -json build/cpu.json"

route: synthesis
	nextpnr-himbaechel --json build/cpu.json --write build/pnrled.json --device GW1NR-LV9QN88PC6/I5 --vopt family=GW1N-9C --vopt cst=constraints.cst

pack: route
	gowin_pack -d GW1N-9C -o build/cpu.fs build/pnrled.json

flash: pack
	openFPGALoader -b tangnano9k -f build/cpu.fs

# ==============================================================================
# TASK 2: STANDARD SIMULATION & WAVEFORMS (make sim)
# ==============================================================================
sim: tb_addrs.vh
	@echo "Compiling Simulation..."
	iverilog -I src/core -o build/sim.vvp $(TB_SIM) $(V_SOURCES)
	@echo "Running Simulation..."
	vvp build/sim.vvp > address_trace.txt
	@echo "Opening GTKWave..."
	gtkwave wave.vcd

# ==============================================================================
# TASK 3: PERFORMANCE PROFILING (make perf)
# ==============================================================================
# Auto-extracts memory addresses from the .elf file for the testbench
tb_addrs.vh: sw
	@echo "Extracting dynamic addresses for Verilog Co-Simulation..."
	@riscv-none-elf-nm software/build/timing/peppzzartos.elf | grep -w trap_start | awk '{print "`define TRAP_START 32'\''h" $$1}' > tb_addrs.vh
	@riscv-none-elf-nm software/build/timing/peppzzartos.elf | grep -w trap_end | awk '{print "`define TRAP_END 32'\''h" $$1}' >> tb_addrs.vh

perf: tb_addrs.vh
	@echo "Compiling Profiler..."
	iverilog -I src/core -o build/perf.vvp $(TB_PERF) $(V_SOURCES)
	@echo "Running Profiling Simulation (Terminal Output Only)..."
	vvp build/perf.vvp > performance_log.txt

# ==============================================================================
# CLEANUP
# ==============================================================================
clean:
	make clean --directory=software/
	rm -rf build abc.history instruction_stream.hex  tb_addrs.vh wave.vcd address_trace.txt performance_log.txt
