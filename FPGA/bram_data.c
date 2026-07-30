#include <fcntl.h>
#include <stdio.h>
#include "bram_data.h"
#include "pcie_device.h"

void dump_bram_data(uint32_t *bram_data)
{
    int fd = open(CSR_RESOURCE_FILE, O_RDONLY | O_SYNC);
    if (fd < 0)
        return;
     ssize_t num_read_bytes = pread(fd, bram_data, BRAM_WORDS * sizeof(uint32_t), BRAM_OFFSET);
     
    close(fd);
}