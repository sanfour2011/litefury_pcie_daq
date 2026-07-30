#include "bram_data.h"

void get_bram_data(uint32_t *bram_data)
{
    for (int i = 0; i < BRAM_WORDS; i++)
    {
        bram_data[i] = 0xA0000000u + (uint32_t)i;
    }
}