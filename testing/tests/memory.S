.section .data
mem:
    .word 0

.section .text
.global _start

_start:
    lui x1, %hi(mem)
    addi x1, x1, %lo(mem)

    addi x2, x0, 42

    sw x2, 0(x1)
    lw x3, 0(x1)

done:
    jal x0, done
