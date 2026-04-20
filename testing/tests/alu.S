.section .text
.global _start

_start:
    addi x1, x0, 10
    addi x2, x0, 3

    add x3, x1, x2
    sub x4, x1, x2

    and x5, x1, x2
    or  x6, x1, x2
    xor x7, x1, x2

    slt  x8, x2, x1
    sltu x9, x2, x1

    sll x10, x1, x2
    srl x11, x1, x2
    sra x12, x1, x2

done:
    jal x0, done
