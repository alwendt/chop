SHELL=/bin/sh

COBJS=allocate.o dag.o decl.o enode.o error.o expr.o init.o input.o lex.o main.o \
	output.o profio.o simp.o stmt.o string.o sym.o tree.o types.o

c-makefile:
	@echo 1>&2 run make from a target-specific directory

rcc:		$(COBJS) $(OBJS)
		$(CC) $(LDFLAGS) -o rcc $(COBJS) $(OBJS)

.c.o: ;	$(CC) -c $(CFLAGS) $(INCLUDES) $<

$(COBJS):	$(C)/c.h $(C)/token.h $(C)/ops.h ../$(MACH)/config.h
$(OBJS):	$(C)/c.h $(C)/token.h $(C)/ops.h ../$(MACH)/config.h

lex.o:		$(C)/keywords.h

allocate.o:	$(C)/allocate.c;$(CC) -c $(CFLAGS) $(INCLUDES) $(C)/allocate.c
dag.o:		$(C)/dag.c;	$(CC) -c $(CFLAGS) $(INCLUDES) $(C)/dag.c
decl.o:		$(C)/decl.c;	$(CC) -c $(CFLAGS) $(INCLUDES) $(C)/decl.c
enode.o:	$(C)/enode.c;	$(CC) -c $(CFLAGS) $(INCLUDES) $(C)/enode.c
error.o:	$(C)/error.c;	$(CC) -c $(CFLAGS) $(INCLUDES) $(C)/error.c
expr.o:		$(C)/expr.c;	$(CC) -c $(CFLAGS) $(INCLUDES) $(C)/expr.c
init.o:		$(C)/init.c;	$(CC) -c $(CFLAGS) $(INCLUDES) $(C)/init.c
input.o:	$(C)/input.c;	$(CC) -c $(CFLAGS) $(INCLUDES) $(C)/input.c
lex.o:		$(C)/lex.c;	$(CC) -c $(CFLAGS) $(INCLUDES) $(C)/lex.c
main.o:		$(C)/main.c;	$(CC) -c $(CFLAGS) $(INCLUDES) $(C)/main.c
output.o:	$(C)/output.c;	$(CC) -c $(CFLAGS) $(INCLUDES) $(C)/output.c
profio.o:	$(C)/profio.c;	$(CC) -c $(CFLAGS) $(INCLUDES) $(C)/profio.c
simp.o:		$(C)/simp.c;	$(CC) -c $(CFLAGS) $(INCLUDES) $(C)/simp.c
stmt.o:		$(C)/stmt.c;	$(CC) -c $(CFLAGS) $(INCLUDES) $(C)/stmt.c
string.o:	$(C)/string.c;	$(CC) -c $(CFLAGS) $(INCLUDES) $(C)/string.c
sym.o:		$(C)/sym.c;	$(CC) -c $(CFLAGS) $(INCLUDES) $(C)/sym.c
tree.o:		$(C)/tree.c;	$(CC) -c $(CFLAGS) $(INCLUDES) $(C)/tree.c
types.o:	$(C)/types.c;	$(CC) -c $(CFLAGS) $(INCLUDES) $(C)/types.c
