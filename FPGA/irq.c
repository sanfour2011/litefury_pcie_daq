#include <fcntl.h>
#include "irq.h"
#include <unistd.h>
#include "pcie_device.h"

volatile int event_count = 0;

// Never ever call this function in a loop
// no close() here on purpose, this thread never exits (infinite loop),
// fd stays open till the whole program dies anyway, OS cleans it up then,
// close(fd) would be necessary if are opneing sveral times in a loop.
// https://www.man7.org/linux/man-pages/man2/pread.2.html
void *irq_thread_func(void *arg)
{
    (void)arg;

    int fd = open(USR_IRQ_EVENT_FILE, O_RDONLY | O_SYNC);
    if (fd < 0)
        return NULL;
    for (;;)
    {
        read(fd, &event_count, sizeof(event_count));
    }
    return NULL;
}