.section .text
.global _start

_start:
    lui x1, 0x12345
    auipc x2, 0

done:
    jal x0, done
