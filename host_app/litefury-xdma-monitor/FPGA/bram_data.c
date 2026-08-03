#include <stdint.h>
#include <fcntl.h>
#include <unistd.h>
#include <time.h>
#include <stdlib.h>

#include "bram_data.h"
#include "pcie_device.h"

void dump_bram_data(uint32_t *bram_data)
{
    int fd = open(BRAM_RESOURCE_FILE_DMA, O_RDONLY | O_SYNC);
    if (fd < 0)
        return;
    pread(fd, bram_data, BRAM_WORDS * sizeof(uint32_t), BRAM_BASE_DMA);

    close(fd);
}

double measure_bram_throughput(int iterations)
{
    int fd = open(CSR_RESOURCE_FILE_DMA, O_RDONLY);
    if (fd < 0)
        return 0;

    uint32_t *buf = malloc(BRAM_WORDS * sizeof(uint32_t));

    struct timespec start, end;
    clock_gettime(CLOCK_MONOTONIC, &start);
    for (int i = 0; i < iterations; i++)
    {
        pread(fd, buf, BRAM_WORDS * sizeof(uint32_t), BRAM_BASE_DMA);
    }
    clock_gettime(CLOCK_MONOTONIC, &end);
    close(fd);
    free(buf);

    double seconds = (end.tv_sec - start.tv_sec) + (end.tv_nsec - start.tv_nsec) / 1e9;
    double total_bytes = (double)(BRAM_WORDS * sizeof(uint32_t)) * iterations;
    double mb = total_bytes / (1024 * 1024);
    return mb / seconds;
}
