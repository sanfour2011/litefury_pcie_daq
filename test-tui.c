#include <stdlib.h>
#include <ncurses.h>
#include <stdint.h>
// https://invisible-island.net/ncurses/howto/NCURSES-Programming-HOWTO.html

#define BRAM_WORDS 2048
#define BRAM_BASE_ADDR 0xFE402000u

int main(void)
{
    uint32_t bram_data[BRAM_WORDS];
    for (int i = 0; i < BRAM_WORDS; i++)
    {
        bram_data[i] = 0xA0000000u + (uint32_t)i;
    }
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
    init_pair(1, COLOR_GREEN, -1);
    init_pair(2, COLOR_RED, -1);

    box(stdscr, 0, 0);
    attron(COLOR_PAIR(1) | A_BOLD);
    mvprintw(1, 2, " LiteFury Control ");
    attroff(COLOR_PAIR(1) | A_BOLD);
    mvhline(2, 1, ACS_HLINE, COLS - 2);
    refresh();

    int left_width = 20;
    int content_top = 3;
    int content_height = LINES - 4;

    mvvline(content_top, left_width, ACS_VLINE, content_height);
    refresh();

    WINDOW *left = derwin(stdscr, content_height, left_width - 1, content_top, 1);

    int right_x = left_width + 1;
    int right_width = COLS - right_x - 1;

    int pci_height = 3;
    int reg_height = 5;
    int bram_height = content_height - pci_height - reg_height - 2;

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

    mvwprintw(left, 0, 0, "1: start acq");
    mvwprintw(left, 1, 0, "2: stop acq");
    mvwprintw(left, 2, 0, "c: clear irq (w1c)");
    mvwprintw(left, 3, 0, "r: reset board");
    mvwprintw(left, 4, 0, "l: load xdma driver");
    mvwprintw(left, 5, 0, "u: unload xdma driver");
    mvwprintw(left, 6, 0, "s: rescan pci");
    mvwprintw(left, 7, 0, "p: pci info");
    mvwprintw(left, 8, 0, "q: quit");
    wrefresh(left);

    mvwprintw(pci, 0, 0, "PCI Info (press 'p')");
    wrefresh(pci);

    mvwprintw(bram, 0, 0, "BRAM");
    wrefresh(bram);

    int is_running = 0;  // STATUS bit 0
    int buffer_full = 0; // STATUS bit 1
    int irq_pending = 0; // STATUS bit 2
    int tick = 0;

    int ch;
    while ((ch = getch()) != 'q')
    {
        if (ch == '1')
            is_running = 1;
        if (ch == '2')
            is_running = 0;
        if (ch == 'c')
            irq_pending = 0;

        // Bram Section:
        werase(bram);
        mvwprintw(bram, 0, 0, "BRAM");

        int bram_max_y, bram_max_x;
        getmaxyx(bram, bram_max_y, bram_max_x);

        int words_per_line = (bram_max_x) / 10;
        if (words_per_line < 1)
            words_per_line = 1;

        int available_lines = bram_max_y - 2; // line 0 = title, line 1 = blank
        if (available_lines < 1)
            available_lines = 1;

        int words_to_show = words_per_line * available_lines;
        if (words_to_show > BRAM_WORDS)
            words_to_show = BRAM_WORDS;

        for (int i = 0; i < words_to_show; i++)
        {
            if (i % words_per_line == 0)
            {
                mvwprintw(bram, 2 + i / words_per_line, 0, "0x%08X: ", BRAM_BASE_ADDR + (uint32_t)i * 4);
            }
            wprintw(bram, "%08X ", bram_data[i]);
        }
        wrefresh(bram);
        // end bram section
        if (is_running)
        {
            tick++;
            if (tick > 60)
            {
                irq_pending = 1;
                buffer_full = 1;
                tick = 0;
            }
        }

        werase(reg);
        mvwprintw(reg, 0, 0, "CTRL / STATUS");
        mvwprintw(reg, 1, 0, "is_running   : ");
        wattron(reg, COLOR_PAIR(is_running ? 1 : 2));
        wprintw(reg, "%d", is_running);
        wattroff(reg, COLOR_PAIR(is_running ? 1 : 2));

        mvwprintw(reg, 2, 0, "buffer_full  : %d", buffer_full);

        mvwprintw(reg, 3, 0, "irq_pending  : ");
        if (irq_pending)
        {
            wattron(reg, COLOR_PAIR(2));
            wprintw(reg, "PENDING");
            wattroff(reg, COLOR_PAIR(2));
        }
        else
            wprintw(reg, "0");
        wrefresh(reg);

        napms(50);
    }

    endwin();
    return 0;
}