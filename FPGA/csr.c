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
    uint32_t reg_val = -1;
    int fd = open(CSR_RESOURCE_FILE, O_RDONLY | O_SYNC);
    if (fd < 0)
        return -2;
    pread(fd, &reg_val, sizeof(reg_val), CR_OFFSET);
    close(fd);
    return reg_val;
}

uint32_t csr_status_read(void)
{
    // https: // github.com/Prandr/XDMA_Tutorial/blob/main/mm_axi_bypass_test.c

    uint32_t reg_val = -1;
    int fd = open(CSR_RESOURCE_FILE, O_RDONLY | O_SYNC);
    if (fd < 0)
        return -2;
    pread(fd, &reg_val, sizeof(reg_val), SR_OFFSET);
    close(fd);
    return reg_val;

    // off_t target = SR_OFFSET;
    // off_t pgsz = sysconf(_SC_PAGESIZE);
    // off_t target_aligned = target & (~(pgsz - 1));
    // off_t offset = target & (pgsz - 1);

    // char *device = CSR_RESOURCE_FILE;

    // int fd = open(device, O_RDONLY | O_SYNC);
    // if (fd < 0)
    //     return -errno;

    // void *map = mmap(NULL, offset + 4, PROT_READ, MAP_SHARED, fd, target_aligned);
    // if (map == MAP_FAILED)
    // {
    //     int err = -errno; // close(fd) changes errno
    //     close(fd);
    //     return err;
    // }

    // char *base_address = (char *)map;
    // char *target_address = base_address + offset;
    // volatile uint32_t *ptr = (volatile uint32_t *)target_address;
    // uint32_t result = *ptr;
    // munmap(map, offset + 4);
    // close(fd);
    // return result;
}

void csr_control_en_acq(int running)
{
    int fd = open(CSR_RESOURCE_FILE, O_WRONLY | O_SYNC);
    if (fd < 0)
        return;

    uint32_t value = running != 0 ? 1 : 0;
    pwrite(fd, &value, sizeof(value), CR_OFFSET);

    close(fd);
}

void csr_status_clear_irq(void)
{
    uint32_t value = (1 << STATUS_BIT_IRQ_PENDING);

    int fd = open(CSR_RESOURCE_FILE, O_WRONLY | O_SYNC);
    if (fd < 0)
        return;
    pwrite(fd, &value, sizeof(value), SR_OFFSET);
    close(fd);
}