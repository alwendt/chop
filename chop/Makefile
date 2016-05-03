MACH = vax

C=../c
COM=../chop
TESTDIR=../chop/test
DEBUG=0

#CFLAGS=-DDEBUG

all:	rcc

OBJS=gen.o $(C0OBJS)
include ../c/makefile

TST=../tst
RUN=./run
OS=bsd
include ../tst/makefile

INCLUDES=-I$(COM) -I$(C) -I../$(MACH)
TESTFILES=*.c

# Files common to cchop, chop1, and chop0
COMOBJS   = hash.o special.o
COMSRCS = $(COM)/hash.c ../$(MACH)/special.c

CHOPOBJS   = $(COMOBJS) $(COBJS) gen.o
CHOPSRCS = $(COMSRCS)

MDOBJS   = cmd.o hash.o

LD = ld

LINT = lint

#
#  Alternate host environments. Select one.
#

# VAX 4.3BSD with gprof profiler
#CFLAGS   = -pg -O -t0 -B/s/parsons/userb/fac/wendt/bin.vax/
#opt1.o:	opt1.c
#	cc $(CFLAGS) -pg -E opt1.c | /s/parsons/userb/fac/wendt/bin.vax/ccom -XP | /lib/c2 > opt1.s
#	as -J -o opt1.o opt1.s

# VAX 4.3BSD
#CFLAGS   = -O -t0 -B/s/parsons/userb/fac/wendt/bin.vax/
#opt1.o:	opt1.c
#	cc $(CFLAGS) -E opt1.c | /s/parsons/userb/fac/wendt/bin.vax/ccom | /lib/c2 > opt1.s
#	as -J -o opt1.o opt1.s

# SUN 4 with gprof profiling
#CFLAGS   = -pg -Bstatic
#LDFLAGS =  -pg
#CC = cc

# SUN 4 gcc & DEC3100 gcc
CC=gcc
LINTFLAGS   =  
CFLAGS   =  -g $(LINTFLAGS) -DMAXKIDS=6 -DMAXSYMS=6 -DLEARNING=$(LEARN) -DDEBUG=$(DEBUG) -DCHOPEMIT=1
LDFLAGS =

# DEC3100 cc
#CC=cc
#LINTFLAGS   =  
#CFLAGS   = -g $(LINTFLAGS) -DMAXKIDS=6 -DMAXSYMS=6 -DLEARNING=$(LEARN) -DDEBUG=$(DEBUG) -DCHOPEMIT=1
#LDFLAGS =

# SUN 4
#CC = cc
#LINTFLAGS   =  
#CFLAGS   = -Bstatic -g $(LINTFLAGS) -DMAXKIDS=6 -DMAXSYMS=6 -DLEARNING=$(LEARN) -DDEBUG=$(DEBUG)
#LDFLAGS =

# SUN 3
# CFLAGS   = -p -O
#	Compile the optimizer code.  The editing works around a bug in
#	the Sun compiler with switches and the -J option in the assembler.
#opt1.o:	opt1.c
#	$(CC) $(CFLAGS) -S -DDEBUG=0 opt1.c
#	echo 'g/movw	pc@(6,/s//movw	pc@(8,/gp~g/jmp	pc@(2,d0:w)/s//jmp	pc@(4,d0:w)/gp~wq' | tr '[~]' '[\012]' | ex opt0.s
#	as -J opt0.s

# HP 700
#CC = c89
#CFLAGS   = -g $(LINTFLAGS) -DMAXKIDS=6 -DMAXSYMS=6 -DLEARNING=$(LEARN) -DDEBUG=$(DEBUG) -DCHOPEMIT=1 -DCLASSIC_ANSI_TYPES=1
#LEX=flex
#LEXFLAGS=-S$(COM)/flex.skel

tags: *.y *.c ../$(MACH)/*.c
	csh -c 'ctags *.y *.c  ../$(MACH)/*.c >& /dev/null'

#asm1.o comb.o combt.o hash.o simprt.o : $(COM)/hop2.h
$(MDOBJS): $(COM)/md.h
cmd.o: $(COM)/lex.zz.c

cmd.c:	$(COM)/cmd.y $(COM)/lex.zz.c
	yacc $(COM)/cmd.y
	rm -f cmd.c
	sed <y.tab.c 's/yy/zz/g;s/YY/ZZ/g' > cmd.c
	rm y.tab.c
	chmod a-w cmd.c

#  This works around hpux lex, which puts a useless line into
#  lex.zz.c that causes gcc to complain.

$(COM)/lex.zz.c: $(COM)/cmd.lex
	$(LEX) $(LEXFLAGS) $(COM)/cmd.lex
	sed <lex.yy.c '/static void __yy__unused()/d;s/yy/zz/g' > $(COM)/lex.zz.c
	rm lex.yy.c


#
#	Compile the optimizer code.  The editing works around a bug in
#	the Sun compiler with switches and the -J option in the assembler.
#
#	echo 'g/movw	pc@(6,/s//movw	pc@(8,/gp~g/jmp	pc@(2,d0:w)/s//jmp	pc@(4,d0:w)/gp~wq' | tr '[~]' '[\012]' | ex opt0.s

runique: runique.icn
	icont runique.icn

GENFILES =  *.s *.o opt[01].[cs] cchop chop0 chop1 missing \
	optpats core  \
	asm1 md mdt *.t rsort lprof.out icode.h *.log gmon.out \
	runique tags nesting opt1.nonest opt1t.* opt0t.* \
	testsuite0 onesies\
	chop0t chop1t cmd.c parser y.output lex.yy.c cmd $(COM)/lex.zz.c \
	everything

Clean:
	/bin/rm -f $(GENFILES) ../$(MACH)/allocl.h

save:
	 mkdir ../$(MACH).save
	/bin/mv $(GENFILES) ../$(MACH).save

cvtpatt.o:	$(COM)/cvtpatt.c	; $(CC) -c $(CFLAGS) $(INCLUDES) $(COM)/cvtpatt.c
deback.o:	$(COM)/deback.c		; $(CC) -c $(CFLAGS) $(INCLUDES) $(COM)/deback.c
gen.o:	../$(MACH)/gen.c ../$(MACH)/allocl.h
	$(CC) -c $(CFLAGS) $(INCLUDES) ../$(MACH)/gen.c
hash.o:		$(COM)/hash.c		; $(CC) -c $(CFLAGS) $(INCLUDES) $(COM)/hash.c
skels.o:	$(COM)/skels.c		; $(CC) -c $(CFLAGS) $(INCLUDES) $(COM)/skels.c
special.o:	../$(MACH)/special.c	; $(CC) -c $(CFLAGS) $(INCLUDES) ../$(MACH)/special.c

# Uncomment the next line if you wish to not stop when you encounter an
# error in running chop0 on the test files.
# IGN0=-
testsuite0:  ${TESTDIR}/${TESTFILES} md
	cd ../chop0;make chop0
	${IGN0} for file in ${TESTDIR}/${TESTFILES} ;\
	do \
		file=`basename $${file} .c` ; \
		echo $${file} ; \
		rm -f optpats ; \
		../chop0/chop0 < ${TESTDIR}/$${file}.c > ../$(MACH)/$${file}.0.new ; \
		sed < optpats "s/# line \(.*\)/# file $${file} line \1/" | \
		compress > ../$(MACH)/opt.$${file}.Z ; \
		rm -f optpats ; \
	done
	touch testsuite0

md:	../$(MACH)/md
	m4 < ../$(MACH)/md > md
