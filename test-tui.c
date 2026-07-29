#include <stdlib.h>
#include <string.h>
#include <ncurses.h>
// https://invisible-island.net/ncurses/howto/NCURSES-Programming-HOWTO.html

int main(void)
{
    initscr();

    if (has_colors() == FALSE)
    {
        endwin();
        printf(" Terminal does not support color\n");
        exit(1);
    }

    noecho();
    curs_set(0);
    start_color();
    use_default_colors();
    init_pair(1, COLOR_GREEN, -1);

    box(stdscr, 0, 0);
    attron(COLOR_PAIR(1) | A_BOLD);
    mvprintw(1, 2, " Dummy Window ");
    attroff(COLOR_PAIR(1) | A_BOLD);
    mvhline(2, 1, ACS_HLINE, COLS - 2);
    refresh();

    int left_width = 20;
    mvvline(3, left_width, ACS_VLINE, LINES - 4);
    refresh();

    WINDOW *left = derwin(stdscr, LINES - 4, left_width - 1, 3, 1);
    WINDOW *right = derwin(stdscr, LINES - 4, COLS - left_width - 2, 3, left_width + 1);

    mvwprintw(left, 0, 0, "1: start acq");
    mvwprintw(left, 1, 0, "2: stop acq");
    mvwprintw(left, 2, 0, "r: reset board");
    mvwprintw(left, 3, 0, "l: load xdma driver");
    mvwprintw(left, 4, 0, "s: rescan pci");
    mvwprintw(left, 6, 0, "q: quit");
    wrefresh(left);

    char is_running = 0;              // 0 = stopped, 1 = running
    char last_action[64] = "";       // text describing the last one-shot action

    int ch;
    while ((ch = getch()) != 'q')
    {
        if (ch == '1') is_running = 1;
        if (ch == '2') is_running = 0;

        if (ch == 'r') strcpy(last_action, "Reset");
        if (ch == 'l') strcpy(last_action, "xdma driver loaded");
        if (ch == 's') strcpy(last_action, "PCI rescan");

        werase(right);
        if (is_running)
            mvwprintw(right, 0, 0, "Status: RUNNING");
        else
            mvwprintw(right, 0, 0, "Status: STOPPED");

        mvwprintw(right, 2, 0, "Last action: %s", last_action);
        wrefresh(right);
    }

    endwin();
    return 0;
}