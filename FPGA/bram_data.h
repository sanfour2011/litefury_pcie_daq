#ifndef BRAM_DATA_H
#define BRAM_DATA_H

#include <stdint.h>

#define BRAM_WORDS 2048
#define BRAM_BASE_ADDR 0xFE402000u

void get_bram_data(uint32_t *bram_data);

#endif