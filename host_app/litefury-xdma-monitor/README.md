# LiteFury XDMA Monitor

Terminal UI for controlling and monitoring a LiteFury (Artix-7) FPGA board over PCIe/XDMA. Replaces a manual setup of several hand-arranged tmux panes with a single ncurses interface.

![screenshot](docs/screenshot.png)

## Build

Needs `libncurses-dev` and `pthread`.

```bash
sudo apt install libncurses-dev
make
./litefury-tui
```

## Layout

- **Left panel** – command list / keybindings
- **PCI Info** – `lspci` output for the board
- **CTRL / STATUS** – live register view
- **BRAM** – hex dump of the onboard memory

## Keybindings

| Key | Action | What it does |
|-----|--------|---------------|
| `1` | Start Acq | Sets the "running" bit in the CTRL register |
| `2` | Stop Acq | Clears the "running" bit |
| `c` | Clear IRQ | Write-1-to-clear on the STATUS register's IRQ pending bit |
| `r` | Reset Board | Writes to the board's sysfs `reset` file |
| `l` | Load Driver | `insmod xdma.ko` |
| `u` | Unload Driver | `rmmod xdma` |
| `s` | Rescan PCI | Triggers a PCI bus rescan and checks whether the device reappears |
| `i` | PCI Info | Re-runs `lspci` for the board |
| `p` | FPGA 2 Flash | Unloads the driver and resets the board to prepare it for reflashing |
| `q` | Quit | Exits the program |

## Structure

```
main.c          entry point, ncurses setup, main loop
shell_exec.c/h  runs one-shot shell commands without corrupting the ncurses screen
FPGA/           hardware access - registers, BRAM, IRQ thread (no ncurses dependency)
ui/             drawing only - one file per panel, takes a WINDOW* and some data
```

The FPGA/ modules are a stand-in right now: register and BRAM values are simulated in software, not yet read from real hardware over mmap. The IRQ side runs on its own pthread, since a real interrupt wait is a blocking read and can't share a thread with the UI loop.

## Requirements

- `libncurses-dev`, `pthread`
- [Xilinx XDMA kernel driver](https://github.com/Xilinx/dma_ip_drivers/tree/master/XDMA/linux-kernel) (BSD-licensed) built and loaded (`xdma.ko`)
- [Xilinx Vivado](https://www.xilinx.com/support/download.html) to build and flash the FPGA firmware itself

The driver exposes character devices (`/dev/xdma0_c2h_0`, `/dev/xdma0_events_0`, ...) with non-standard semantics - a plain `pread()`/`pwrite()` on these doesn't behave like a regular file, the offset addresses FPGA memory instead. See the driver repo for details before using them directly.
