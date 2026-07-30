#ifndef IRQ_H
#define IRQ_H

//it should runs in a thread since it runs in blocking mode and ui should still repsonsive.
extern volatile int irq_thread_ticks;

void *irq_thread_func(void *arg);



#endif