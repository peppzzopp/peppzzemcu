.section .text
.globl _start
_start:
    lui x1, 0x30000      # GPIO Base: 0x30000000
    addi x2, x0, 0x21    # Pattern: 100001
    sw x2, 0(x1)         # Store to GPIO
done:
    jal x0, done
