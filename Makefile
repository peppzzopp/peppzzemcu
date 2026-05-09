all: synthesis route pack flash

building: 
	mkdir -p build

synthesis: building
	make all --directory=software/
	cp software/instruction_stream.hex ./
	yosys -p "read_verilog -I src/core src/core/*.v src/memory/*.v src/peripherals/*.v src/bus/*.v src/*.v; synth_gowin -top system -json build/cpu.json"

route: building
	nextpnr-himbaechel --json build/cpu.json --write build/pnrled.json --device GW1NR-LV9QN88PC6/I5 --vopt family=GW1N-9C --vopt cst=constraints.cst

pack: building
	gowin_pack -d GW1N-9C -o build/cpu.fs build/pnrled.json

flash: building
	openFPGALoader -b tangnano9k -f build/cpu.fs

clean: building
	rm -rf build abc.history instruction_stream.hex
