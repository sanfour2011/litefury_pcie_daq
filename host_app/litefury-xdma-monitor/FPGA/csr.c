#include <errno.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <byteswap.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/mman.h>

#include "csr.h"
#include "pcie_device.h"

uint32_t csr_control_read(void)
{
    // SR_OFFSET is already page-aligned (0x0), so no alignment math needed here

    int fd = open(CSR_RESOURCE_FILE, O_RDONLY | O_SYNC);
    if (fd < 0)
        return 0xFFFFFFFF;

    // read 8 bytes Status reg sits on second word
    volatile uint32_t *map = mmap(NULL, 8, PROT_READ, MAP_SHARED, fd, 0);

    close(fd);

    if (map == MAP_FAILED)
        return 0xFFFFFFFF;

    uint32_t status_reg = map[0];
    munmap((void *)map, 8);
    return status_reg;
}

uint32_t csr_status_read(void)
{
    // SR_OFFSET is already page-aligned (0x0), so no alignment math needed here

    int fd = open(CSR_RESOURCE_FILE, O_RDONLY | O_SYNC);
    if (fd < 0)
        return 0xFFFFFFFF;

    // read 8 bytes Status reg sits on second word
    volatile uint32_t *map = mmap(NULL, 8, PROT_READ, MAP_SHARED, fd, 0);

    close(fd);

    if (map == MAP_FAILED)
        return 0xFFFFFFFF;

    uint32_t status_reg = map[1];
    munmap((void *)map, 8);
    return status_reg;
}

void csr_control_en_acq(int running)
{
    int fd = open(CSR_RESOURCE_FILE, O_RDWR | O_SYNC);
    if (fd < 0)
        return;

    volatile uint32_t *map = mmap(NULL, 8, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);

    close(fd);
    if (map == MAP_FAILED)
        return;
        
    if (running)
        map[0] |= (1U << ENABLE_ACQ_BIT);
    else
        map[0] &= ~(1U << ENABLE_ACQ_BIT);

    munmap((void *)map, 8);
}

void csr_status_clear_irq(void)
{
    int fd = open(CSR_RESOURCE_FILE, O_RDWR | O_SYNC);
    if (fd < 0)
        return;

    volatile uint32_t *map = mmap(NULL, 8, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    close(fd);
    map[1] |= (1U << STATUS_BIT_IRQ_PENDING);

    munmap((void *)map, 8);
}