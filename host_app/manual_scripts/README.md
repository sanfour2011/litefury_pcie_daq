# manual_scripts

Small shell scripts for controlling and inspecting the LiteFury board directly from the command line - the manual precursor to `host_app/litefury-xdma-monitor`. Useful on their own for quick one-off checks or debugging without starting the full TUI.

## Requirements

- [pcimem](https://github.com/billfarrow/pcimem) - reads/writes PCI BAR memory from userspace, needed by most scripts below. Build it and make sure it's on your `PATH`.
- [Xilinx XDMA kernel driver](https://github.com/Xilinx/dma_ip_drivers/tree/master/XDMA/linux-kernel/xdma) built (`xdma.ko`) - needed for `load_xdma_driver.sh` and anything touching `/dev/xdma0_*`.

## Scripts

| Script | What it does |
|---|---|
| `pciinfo.sh` | `lspci -nnv` for the board |
| `load_xdma_driver.sh` | `insmod xdma.ko`, then confirms it's loaded |
| `reset_litefury.sh` | Resets the board via its sysfs `reset` file |
| `rescan_pci.sh` | Triggers a PCI bus rescan, shows whether the board reappears |
| `remove_litefury.sh` | Removes the PCI device (e.g. before reflashing) |
| `start_acquisition.sh` | Writes `0x1` to CTRL (offset `0x0`) - starts acquisition |
| `stop_acquisition.sh` | Writes `0x0` to CTRL (offset `0x0`) - stops acquisition |
| `w1c_irq_pending.sh` | Write-1-to-clear on STATUS (offset `0x4`) - clears the IRQ pending bit |
| `watch_status_reg.sh` | Live-polls CTRL/STATUS (offset `0x00`) every 0.2s |
| `watch_bram_end.sh` | Live-polls the tail end of BRAM (offset `0x3FDC`) every 0.2s |
| `wait_for_irq.sh` | Blocks on `/dev/xdma0_events_0` until an interrupt arrives |

All register offsets refer to `/sys/bus/pci/devices/0000:01:00.0/resource2` (BAR2).
