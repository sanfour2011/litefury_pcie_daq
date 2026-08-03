#include "shell_exec.h"
#include <ncurses.h>
#include <stdlib.h>

void run_shell_command(const char *cmd)
{
    def_prog_mode();       // remember curses' terminal settings
    endwin();               // temporarily leave curses mode
    system(cmd);             // run the command with a normal terminal
    reset_prog_mode();        // restore curses' terminal settings
    clearok(curscr, TRUE);     // force a full redraw on the next refresh
}