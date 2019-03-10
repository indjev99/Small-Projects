#include "phos.h"
#include "hardware.h"
#include <stdarg.h>

#define NBUF 64

#define GETBYTE 6
#define GETINT 7
#define GETROLL 8

static volatile int bufcnt;
static volatile unsigned buf[NBUF];

static int reader = -1;         /* Process waiting to read */
static int type = -1;           /* Type of return wanted */

/* rng_interrupt -- handle rng interrupt */
static void rng_interrupt(void) {
    if (RNG_VALRDY) {
        if (bufcnt < NBUF) {
            buf[bufcnt++] = RNG_VALUE;
        }
        RNG_VALRDY = 0;
    }
    enable_irq(RNG_IRQ);
}

static void reply() {
    message m;
    
    // Can we satisfy a reader?
    if (reader >= 0 && bufcnt) {
        if (type == GETBYTE) {
            m.m_type = REPLY;
            m.m_i1 = buf[--bufcnt];
            send(reader, &m);
            reader = -1;
        }
        else if (type == GETINT) {
            if (bufcnt >= 4) {
                m.m_type = REPLY;
                bufcnt -= 4;
                m.m_i1 = buf[bufcnt] << 24 | buf[bufcnt+1] << 16 | buf[bufcnt+2] << 8 | buf[bufcnt+3];
                send(reader, &m);
                reader = -1;
            }
        }
        else if (type == GETROLL) {
            unsigned temp = buf[--bufcnt];
            if (temp < 252) {
                m.m_type = REPLY;
                m.m_i1 = temp % 6 + 1;
                send(reader, &m);
                reader = -1;
            }
        }
    }
}

/* rng_task -- driver process for rng */
void rng_task(int n) {
    message m;

    RNG_START = 1;

    connect(RNG_IRQ);
    RNG_INTEN = BIT(RNG_INT_VALRDY);
    enable_irq(RNG_IRQ);

    while (1) {
        receive(ANY, &m);

        switch (m.m_type) {
        case INTERRUPT:
            rng_interrupt();
            break;

        case GETBYTE:
        case GETINT:
        case GETROLL:
            if (reader >= 0)
                panic("Two cannot wait for the rng at once");
            reader = m.m_sender;
            type = m.m_type;
            break;

        default:
            panic("rng driver got bad message %d", m.m_type);
        }

        reply();
    }
}

/* random_byte -- returns a random byte */
unsigned random_byte(void) {
    message m;
    m.m_type = GETBYTE;
    sendrec(RNG, &m);
    return m.m_i1;
}

/* random_int -- returns a random int */
unsigned random_int(void) {
    message m;
    m.m_type = GETINT;
    sendrec(RNG, &m);
    return m.m_i1;
}

/* roll -- returns 1-6 */
unsigned roll(void) {
    message m;
    m.m_type = GETROLL;
    sendrec(RNG, &m);
    return m.m_i1;
}

/* rng_init -- start the rng task */
void rng_init(void) {
    start(RNG, "RNG", rng_task, 0, STACK);
}
