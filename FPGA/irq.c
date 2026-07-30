#include "irq.h"
#include <unistd.h>

volatile int irq_thread_ticks = 0;

void *irq_thread_func(void *arg){
    (void)arg;

    for(;;)
    {
        sleep(1);
        irq_thread_ticks++;
    }
    return NULL;
}