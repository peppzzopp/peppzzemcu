.section .text
.global _start

_start:
    addi x1, x0, 5

    addi x2, x1, 10
    andi x3, x1, 3
    ori  x4, x1, 8
    xori x5, x1, 1

    slti  x6, x1, 10
    sltiu x7, x1, 10

    slli x8, x1, 2
    srli x9, x1, 1
    srai x10, x1, 1

done:
    jal x0, done
