OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY
{
    ROM (rx)  : ORIGIN = 0x80000000, LENGTH = 4K
    RAM (rwx) : ORIGIN = 0x20000000, LENGTH = 250K
}

SECTIONS
{
    .text : ALIGN(4)
    {
        *(.text)
        *(.text.*)
    } > ROM

    .rodata : ALIGN(4)
    {
        *(.rodata*)
        *(.srodata*)
    } > ROM

    .data : ALIGN(4)
    {
        *(.data*)
        *(.sdata*)
    } > RAM

    .bss : ALIGN(4)
    {
        *(.bss*)
        *(.sbss*)
        *(COMMON)
    } > RAM
}
