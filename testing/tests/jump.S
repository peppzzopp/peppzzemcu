.section .text
.global _start

_start:
    jal x1, func

after_return:
    jal x0, done

func:
    addi x2, x0, 10
    jalr x0, x1, 0

done:
    jal x0, done
