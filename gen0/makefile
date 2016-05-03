CFLAGS=-g -DDEBUG
LDFLAGS=-g
C=../c
INCLUDES=-I. -I$(C)

all:	rcc

OBJS=gen.o
include ../c/makefile

TST=../tst
RUN=./run
OS=
include ../tst/makefile
