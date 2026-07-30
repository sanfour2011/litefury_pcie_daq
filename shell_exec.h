#ifndef SHELL_EXEC_H
#define SHELL_EXEC_H

// lunches a one-shot shell command without corrupting the ncurses screen.
void run_shell_command(const char *cmd);

#endif