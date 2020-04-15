# File: Makefile
# A simple Makefile used to build an executable supporting Cross-compiling.
# Use `make` or `make all` to build natively
# Use `make CROSS_COMPILE=<cross-platform-binary>-gcc to cross-compile for different platforms.

CC = $(CROSS_COMPILE)gcc
INCLUDES = -I/
TARGET = hello-world
LDFLAGS = 
CFLAGS = -g -Wall -Werror

SRC := hello-world.c
OBJS := $(SRC:.c=.o)

all: $(TARGET)

hello-world: hello-world.c
	$(CC) $(CFLAGS) $(INCLUDES) $^ -o $@ $(LDFLAGS)

clean:
	-rm -f *.o $(TARGET) *.elf *.map *.o
