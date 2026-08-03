CC      = gcc
CFLAGS  = -Wall -Wextra -std=gnu99 -I.
LDLIBS  = -lncurses -lpthread
TARGET  = litefury-tui

SOURCES = $(wildcard *.c FPGA/*.c ui/*.c)
OBJECTS = $(SOURCES:.c=.o)

$(TARGET): $(OBJECTS)
	$(CC) $(CFLAGS) -o $(TARGET) $(OBJECTS) $(LDLIBS)

clean:
	rm -f $(TARGET) $(OBJECTS)

.PHONY: clean