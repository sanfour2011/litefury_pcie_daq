#include "csr.h"

uint32_t csr_control_read(void)
{
    return 0;
}

uint32_t csr_status_read(void)
{
    return 0;
}

void csr_control_en_acq(int running)
{
}

void csr_status_clear_irq(void)
{
    uint32_t status_reg = (1 << STATUS_BIT_IRQ_PENDING);
}