#include "pci_info.h"

void draw_pci_panel(WINDOW *win)
{
    mvwprintw(win, 0, 0, "01:00.0 Xilinx 7-Series FPGA [10ee:7011]");
    mvwprintw(win, 1, 0, "BAR0 0xd0000000 (128K)  BAR2 0xd0020000 (64K)");
    wrefresh(win);
}