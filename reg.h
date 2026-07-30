#ifndef REG_H
#define REG_H

#include <ncurses.h>
#include <stdint.h>
#include "csr.h"



void draw_reg_panel(WINDOW *win, uint32_t ctr_reg, uint32_t status_reg);

#endif