#
#       Chop1
#


LEARN=0

include ../chop/Makefile

CHOP1OBJS = hash.o special.o $(COBJS) gen.o deback.o cvtpatt.o skels.o
CHOP1SRCS = $(COM)/hash.c ../$(MACH)/special.c ../$(MACH)/gen.o deback.c cmd.c cvtpatt.c skels.c 

C0OBJS = hash.o special.o $(COBJS) gen.o deback.o cmd.o cvtpatt.o skels.o simprt.o choose.o
C0SRCS = $(COM)/hash.c ../$(MACH)/special.c deback.c cmd.c cvtpatt.c skels.c simprt.c choose.c

chop1:	opt1.o $(CHOP1OBJS)
	$(CC) $(CFLAGS) -o chop1 opt1.o $(CHOP1OBJS)

opt1.o: opt1.c
	$(CC) $(CFLAGS) $(INCLUDES) -c -DDEBUG=0 -o opt1.o opt1.c

opt1.c:	opt1.nonest
	iconx nesting < opt1.nonest > opt1.c

opt1.nonest: ../$(MACH)/opts.good ../chop/parf md nesting ../cchop/cchop md
	../cchop/cchop -f../chop/parf -m$(MACH) ../$(MACH)/opts.good > opt1.nonest
	mv $(COM)/allocl.h ../$(MACH)
#	rcp cchop ../$(MACH)/opts.good ../chop/parf md mozart:
#	rsh mozart cchop -m$(MACH) opts.good \> opt1.nonest
#	rcp mozart:opt1.nonest opt1.nonest

opt1.flat: ../$(MACH)/opts.good ../chop/parf md nesting ../cchop/cchop md
	../cchop/cchop -j -f../chop/parf -m$(MACH) ../$(MACH)/opts.good > opt1.flat
	mv $(COM)/allocl.h ../$(MACH)

../$(MACH)/allocl.h:	opt1.c


chop1t:	opt1t.o $(CHOP1OBJS)
	$(CC) $(CFLAGS) -o chop1t $(CHOP1OBJS) opt1t.o -lc

opt1t.o: opt1.c
	$(CC) $(CFLAGS) $(INCLUDES) -O1 -c -DDEBUG=1 -o opt1t.o opt1.c

nesting: nesting.icn
	icont nesting.icn

rsort:	rsort.icn
	icont rsort.icn


# Uncomment the next line if you wish to not stop when you encounter an
# error in running chop1 on the test files.
# IGN1=-
testsuite1: ${TESTDIR}/${TESTFILES} chop1
	${IGN1} for file in ${TESTDIR}/${TESTFILES} ;\
	do \
		file=`basename $${file} .c` ; \
		echo $${file} ; \
		chop1 < ${TESTDIR}/$${file}.c > ../$(MACH)/$${file}.1.new ; \
	done
	touch testsuite1

../$(MACH)/opts.good : ../chop0/testsuite0 onesies rsort
	zcat ../$(MACH)/opt.*.Z | iconx rsort > ../$(MACH)/opts.good

../cchop/cchop:
	cd ../cchop;make cchop

../chop0/chop0:
	cd ../chop0;make chop0

onesies: ../chop0/chop0 md
	rm -f optpats
	echo ";" | ../chop0/chop0 -onesies
	sed < optpats "s/# line \(.*\)/# file onesies line \1/" > \
	    ../$(MACH)/opt.onesies
	compress ../$(MACH)/opt.onesies
	touch onesies

