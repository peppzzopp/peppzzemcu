#!/bin/bash

STREAMS_DIR=testing/instruction_streams/
LOGS_DIR=testing/logs/core/
SPIKE_DIR=testing/logs/spike/

echo "Testing the Core:"
iverilog -o sim.out gs_tb.v design.v

# generate DUT logs
find "$STREAMS_DIR" -name "*.hex" | while read -r specific_stream; do
    one_stream=$(basename "$specific_stream" .hex)

    cp "$specific_stream" instruction_stream.hex

    vvp sim.out | awk '
    /^0x80000000 / { start=1 }
    start && /^0x[0-9a-f]+ 0x[0-9a-f]+$/ && $2 != "0xxxxxxxxx" {
        print
    }
    ' | tail -n +2 > "$LOGS_DIR/$one_stream.log"
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

rm instruction_stream.hex sim.out wave.vcd
