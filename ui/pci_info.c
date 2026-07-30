#include "pci_info.h"
#include <stdio.h>
#include <string.h>

void draw_pci_panel(WINDOW *win)
{
    werase(win);

    FILE *fp = popen("lspci -s 01:00.0 -nnv", "r");
    if (!fp)
    {
        mvwprintw(win, 0, 0, "failed to run lspci");
        wrefresh(win);
        pclose(fp);
        return;
    }

    int max_y, max_x;
    getmaxyx(win, max_y, max_x);
    (void)max_x;

    char line[256];
    int row = 0;
    while (row < max_y && fgets(line, sizeof(line), fp) != NULL)
    {
        line[strcspn(line, "\n")] = '\0'; // Trimm
        mvwprintw(win, row, 0, "%s", line);
        row++;
    }

    pclose(fp);
    wrefresh(win);
}