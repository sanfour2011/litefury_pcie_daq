#include "pci_info.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "../shell_exec.h"

void draw_pci_panel(WINDOW *win)
{
    werase(win);

    FILE *fp = popen("lspci -s 01:00.0 -nnv", "r");
    if (!fp)
    {
        mvwprintw(win, 0, 0, "failed to run lspci");
        wrefresh(win);
        return;
    }
   
    char line[256];
    if (fgets(line, sizeof(line), fp) != NULL)
    {
        line[strcspn(line, "\n")] = '\0';
        mvwprintw(win, 0, 0, "%s", line);
    }

    pclose(fp);
    wrefresh(win);
}

bool pci_rescan_and_check()
{
    run_shell_command("echo 1 | sudo tee /sys/bus/pci/rescan > /dev/null");

    FILE *fp = popen("lspci -s 0000:01:00.0 -nnv", "r");
    if (!fp)
        return false;

    char buf[512] = {0};
    fread(buf, 1, sizeof(buf) - 1, fp);
    pclose(fp);

    return strstr(buf, "01:00.0") != NULL && strstr(buf, "7-Series FPGA Hard PCIe") != NULL;
}