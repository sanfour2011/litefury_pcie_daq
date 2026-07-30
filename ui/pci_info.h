#ifndef PCI_INFO_H
#define PCI_INFO_H
#include <ncurses.h>

void draw_pci_panel(WINDOW *win);

//returns true if the FPGA device (01:00.0) is present
bool pci_rescan_and_check();
#endif
