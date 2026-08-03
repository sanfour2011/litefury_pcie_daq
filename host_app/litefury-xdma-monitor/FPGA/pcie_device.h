#ifndef PCI_DEVICE_H
#define PCI_DEVICE_H

// Sysfs path to the PCIe BAR2 resource, memory-mapped for register/BRAM access.
#define PCI_RESOURCE2_PATH "/sys/bus/pci/devices/0000:01:00.0/resource2"
// use only with mmap xdma0_bypass has no engine! pread, pwrite, ... needs an engine to run otherwise it returns (EINVAL)
#define CSR_RESOURCE_FILE "/dev/xdma0_bypass"
#define USR_IRQ_EVENT_FILE "/dev/xdma0_events_0"

// When using DMA Engines:
#define CSR_RESOURCE_FILE_DMA "/dev/xdma0_c2h_0"
#define BRAM_RESOURCE_FILE_DMA  "/dev/xdma0_c2h_0"
#define SR_BASE_DMA 0x44A00000 // Address from Vivado Address Edito
#define BRAM_BASE_DMA 0x44A02000
/////////////////////////

#define ENABLE_ACQ_BIT 0
#define STATUS_BIT_RUNNING 0
#define STATUS_BIT_BUFFER_FULL 1
#define STATUS_BIT_IRQ_PENDING 2

#define XDMA_PCIe_to_AXI_Translation_Offset 0x44A00000 
#define SR_OFFSET 0x04
#define CR_OFFSET 0x00
#define BRAM_OFFSET 0x2000

#define BRAM_WORDS 2048


#endif