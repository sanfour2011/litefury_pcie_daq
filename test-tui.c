#include <stdlib.h>
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

    mvwprintw(left, 0, 0, "Left panel");
    mvwprintw(right, 0, 0, "Right panel");

    wrefresh(left);
    wrefresh(right);

    int ch;
    while ((ch = getch()) != 'q')
    {
        if (ch == '1')
        {
            mvwprintw(right, 2, 0, "1");
            wrefresh(right);
        }
        if (ch == '2')
        {
            mvwprintw(right, 3, 0, "2");
            wrefresh(right);
        }
        if (ch == '3')
        {
            mvwprintw(right, 4, 0, "3");
            wrefresh(right);
        }
    }

    endwin();
    return 0;
}