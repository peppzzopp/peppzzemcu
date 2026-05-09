#!/bin/bash

STREAMS_DIR=testing/instruction_streams/
LOGS_DIR=testing/logs/core/
SPIKE_DIR=testing/logs/spike/

echo "Testing the Core:"
 iverilog -o system.vvp -I src/core sim/gs_tb.v src/core/alu.v src/core/core.v src/core/decoder.v src/core/lsu.v src/core/core_registers.v src/core/control_registers.v src/memory/memory.v src/system.v src/core/control.v src/core/csr.v src/core/trap_encoder.v src/bus/axi4_lite.v src/core/axi_master.v src/peripherals/gpio.v src/peripherals/axi_peripheral.v src/peripherals/timer.v

 # generate DUT logs
 find "$STREAMS_DIR" -name "*.hex" | while read -r specific_stream; do
    one_stream=$(basename "$specific_stream" .hex)

    cp "$specific_stream" instruction_stream.hex

    vvp system.vvp | awk '
    /^0x80000000 / { start=1 }
    start && /^0x[0-9a-f]+ 0x[0-9a-f]+$/ && $2 != "0xxxxxxxxx" {
        print
    }
    ' > "$LOGS_DIR/$one_stream.log"
done

# compare with spike
for specific_log in "$LOGS_DIR"/*.log; do
    one_log=$(basename "$specific_log")
    spike_file="$SPIKE_DIR/$one_log"

    if [ ! -f "$spike_file" ]; then
        echo "$one_log : MISSING SPIKE LOG"
        continue
    fi

    lines=$(wc -l < "$spike_file")

    printf "%-20s : " "$one_log"

    if diff -q "$spike_file" <(head -n "$lines" "$specific_log") > /dev/null; then
        echo "PASS"
    else
        echo "FAIL"
        diff -u "$spike_file" <(head -n "$lines" "$specific_log")
    fi
done

rm instruction_stream.hex system.vvp wave.vcd
