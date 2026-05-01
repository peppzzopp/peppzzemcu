#!/usr/bin/env bash

TESTS_DIR=tests
BUILD_DIR=build
LOG_DIR=logs
MAP_DIR=maps
INSTR_DIR=instruction_streams
MAX_CYCLES=100

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || exit 1

mkdir -p "$BUILD_DIR"/{obj,bin,logs} "$LOG_DIR"/{spike,core} "$MAP_DIR" "$INSTR_DIR"

# assemble + link
find "$TESTS_DIR" -name "*.S" | while read -r specific_test; do
    one_test=$(basename "$specific_test" .S)

    riscv-none-elf-as "$specific_test" \
        -o "$BUILD_DIR/obj/$one_test.o"

    riscv-none-elf-ld \
        -T riscv.ld \
        -Map="$MAP_DIR/$one_test.map" \
        -o "$BUILD_DIR/bin/$one_test" \
        "$BUILD_DIR/obj/$one_test.o"

    riscv-none-elf-objdump -d "$BUILD_DIR/bin/$one_test" \
    | awk '
        /^[[:space:]]*[0-9a-f]+:/ {
            if ($2 ~ /^[0-9a-f]{8}$/)
                print $2
        }
    ' > "$INSTR_DIR/$one_test.hex"

done

# run spike
find "$BUILD_DIR/bin" -type f | while read -r specific_binary; do
    one_binary=$(basename "$specific_binary")

    timeout 1 spike --isa=RV32I -m0x80000000:0x1000,0x20000000:0x3E800 -l "$specific_binary" \
        &> "$BUILD_DIR/logs/$one_binary.log"
done

# extract trace
find "$BUILD_DIR/logs" -type f | while read -r specific_log; do
    one_log=$(basename "$specific_log")

    sed -E 's/.*: (0x[0-9a-f]+) \((0x[0-9a-f]+)\).*/\1 \2/' "$specific_log" \
        | sed -n '/0x80000000/,$p' > "$LOG_DIR/spike/$one_log"
done
