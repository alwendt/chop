tst-makefile:
	@echo 1>&2 run make from a target-specific directory

test:	tst/8q.s tst/array.s tst/cf.s tst/cq.s tst/cvt.s tst/fields.s tst/front.s \
	tst/incr.s tst/init.s tst/limits.s tst/paranoia.s tst/sort.s tst/spill.s \
	tst/stdarg.s tst/struct.s tst/switch.s tst/wf1.s tst/yacc.s

tst/8q.s:	$(RUN) rcc $(TST)/8q.c       $(TST)/8q.0;	@$(RUN) 8q	$(OS)
tst/array.s:	$(RUN) rcc $(TST)/array.c    $(TST)/array.0;	@$(RUN) array	$(OS)
tst/cf.s:	$(RUN) rcc $(TST)/cf.c       $(TST)/cf.0;	@$(RUN) cf	$(OS)
tst/cq.s:	$(RUN) rcc $(TST)/cq.c       $(TST)/cq.0;	@$(RUN) cq	$(OS)
tst/cvt.s:	$(RUN) rcc $(TST)/cvt.c      $(TST)/cvt.0;	@$(RUN) cvt	$(OS)
tst/fields.s:	$(RUN) rcc $(TST)/fields.c   $(TST)/fields.0;	@$(RUN) fields	$(OS)
tst/front.s:	$(RUN) rcc $(TST)/front.c    $(TST)/front.0;	@$(RUN) front	$(OS)
tst/incr.s:	$(RUN) rcc $(TST)/incr.c     $(TST)/incr.0;	@$(RUN) incr	$(OS)
tst/init.s:	$(RUN) rcc $(TST)/init.c     $(TST)/init.0;	@$(RUN) init	$(OS)
tst/limits.s:	$(RUN) rcc $(TST)/limits.c   $(TST)/limits.0;	@$(RUN) limits	$(OS)
tst/paranoia.s:	$(RUN) rcc $(TST)/paranoia.c $(TST)/paranoia.0;	@$(RUN) paranoia $(OS)
tst/sort.s:	$(RUN) rcc $(TST)/sort.c     $(TST)/sort.0;	@$(RUN) sort	$(OS)
tst/spill.s:	$(RUN) rcc $(TST)/spill.c    $(TST)/spill.0;	@$(RUN) spill	$(OS)
tst/stdarg.s:	$(RUN) rcc $(TST)/stdarg.c   $(TST)/stdarg.0;	@$(RUN) stdarg	$(OS)
tst/struct.s:	$(RUN) rcc $(TST)/struct.c   $(TST)/struct.0;	@$(RUN) struct	$(OS)
tst/switch.s:	$(RUN) rcc $(TST)/switch.c   $(TST)/switch.0;	@$(RUN) switch	$(OS)
tst/wf1.s:	$(RUN) rcc $(TST)/wf1.c      $(TST)/wf1.0;	@$(RUN) wf1	$(OS)
tst/yacc.s:	$(RUN) rcc $(TST)/yacc.c     $(TST)/yacc.0;	@$(RUN) yacc	$(OS)

triple:	rcc
	rm -f *.o
	make CC='lcc -B./ -d0.1 -A' CFLAGS='$(CFLAGS)' LDFLAGS='$(LDFLAGS)' rcc
	-od +8 <rcc >tst/od2
	rm -f *.o
	make CC='lcc -B./ -d0.1 -A' CFLAGS='$(CFLAGS)' LDFLAGS='$(LDFLAGS)' rcc
	-od +8 <rcc >tst/od3
	cmp tst/od[23] && rm tst/od[23]

clean:
	rm -f *.o tst/od[23] tst/*.[12so]
	-cd tst; rm -f 8q array cf cq cvt fields front incr init \
		limits paranoia sort spill stdarg struct switch wf1 yacc

clobber:	clean
		rm -f rcc
