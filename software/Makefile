CC      = riscv-none-elf-gcc
LD      = riscv-none-elf-ld
OBJCPY  = riscv-none-elf-objcopy
OBJDUMP = riscv-none-elf-objdump

ARCH_FLAGS = -march=rv32i_zicsr -mabi=ilp32
SRCS = startup.c main.c
OBJS = $(SRCS:.c=.o)

.PHONY: all clean

all: elf stream

elf: $(OBJS)
	$(LD) -T riscv.ld $(OBJS) -o peppzzemcu.elf

%.o: %.c
	$(CC) $(ARCH_FLAGS) -c $< -o $@

stream: peppzzemcu.elf
	$(OBJDUMP) -d $< \
	| awk '/^[[:space:]]*[0-9a-f]+\072/ { if ($$2 ~ /^[0-9a-f]{8}$$/) print $$2 }' \
	> instruction_stream.hex

clean:
	rm -f $(OBJS) peppzzemcu.elf instruction_stream.hex
