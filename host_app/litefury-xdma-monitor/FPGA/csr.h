#ifndef CSR_H
#define CSR_H

#include <stdint.h>

// Reads the current STATUS register value.
// /sys/bus/pci/devices/0000:01:00.0/resource2 offset 0x4.
uint32_t csr_status_read(void);

// /sys/bus/pci/devices/0000:01:00.0/resource2 offset 0x00
uint32_t csr_control_read(void);

//enables aquistion
void csr_control_en_acq(int running);

// w1c: clears the irq_pending bit (bit 2). Same effect as
// w1c_irq_pending.sh writing 0x04 to offset 0x4.
void csr_status_clear_irq(void);

#endif