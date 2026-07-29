#include <stdlib.h>
#include <ncurses.h>
// https://invisible-island.net/ncurses/howto/NCURSES-Programming-HOWTO.html

int main(void)
{
    initscr(); // determines the terminal type and initializes the library's SCREEN, WINDOW, and other data structures

    if (has_colors() == FALSE)
    {
        endwin();
        printf(" Terminal does not support color\n");
        exit(1);
    }
    start_color();
    use_default_colors();
    init_pair(1, COLOR_GREEN, -1); // pair 1 = green on default background
    box(stdscr, 0, 0);
    attron(COLOR_PAIR(1) | A_BOLD);
    mvprintw(1, 2, " Dummy Window ");
    attroff(COLOR_PAIR(1) | A_BOLD);

    refresh();
    getch();
    endwin();
    return 0;
}