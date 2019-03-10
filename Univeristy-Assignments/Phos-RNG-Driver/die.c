#include "phos.h"
#include "hardware.h"
#include "lib.h"
#include <string.h>

void process(int n) {
    GPIO_DIR=0xfff0;
    GPIO_PINCNF[BUTTON_A]=0;
    GPIO_PINCNF[BUTTON_B]=0;

    unsigned die;
    unsigned prev = 0;
    unsigned curr;
    while (1) {
        delay(1000);
        curr = !(GPIO_IN & BIT(BUTTON_A));
        if (curr && !prev) {
            die = roll();
            serial_printf("You rolled a %d\r\n", die);
        }
        prev = curr;
    }
}

void init(void) {
    serial_init();
    timer_init();
    rng_init();
    start(USER+0, "Die", process, 0, STACK);
}
