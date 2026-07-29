#include <ncurses.h>
//https://invisible-island.net/ncurses/howto/NCURSES-Programming-HOWTO.html


int main(void)
{
    initscr();// determines the terminal type and initializes the library's SCREEN, WINDOW, and other data structures
    printw("Hello World");//write formatted output to a curses window
    refresh();
    getch();
    endwin();
    return 0;
}