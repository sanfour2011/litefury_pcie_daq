#include <fcntl.h>
#include "irq.h"
#include <unistd.h>
#include "pcie_device.h"

volatile int irq_thread_ticks = 0;

void *irq_thread_func(void *arg){
    (void)arg;
int fd = open(CSR_RESOURCE_FILE, O_RDONLY | O_SYNC);
    if (fd < 0)
        return;
     
    close(fd);
}
    for(;;)
    {
            ssize_t num_read_bytes = pread(fd, bram_data, BRAM_WORDS * sizeof(uint32_t), BRAM_OFFSET);

        irq_thread_ticks++;
    }
    return NULL;
}