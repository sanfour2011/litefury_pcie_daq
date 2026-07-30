#include <stdlib.h>
#include <ncurses.h>
#include <stdint.h>
#include <pthread.h>
#include "reg.h"
#include "bram.h"
#include "pci_info.h"
#include "irq.h"

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
    nodelay(stdscr, TRUE);
    start_color();
    use_default_colors();

    // declaring color pairs
    init_pair(1, COLOR_GREEN, -1);
    init_pair(2, COLOR_RED, -1);

    // Titel
    box(stdscr, 0, 0);
    attron(COLOR_PAIR(1) | A_BOLD);
    mvprintw(1, 2, " LiteFury Control ");
    attroff(COLOR_PAIR(1) | A_BOLD);
    mvhline(2, 1, ACS_HLINE, COLS - 2);
    refresh();

    int left_width = 20;            // menu Witdth
    int content_top = 3;            // start row for menu
    int content_height = LINES - 4; // -4-Lines to let place for Title Box

    mvvline(content_top, left_width, ACS_VLINE, content_height);
    refresh();

    WINDOW *left = derwin(stdscr, content_height, left_width - 1, content_top, 1);

    int right_x = left_width + 1;
    int right_width = COLS - right_x - 1;

    int pci_height = 3;
    int reg_height = 5;
    int bram_height = content_height - pci_height - reg_height - 2;

    // calc horizontal seperator lines positions and content positions
    int pci_y = content_top;
    int sep1_y = pci_y + pci_height;
    int reg_y = sep1_y + 1;
    int sep2_y = reg_y + reg_height;
    int bram_y = sep2_y + 1;

    mvhline(sep1_y, right_x, ACS_HLINE, right_width);
    mvhline(sep2_y, right_x, ACS_HLINE, right_width);
    refresh();

    WINDOW *pci = derwin(stdscr, pci_height, right_width, pci_y, right_x);
    WINDOW *reg = derwin(stdscr, reg_height, right_width, reg_y, right_x);
    WINDOW *bram = derwin(stdscr, bram_height, right_width, bram_y, right_x);

    // Command menu Left side:
    mvwprintw(left, 0, 0, "1: start acq");
    mvwprintw(left, 1, 0, "2: stop acq");
    mvwprintw(left, 2, 0, "c: clear irq (w1c)");
    mvwprintw(left, 3, 0, "r: reset board");
    mvwprintw(left, 4, 0, "l: load xdma driver");
    mvwprintw(left, 5, 0, "u: unload xdma driver");
    mvwprintw(left, 6, 0, "s: rescan pci");
    mvwprintw(left, 7, 0, "i: pci info");
    mvwprintw(left, 8, 0, "p: Prepare to flash FPGA");
    mvwprintw(left, 9, 0, "q: quit");
    wrefresh(left);

    int ch;
    uint32_t bram_data[BRAM_WORDS];
    init_bram_data(bram_data);

    pthread_t irq_thread;
    pthread_create(&irq_thread, NULL, irq_thread_func, NULL);
    pthread_detach(irq_thread); // We dont need to wait for it runs, it never returns!
    while ((ch = getch()) != 'q')
    {
        uint32_t ctrl_reg = csr_control_read();
        uint32_t status_reg = csr_status_read();
        if (ch == '1')
            csr_control_set_running(1);
        if (ch == '2')
        {
            ctrl_reg &= ~0x1u;
            status_reg &= ~STATUS_BIT_RUNNING;
        }
        if (ch == 'c')
            status_reg &= ~STATUS_BIT_IRQ_PENDING;

        draw_pci_panel(pci);
        draw_bram_panel(bram, bram_data);
        draw_reg_panel(reg, ctrl_reg, status_reg);

        mvwprintw(reg, 4, 0, "irq heartbeat: %d", irq_thread_ticks);
        wrefresh(reg);
        napms(50);
    }

    endwin();
    return 0;
}