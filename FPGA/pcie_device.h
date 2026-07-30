#ifndef PCI_DEVICE_H
#define PCI_DEVICE_H

// Sysfs path to the PCIe BAR2 resource, memory-mapped for register/BRAM access.
#define PCI_RESOURCE2_PATH "/sys/bus/pci/devices/0000:01:00.0/resource2"
#define CSR_RESOURCE_FILE "/dev/xdma0_bypass"
#define USR_IRQ_EVENT_FILE "/dev/xdma0_events_0"
#define STATUS_BIT_RUNNING (1u << 0)
#define STATUS_BIT_BUFFER_FULL (1u << 1)
#define STATUS_BIT_IRQ_PENDING (1u << 2)

#define XDMA_PCIe_to_AXI_Translation_Offset 0x44A0_0000 //not needed
#define SR_OFFSET 0x04
#define CR_OFFSET 0x00
#define BRAM_OFFSET 0x2000


#endif