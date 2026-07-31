#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>


#include "bram_data.h"
#include "pcie_device.h"

void dump_bram_data(uint32_t *bram_data)
{
    int fd = open(BRAM_RESOURCE_FILE_DMA, O_RDONLY | O_SYNC);
    if (fd < 0)
        return;
    pread(fd, bram_data, BRAM_WORDS * sizeof(uint32_t), BRAM_OFFSET_DMA);
   

    close(fd);
}