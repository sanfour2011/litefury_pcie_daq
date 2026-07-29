#ifndef BRAM_H
#define BRAM_H
#include <ncurses.h>

#define BRAM_WORDS 2048
#define BRAM_BASE_ADDR 0xFE402000u



void init_bram_data(uint32_t *bram_data);

void draw_bram_panel(WINDOW *win, const uint32_t *bram_data);

#endif