this:	chop0

LEARN=1
MACH = vax

include ../chop/Makefile

C0OBJS = hash.o special.o $(COBJS) gen.o deback.o cmd.o cvtpatt.o skels.o simprt.o choose.o
C0SRCS = $(COM)/hash.c ../$(MACH)/special.c deback.c cmd.c cvtpatt.c skels.c simprt.c choose.c

chop0t:	$(C0OBJS) opt0t.o combt.o
	$(CC) $(CFLAGS) -o chop0t $(C0OBJS) combt.o opt0t.o -lm

opt0t.o: opt0.c
	$(CC) $(CFLAGS) $(INCLUDES) -DDEBUG=1 -c -o opt0t.o opt0.c

opt0.o:	opt0.c
	$(CC) $(CFLAGS) $(INCLUDES) -DDEBUG=0 -c -o opt0.o opt0.c

../$(MACH)/allocl.h:	opt0.c

opt0.c:	../chop/parf md $(COM)/hash.c $(COM)/cvtpatt.c 
	cd ../cchop;make cchop
	../cchop/cchop -f../chop/parf -m$(MACH) -l > opt0.c
	mv $(COM)/allocl.h ../$(MACH)

combt.o: comb.c
	$(CC) $(CFLAGS) $(INCLUDES) -DDEBUG=1 -c -o combt.o comb.c

chop0:	$(C0OBJS) opt0.o comb.o
	$(CC) -o chop0 $(C0OBJS) comb.o opt0.o $(LDFLAGS) -lm

chop0.Counts: chop0.pixie
	chop0.pixie < test/modulo.c >chop0.pixie.out

chop0.pixie: chop0
	pixie -o chop0.pixie chop0

chop0t.Counts: chop0t.pixie
	chop0t.pixie < test/modulo.c >chop0t.pixie.out

chop0t.pixie: chop0t
	pixie -o chop0t.pixie chop0t

asm1:	asm1.o deback.o cmd.o allocate.o string.o special.o cvtpatt.o hash.o $(COM)/md.h
	$(CC) $(CFLAGS) -o asm1 asm1.o deback.o cmd.o allocate.o string.o special.o cvtpatt.o hash.o -lm
