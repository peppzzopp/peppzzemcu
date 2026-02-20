all:
	iverilog -o sim.out core_tb.v design.v
	vvp sim.out
	gtkwave wave.vcd

clean:
	rm sim.out wave.vcd log.txt
