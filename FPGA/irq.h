#ifndef IRQ_H
#define IRQ_H

//it should runs in a thread since it runs in blocking mode and ui should still repsonsive.
extern volatile int event_count;

void *irq_thread_func(void *arg);



#endif