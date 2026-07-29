#ifndef REG_H
#define REG_H

#include <ncurses.h>
#include <stdint.h>

#define STATUS_BIT_RUNNING (1u << 0)
#define STATUS_BIT_BUFFER_FULL (1u << 1)
#define STATUS_BIT_IRQ_PENDING (1u << 2)

void draw_reg_panel(WINDOW *win, uint32_t ctr_reg, uint32_t status_reg);

#endif