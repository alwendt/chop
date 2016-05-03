CC=lcc -A
CFLAGS=-DDEBUG
C=../c
INCLUDES=-I. -I$(C)

all:	rcc

OBJS=gen.o
include ../c/makefile

TST=../tst
RUN=./run
OS=bsd
include ../tst/makefile
