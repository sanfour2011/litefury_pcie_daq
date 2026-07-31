#include "bram_panel.h"
#include "../FPGA/pcie_device.h"

void draw_bram_panel(WINDOW *win, const uint32_t *bram_data, int scroll_offset)
{
    werase(win);

    int max_y, max_x;
    getmaxyx(win, max_y, max_x);

    // Rahmen
    box(win, 0, 0);

    // Titel-Zeile innen
    mvwprintw(win, 0, 2, " BRAM (Offset: Zeile %d) ", scroll_offset);

    // Platz im Fenster für Daten (innen, ohne Rahmen)
    int text_x_start = 2 + 12;          // Rahmen + "0x12345678: "
    int words_per_line = (max_x - text_x_start - 1) / 9;  // -1 für rechten Rand
    if (words_per_line < 1)
        words_per_line = 1;

    int available_lines = max_y - 2;    // 1 Titel + 1 Rahmen unten
    if (available_lines < 1)
        available_lines = 1;

    int total_lines = (BRAM_WORDS + words_per_line - 1) / words_per_line;

    // Scroll-Offset begrenzen
    if (scroll_offset < 0)
        scroll_offset = 0;
    int max_offset = total_lines - available_lines;
    if (max_offset < 0)
        max_offset = 0;
    if (scroll_offset > max_offset)
        scroll_offset = max_offset;

    int start_word_idx = scroll_offset * words_per_line;

    for (int line = 0; line < available_lines; line++)
    {
        int line_start_idx = start_word_idx + line * words_per_line;
        if (line_start_idx >= BRAM_WORDS)
            break;

        uint32_t addr = BRAM_BASE_DMA + (uint32_t)line_start_idx * 4;
        int y = 1 + line;  // Zeile 1 ist direkt unter dem Titel
        mvwprintw(win, y, 2, "0x%08X: ", addr);

        for (int w = 0; w < words_per_line; w++)
        {
            int idx = line_start_idx + w;
            if (idx >= BRAM_WORDS)
                break;

            wprintw(win, "%08X ", bram_data[idx]);
        }
    }

    wrefresh(win);
}