#ifndef BRAM_H
#define BRAM_H
#include <ncurses.h>

void init_bram_data(uint32_t *bram_data);

void draw_bram_panel(WINDOW *win, const uint32_t *bram_data, int scroll_offset);

#endif