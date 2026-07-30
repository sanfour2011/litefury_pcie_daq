#include "bram_panel.h"

void init_bram_data(uint32_t *bram_data)
{
    for (int i = 0; i < BRAM_WORDS; i++)
    {
        bram_data[i] = 0xA0000000u + (uint32_t)i;
    }
}

void draw_bram_panel(WINDOW *win, const uint32_t *bram_data)
{
    werase(win);
    mvwprintw(win, 0, 0, "BRAM");

    int bram_max_y, bram_max_x;
    getmaxyx(win, bram_max_y, bram_max_x);

    int words_per_line = (bram_max_x) / 10;
    if (words_per_line < 1)
        words_per_line = 1;

    int available_lines = bram_max_y - 2;
    if (available_lines < 1)
        available_lines = 1;

    int words_to_show = words_per_line * available_lines;
    if (words_to_show > BRAM_WORDS)
        words_to_show = BRAM_WORDS;

    for (int i = 0; i < words_to_show; i++)
    {
        if (i % words_per_line == 0)
        {
            mvwprintw(win, 2 + i / words_per_line, 0, "0x%08X: ", BRAM_BASE_ADDR + (uint32_t)i * 4);
        }
        wprintw(win, "%08X ", bram_data[i]);
    }
    wrefresh(win);
}