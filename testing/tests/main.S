.section .text
.globl _start

_start:

    # x1 = 5
    addi x1, x0, 5

    # x2 = 7
    addi x2, x0, 7

    # x3 = x1 + x2 = 12
    add x3, x1, x2

    # x4 = x3 << 1 = 24
    slli x4, x3, 1

    # x5 = x4 - x1 = 19
    sub x5, x4, x1

    # load address of result
    lui x6, %hi(result)
    addi x6, x6, %lo(result)

    # store result to memory
    sw x5, 0(x6)

done:
    j done

.section .data
result:
    .word 0
