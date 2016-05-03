LEARN = 1

this:	cchop

include ../chop/Makefile

LIBCCHOP = hash.o special.o cchop.o cmd.o cvtpatt.o skels.o deback.o doxfers.o rules.o string.o allocate.o

cchop:	$(LIBCCHOP)
	$(CC) $(CFLAGS) -o cchop $(LIBCCHOP) -lm

