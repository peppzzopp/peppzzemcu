#include "stdint.h"

#define HALF_SEC (13499999)

#define TIMER_COMPARE_LW (*(volatile uint32_t *)0x30000100)
#define TIMER_COMPARE_HW (*(volatile uint32_t *)0x30000104)
#define LED_GPIO (*(volatile uint32_t *)0x30000000)

extern uint32_t _etext;
extern uint32_t _sdata;
extern uint32_t _edata;
extern uint32_t _sbss;
extern uint32_t _ebss;
extern uint32_t _stack;

extern int main(void);

__attribute__((interrupt("machine"))) void timer_handler(void){
    uint32_t lw = TIMER_COMPARE_LW;
    uint32_t hw = TIMER_COMPARE_HW;
    
    uint64_t fw = ((uint64_t)hw << 32 | lw);
    fw += HALF_SEC;
    
    TIMER_COMPARE_HW = 0xFFFFFFFF;
    TIMER_COMPARE_LW = (uint32_t)fw;
    TIMER_COMPARE_HW = (uint32_t)(fw >> 32);

    LED_GPIO = LED_GPIO ^ 0x2a;
    
}

void init_machine_interrupts(void) {
    __asm__ volatile(
        "csrw mtvec, %0\n"
        "li t0, 0x80\n"
        "csrs mie, t0\n"
        "li t0, 0x8\n"
        "csrs mstatus, t0\n"
        : /* No outputs */
        : "r" (timer_handler)
        : "t0"
    );
}

void start_up(void);
__attribute__((naked, section(".text.entry"))) void _stack_setup(void){
    __asm__ volatile(
        "la sp, _stack\n"
        "j start_up\n"
    );
}

void start_up(void){
    uint32_t size_of_data = (uint32_t)&_edata - (uint32_t)&_sdata;

    uint8_t *pDst = (uint8_t *)&_sdata;
    uint8_t *pSrc = (uint8_t *)&_etext;

    for(uint32_t i=0; i<size_of_data; i++){
        *pDst++ = *pSrc++;
    }

    size_of_data = (uint32_t)&_ebss - (uint32_t)&_sbss;
    pDst = (uint8_t *)&_sbss;
    for(uint32_t i=0; i<size_of_data; i++){
        *pDst++ = 0;
    }
    init_machine_interrupts();
    TIMER_COMPARE_LW = HALF_SEC;
    TIMER_COMPARE_HW = 0x00000000;
    main();
}
