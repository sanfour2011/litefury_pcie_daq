#include "reg.h"


void draw_reg_panel(WINDOW *win, uint32_t ctrl_reg, uint32_t status_reg){
    
    int running_bit     = (status_reg & STATUS_BIT_RUNNING) != 0;
    int buffer_full_bit = (status_reg & STATUS_BIT_BUFFER_FULL) != 0;
    int irq_pending_bit = (status_reg & STATUS_BIT_IRQ_PENDING) != 0;

    werase(win);
        mvwprintw(win, 0, 0, "CTRL / STATUS");
        mvwprintw(win, 0, 30, "CTRL  : 0x%08X", ctrl_reg);
        mvwprintw(win, 1, 30, "STATUS: 0x%08X", status_reg);
        
        mvwprintw(win, 1, 0, "is_running   : ");
        wattron(win, COLOR_PAIR(running_bit ? 1 : 2));
        wprintw(win, "%d", running_bit);
        wattroff(win, COLOR_PAIR(running_bit ? 1 : 2));

        mvwprintw(win, 2, 0, "buffer_full  : %d", buffer_full_bit);

        mvwprintw(win, 3, 0, "irq_pending  : ");
        if (irq_pending_bit)
        {
            wattron(win, COLOR_PAIR(2));
            wprintw(win, "PENDING");
            wattroff(win, COLOR_PAIR(2));
        }
        else
            wprintw(win, "0");
        wrefresh(win);

}