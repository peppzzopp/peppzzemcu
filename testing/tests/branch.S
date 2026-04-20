.section .text
.global _start

_start:
    addi x1, x0, 5
    addi x2, x0, 5
    addi x3, x0, 3

    beq x1, x2, label1
    addi x0, x0, 0

label1:
    bne x1, x3, label2
    addi x0, x0, 0

label2:
    blt x3, x1, label3
    addi x0, x0, 0

label3:
    bge x1, x3, label4
    addi x0, x0, 0

label4:
    bltu x3, x1, label5
    addi x0, x0, 0

label5:
    bgeu x1, x3, done
    addi x0, x0, 0

done:
    jal x0, done
