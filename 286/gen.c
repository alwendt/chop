/* C compiler: mips subset code generator */

#include "c.h"
#include <stdio.h>
#include "hop2.h"

#include "allocl.h"
#include "bits.h"

#ifdef DEBUG
#define debug(x,y) if (x) y
static void lprint(Node, char *);
static void nprint(Node);
static int id;
static Node lhead;

#else
#define debug(x,y)
#endif

Symbol global_cached_sym;	/* if a "global" command has been emitted without an accompanying
				 * "space" command, this cell holds the symbol.  The mips needs both
					 * in order to generate a ".comm name,size".
				 */

#define OUTPUT_GLOBAL() if (global_cached_sym) { print("%s:", global_cached_sym->x.name); global_cached_sym = 0; }

void defaddress(Symbol p)
    {
    OUTPUT_GLOBAL();
    print(".long %s\n", (p)->x.name);
    }

void space(int x)
    {
    OUTPUT_GLOBAL();
    print(".space %d\n", (x));
    }


/*  The Mips has 25 integer registers $2 to $25 and $30 for general use.
 *  $0 is a constant 0.
 *  $1 is reserved for use by the assembler.
 *  $26 and $27 are used by the OS kernel.
 *  $28 is the "global pointer"
 *  $29 is the stack pointer.
 *  $31 is the return address.
 *  
 *  $4 - $7 hold the first 4 parameters to function calls.
 *  These values are not preserved by the callee.
 *
 *  $8 - $15 are temporary values, not preserved by the callee.
 *  $16 - $23 are preserved by the callee.
 *  $24 - $25 are not preserved by the callee.
 *
 *  It has 16 floating registers $f0-$f30 (even numbers only).
 *  Each register can hold a single or double precision value.
 *  $f0 and $f2 hold function results ($f2 used for complex results).
 *  $f4 - $f10 are not preserved by the callee.
 *  $f12 - $f14 hold first two floating args.  Not preserved by callee.
 *  $f16 - $f18 not preserved by callee.
 *  $f20 - $f30 preserved by callee.
 *
 *  There is no explicit frame pointer, instead the assembly language
 *  programmer can supply a .frame directive which establishes the fp
 *  at a constant offset from the sp:  .frame framereg,framesize,returnreg
 *  This means that the sp cannot change inside of a procedure, which
 *  implies that an argument build area must be used.
 *
 *  Currently each procedure stores all parameters into the frame immediately.
 *  Currently only 25 integer registes and 7 floating point registers
 *  are available (for a total of 32).
 *
 *  In addition, there are "$lo" and "$hi" integer registers that hold the
 *  results of 64-bit multiplies.
 *
 *  In addition there is a floating point condition code.
 * 
 *  Per Michal Meissner (who did the gcc port) load-address pseudo-instructions
 *  are never broken into their actual components and scheduled separately.
 */


static int rflag;		/* nonzero to trace register allocation */
static int framesize;		/* size of activation record */
static int offset;		/* current frame offset */
static int argbuildsize;	/* size of argument build area */
static int argoffset;		/* offset from top of stack for next argument */

/*  This allocator treats stack temps AND registers uniformly.  It has a maximum
 *  of 32 such resources.  It does not have a concept of "spilling", instead it
 *  repositions operands to free up their registers. It can reposition them into
 *  another register or a stack location.  Instead of reloads, it uses the new
 *  location if possible.  If not possible, it repositions the operand into a
 *  legal location.
 */

#define ALIGNBITS       2		/* allocations >1 must align to this */

#define RESULTNAME(p) regnames[regpatts[regtype(p)].width - 1][(p)->x.reg]

/*  the register holding this subtree. */
#define holder(ip) \
    ((ip && contents[ip->x.reg] == ip) ? \
	ip->x.reg : \
	(printf("file %s line %d::", \
	__FILE__,__LINE__), \
	cerror("holder woops ip %x contents[%d] = %x", \
		     ip, ip->x.reg, contents[ip->x.reg])))


Node contents[REGBITS];		/* current register contents */

#define RREG(x)	(1 << (x))
#define	FREG(x) (0x100 << (x))

#define TREGS 0xfffe0000

static int nregs = 5;		/* number of actual registers for which save
				 * area is allocated on the stack.
				 */


/*  registers in the RegSet
"$2",  "$3",  "$4",  "$5",  "$6",  "$7",  "$8", "$9",
"$10", "$11", "$12", "$13", "$14", "$15", "$16", "$17",
"$18", "$19", "$20", "$21", "$22", "$23", "$24", "$25",
"$30", "$f0", "$f2", "$f4", "$f6", "$f8", "$f10", "$f12"
*/

/*  Move the RegSet bit positions into the positions that the
 *  Mips architecture wants.  The RegSet has $30 in bit position
 *  24, for example, so it must be shifted left 6 positions.
 */

#define savemask(x) OR(((AND(x, 0xffffff)) << 2), (AND(x, 0x01000000) << 6))

static RegSet freebies;	/* TESTBIT(freebies, r) = 1 if register r is free */
static RegSet usedmask;	/* TESTBIT(usedmask, r) == 1 if register r was used */

int getreg(RegSet, int, Node);	/* legal mask, width, pointer */
void putreg(int, RegSet, int);

#if LEARNING
static dumpregs() {
    int i;
    for (i = 0; i < REGBITS; i++) {
	if (contents[i] != NULL || !TESTBIT(freebies, i))
	    printf("reg %d: %s %x\n", i, regnames[i], contents[i]);
	}
    printf("\n");
    }

static void checkregs() {
    int i;
    for (i = 0; i < REGBITS; i++) {
	if (TESTBIT(freebies, i) && contents[i] != NULL) {
	    printf("reg %s free with %x contents", regnames[0][i], contents[i]);
	    dumpregs();
	    cerror("reg %s free with %x contents", regnames[0][i], contents[i]);
	    }
	if (!TESTBIT(freebies, i) && contents[i] == NULL) {
	    printf("reg %s busy with NULL contents", regnames[0][i]);
	    dumpregs();
	    cerror("reg %s busy with NULL contents", regnames[0][i]);
	    }
	}
    }
#else
#define checkregs() 
#endif

static void fixoffsets(Node);
static int needsreg(Node);
static void save(RegSet);
static void restore(RegSet);
static RegSet uses(Node);
static int valid(int);

#define typecode(p) (asmoptype(p->op) == U ? I : asmoptype(p->op) == B ? P : asmoptype(p->op))

/* address - initialize q for addressing expression p+n */
void address(Symbol q, Symbol p, int n) {
	if (p->scope == GLOBAL || p->class == STATIC || p->class == EXTERN)
		q->x.name = stringf("%s%s%d", p->x.name, n >= 0 ? "+" : "", n);
	else {
		q->x.offset = p->x.offset + n;
		q->x.name = stringd(q->x.offset);
		/*
		q->x.name = stringf("%d(%s)", q->x.offset,
			p->scope == PARAM ? "ap" : "fp");
		*/
	}
}

/* asmcode - emit assembly language specified by asm */
void asmcode(char *str, Symbol argv[]) {
	OUTPUT_GLOBAL();
	for ( ; *str; str++)
		if (*str == '%' && str[1] >= 0 && str[1] <= 9)
			print("%s", argv[*++str]->x.name);
		else
			print("%c", *str);
	print("\n");
}

/* blockbeg - begin a compound statement */
void blockbeg(Env *e) {
	assert(freebies == ~0);		/* all temporary resource are free */
	e->rmask = ~freebies;
	e->offset = offset;
}

/* blockend - end a compound statement */
void blockend(Env *e) {
	if (offset > framesize)
		framesize = offset;
	offset = e->offset;
	freebies = ~e->rmask;
}

/* defconst - define a constant */
void defconst(int ty, Value v) {
	OUTPUT_GLOBAL();
	switch (ty) {
	case C: print(".byte %d\n",   v.uc); break;
	case S: print(".word %d\n",   v.us); break;
	case I: print(".long %d\n",   v.i ); break;
	case U: print(".long 0x%x\n", v.u ); break;
	case P: print(".long 0x%x\n", v.p ); break;
#ifdef vax
	case F:
		print(".long 0x%x\n", ((unsigned *) &v.f)[0]);
		break;
	case D: 
		print(".long 0x%x,0x%x\n", ((unsigned *) &v.d)[0],
			((unsigned *) &v.d)[1]);
		break;
#else
	case F: {
		char buf[MAXLINE];
		sprintf(buf, ".float 0f%.8e\n", v.f);
		outs(buf);
		break;
		}
	case D: {
		char buf[MAXLINE];
		sprintf(buf, ".double 0d%.18e\n", v.d);
		outs(buf);
		break;
		}
#endif
	default: assert(0);
	}
}

/* defstring - emit a string constant */
void defstring(int len, char *s) {
	OUTPUT_GLOBAL();
	while (len-- > 0)
		print(".byte %d\n", *s++);
}

/* defsymbol - initialize p's Xsymbol fields */
void defsymbol(Symbol p) {
	if (p->scope == CONSTANTS)
		p->x.name = p->name;
	else if (p->generated)
		p->x.name = stringf("L%s", p->name);
	else
		p->x.name = stringf("_%s", p->name);
}


/* function - generate code for a function */

/*  enter [ reglist ],localsz seems to do the following:
 *  1.  push fp onto stack
 *  2.  fp = sp
 *  3.  sp += localsz
 *  4.  push regs in reglist
 *  If there are no reglist regs and no fregs that must be saved,
 *  the localsz and the argument build area can both be allocated
 *  by the enter instruction and no adjsbp's are needed.
 */

void function(Symbol f, Symbol caller[],
	Symbol callee[], int ncalls) {
	int	i;
	int	anysaved;
	RegSet floatsaved;	/* set of fregs that get saved */
	int	funclabel;
	int	tempsused;

	OUTPUT_GLOBAL();

	/*  Generate names for the parameters to this function.
	 *  Mark all callee parameters AUTO (as opposed to REGISTER)
	 *  so that they will get stored into the frame.
	 */
	offset = 8;		/* offset of leftmost parameter */
	for (i = 0; caller[i] && callee[i]; i++) {
		offset = roundup(offset, caller[i]->type->align);
		callee[i]->x.offset = caller[i]->x.offset = offset;
		callee[i]->x.name = caller[i]->x.name = stringd(offset);
		offset += caller[i]->type->size;
		callee[i]->class = AUTO;
	}
	usedmask = argbuildsize = framesize = offset = 0;
	gencode(caller, callee);

	print(".ent %s\n", f->x.name);
	print("%s:\n", f->x.name);
	print("subu $sp,%d\n", framesize);
	print(".frame $sp,%d,$31\n");

	/*  $16-$23, $30 must be saved if they are used.
	 *  $31 is the return address, it is always saved.
	 */
	print(".mask 0x%x,%d\n",
	    OR(0x80000000, AND(savemask(usedmask), 0xc0ff0000)), 0);

	emitcode();

	print("lw $31, %d($sp)\n", framesize - 4);
	print("addu $sp,%d\n", framesize);
	print("j $31\n");

#if 0
	/*  Remove the argument build area from the stack */
	if (!floatsaved && !anysaved) {
	    print("exit []\nret 0\n");
	    }
	else {
	    if (argbuildsize)
		print("adjspb -%d\n", argbuildsize);

	    /* Pop f4-f7 off the stack in the reversed order of pushing */
	    for (i = 12; i < 16; i++)
		if (TESTBIT(floatsaved, i))
		    print("movl tos,f%d\n", i - 8);

	    /*	Restore r3 - r7 (if needed) with the exit instruction	*/
	    print("exit [");
	    for (i = 0, anysaved = 0; i < 8; i++)
		if (usedmask & ~(RREG(0) | RREG(1) | RREG(2)) & BIT(i))) {
		    print(anysaved++ ? ",r%d" : "r%d", i);
		    }
	    print("]\nret 0\n");
	    }
#endif

	/*
	if (glevel > 1) {
	    print("ret\n");
	    }
	*/
	/* Generate code to save r3 - r7 with the enter instruction */
	tempsused = bitcount(AND(usedmask, TREGS));
	print("# usedmask O%o argbuildsize %d framesize %d temps %d\n",
		usedmask, argbuildsize, framesize, tempsused);

	print("L%d:\n", funclabel);
	print("enter [");
	for (i = 0, anysaved = 0; i <= 7; i++)
	    if (usedmask & ~(RREG(0) | RREG(1) | RREG(2)) & BIT(i)) {
		print(anysaved++ ? ",r%d" : "r%d", i);
		}

	/*  Will we need to push any fregs? */
	floatsaved = AND(usedmask, (FREG(4) | FREG(5) | FREG(6) | FREG(7)));
	framesize += tempsused * 8;

	if (!anysaved && !floatsaved) {
	    print("],%d\n", framesize + argbuildsize);
	    }
	else {
	    print("],%d\n", framesize);

	    /*	Generate code to save f4 - f7 by pushing them onto tos	*/
	    for (i = 15; i >= 12; i--)
		if (TESTBIT(floatsaved, i))
		    print("movl f%d,tos\n", i - 8);

	    /*  Make space on the stack to hold the largest argument list */
	    if (argbuildsize) {
		print("adjspb %d\n", argbuildsize);
		}
	    }

	if (isstruct(freturn(f->type)))
	    print("movl r1,-4(fp)\n");
	print("br L%d\n", funclabel + 1);
}

/* gen - generate code for the dags on list p */
Node gen(Node p) {
	Node head, *last, new;
	int		op;

	/*  Every node N at the top level that delivers a result into a
	 *  register, which value is used later,  gets marked with the
	 *  LOAD no-op, to prevent an optimization that would combine
	 *  N with the later node that references N, which would move
	 *  N from its current position.  Because N's address is held
	 *  somewhere else, and that address needs to point to the LOAD
	 *  node instead, the entire node N is actually copied into a new
	 *  structure, and the LOAD opcode is stuck into the old N.
	 *  The new node is only pointed to by the LOAD node, so the new
	 *  node gets a use count of 1.
	 */
	for (head = p; head; head = head->link) {
	    if (head->count != 0 && needsreg(head) &&
		((op = generic(head->op)) != LOAD) && op != CNST) {
		new = (Node)talloc(sizeof(*new));
		*new = *head;
		head->op = LOAD + optype(head->op);
		new->link = 0;
		head->kids[0] = new;
		new->count = 1;
	    }
	}


	print("gen gets the dags:\n");
	for (head = p; head; head = head->link) {
	    print("next dag:\n");
	    printdag(head, 1);
	    }
	outflush();

	debug(1,id = 0);

	/*  Set argument offsets */
	for (head = p; head; head = head->link) {
		fixoffsets(head);
	}

	/*  Set the global that holds the list head (for dagdump debugging
	 *  output).  Rewrite the dags on this list into assembly code.
	 */
	for (head = p; head; head = head->link) {
		globr = head;
		opt(head);
	}


	return p;
}


/* global - global id */
void global(Symbol p) {
	OUTPUT_GLOBAL();
	switch (p->type->align) {
	case 2: print(".align 1\n"); break;
	case 4: print(".align 2\n"); break;
	case 8: print(".align 3\n"); break;
	}
	global_cached_sym = p;
}
/* local - local variable */
void local(Symbol p) {
	offset = roundup(offset + p->type->size, p->type->align);
	offset = roundup(offset, 4);
	p->x.offset = -offset;
	/* p->x.name = stringf("%d(fp)", -offset); */
	p->x.name = stringd(-offset);
	p->class = AUTO;
}

/* needsreg - does p need a register? */
static int needsreg(p) Node p; {
	static int reg[] = { 0
#define xxop(a,b,c,d,e,f) , 0
#define yyop(a,b,c,d,e,f) |((f)==V?0:1<<(c))
#include "ops.h"
};
	if (opindex(p->op) < nelts(reg)) {
	    return reg[opindex(p->op)] & (1<<asmoptype(p->op));
	    }

        return reslb(p) < resub(p);
}

/* progbeg - beginning of program */
void progbeg(int argc, char *argv[]) {
	extern int atoi(char *);		/* (omit) */
	while (--argc > 0)
		++argv;
		     if (strcmp(*argv, "-r") == 0)	/* (omit) */
			rflag++;			/* (omit) */
#if LEARNING
		else if (strcmp(*argv, "-onesies") == 0)
			onesies();
#endif
	freebies = ~0;			/* all resources are free */
}

void putreg(regno, width, line)		/* give a register back */
    register int        regno;
    register RegSet   width;
    int                 line;
    {
    register int                lim;
#if 1
    register int	oldfreebies = freebies;
#endif
#if 0
    printf("putreg: mask %o line %d\n", ((1 << width) - 1) << regno, line);
#endif
    for (lim = regno + width; regno < lim; regno++) {
        SETBIT(freebies, regno);
        contents[regno] = NULL;
        }
#if 1
    if (oldfreebies == freebies)
        printf("# redundant putreg compiler regno %d width %d from line %d\n",
                regno,width, line);
#endif
    }

/*  fixoffsets - set argument offset in these nodes.  This code sort of depends
 *  upon the fact that ARG and CALL nodes are in the root level of the dag forest.
 *  It has been patched so that the CALL can live below a LOAD.
 */
static void fixoffsets(Node p) {

	retry:
	switch (generic(p->op)) {
	case ARG:
		/*  Re-use alignment symbol entry for argument offset */
		argoffset = roundup(argoffset, p->syms[1]->u.c.v.i);
		/* p->x.argoffset = argoffset; */
		p->syms[1] = intconst(argoffset);
		argoffset += p->syms[0]->u.c.v.i;
		if (argoffset > argbuildsize)
			argbuildsize = roundup(argoffset, 4);
		break;

	case CALL:
		argoffset = 0;
		break;

	case LOAD:
		p = p->kids[0];
		goto retry;
	/*
	This code sees assembly codes, which do not satisfy "valid".
	default:assert(valid(p->op));
	*/
	}
}


/* restore - restore registers in mask */
static void restore(RegSet mask) {
	int i;

	for (i = 1; i < nregs; i++)
		if (mask&(1<<i))
			print("movl %d(fp),r%d\n",
				4*i - framesize + argbuildsize, i);
}

/* save - save registers in mask */
static void save(RegSet mask) {
	int i;

	for (i = 1; i < nregs; i++)
		if (mask&(1<<i))
			print("movl r%d,%d(fp)\n", i,
				4*i - framesize + argbuildsize);
}

/* segment - switch to logical segment s */
void segment(int s) {
	OUTPUT_GLOBAL();
	switch (s) {
	case CODE: print(".text\n");   break;
	case  LIT: print(".text 1\n"); break;
	case DATA:
	case  BSS: print(".data\n");   break;
	default: assert(0);
	}
}


/* uses - return mask of registers used by node p */
static RegSet uses(Node p) {
	int i;
	RegSet m = 0;
	int	first, lim;

	first = kidlb(p);
	lim = kidub(p);
	for (i = first; i < lim; i++)
	    m = OR(m, sets(IKID(p,i)));
	return m;
}

/* valid - is operator op a valid operator ? */
static int valid(op) {
	static int ops[] = { 0
#define xxop(a,b,c,d,e,f) , 0
#define yyop(a,b,c,d,e,f) |(1<<(c))
#include "ops.h"
};
	return opindex(op) > 0 && opindex(op) < sizeof ops/sizeof ops[0] ?
		ops[opindex(op)]&(1<<asmoptype(op)) : 0;
}

#ifdef DEBUG
/* lprint - print the nodelist beginning at p */
static void lprint(Node p, char *s) {
	fprint(2, "node list%s:\n", s);
	if (p) {
		char buf[100];
		sprintf(buf, "%-30s%-8s%-8s%-8s%-7s%-13s%-10s%s",
		    " #", "op", "kids", "syms", "count", "uses", "sets",
		    "busy");
		fprint(2, "%s\n", buf);
	}
	for ( ; p; p = p->x.next)
		nprint(p);
}

/* nprint - print a line describing node p */
static void nprint(Node p) {
	int i;
	char *kids = "", *syms, buf[200];
	int first, lim;
	static char tbuf[100];

	if (p->kids[0]) {
		static char buf[100];
		buf[0] = 0;
		first = kidlb(p);
		lim = kidub(p);
		for (i = first; i < lim && IKID(p,i); i++)
			sprintf(buf + strlen(buf), "%3d", IKID(p,i)->x.id);
		kids = &buf[1];
	}
	tbuf[0] = tbuf[1] = 0;
	for (i = varlb(p); i < varub(p); i++) {
		if (sigs[signo(p->op)].numbers & 1 << i)
		    sprintf(tbuf + strlen(tbuf), " %d", INUM(p,i));

		else {
		    if (ISYM(p,i) && ISYM(p,i)->x.name)
			sprintf(tbuf + strlen(tbuf), " %s", ISYM(p,i)->x.name);
		    if (ISYM(p,i) && ISYM(p,i)->u.c.loc)
			sprintf(tbuf + strlen(tbuf), "=%s",
				ISYM(p,i)->u.c.loc->name);
		    }
	}
	syms = &tbuf[1];

	sprintf(buf, "%2d. %-30s%-8s%-8s %2d    %-13s",
		p->x.id, (p->op < MAXOP) ? opname(p->op) : skelptr[p->op],
		kids, syms, p->count, rnames(uses(p)));
	sprintf(buf + strlen(buf), " %s", rnames(sets(p)));
	sprintf(buf + strlen(buf), " %o", p->x.busy);
	fprint(2, "%s\n", buf);
}

/* rnames - return names of registers given by mask m */
char *rnames(RegSet m) {
	static char buf[100];
	int r;

	buf[0] = buf[1] = 0;
	for (r = 0; r < nregs; r++)
		if (m&(1<<r))
			sprintf(buf + strlen(buf), " r%d", r);
	return &buf[1];
}
#endif

/* called just before final exit */
void progend()
    {
#if DEBUG
    int	i,j,k;
    for (i = 0; i < 2; i++)
	for (j = 0; j <= MAXOPTSIZE; j++)
	    for (k = 0; k <= MAXOPTSIZE; k++)
		if (rewct[i][j][k])
		    printf("/ %s: %d->%d %d\n",
			    i==0?"gen":"opt", j,k,rewct[i][j][k]);
#endif
    }

		  /* " FDCSIUPVB" */
#define suffix(p)    ".fdbwllll."[asmoptype((p)->op)]




/*  Emit this instruction and its kids.  Try to allocate your result into one
 *  of the desireable target registers.
 *  Processes each dag root in the dag forest sequentially.
 *  For each root, it recurs on all of the children and emits code to evaluate each
 *  child.
 */
#define trace_emit 0
static void emit2(Node ins, RegSet desireable)
    {
    Node			spillins, kid, result;
    RegSet			kidreg, winner, mask, spillmask, trashed, ofreebies;
    RegSet			tomask;
    register char		*s;
    register int		i, lim;
    register int		j;
    register int		reg;
    struct Hnode		*var;
    int				kidtype;
    int				resultreg, restype;
    int				inswidth, spillwidth;
    int				width;
    int				fromclass, toclass, from;

#if trace_emit
    printf("emit ins %x desireable %o freebies %o\n", ins, desireable, freebies);
    dagdump(globr, 0, ins, 0);
    checkregs();
    /*	validag();	*/
#endif

    if (!ins->x.visited) {			/* first encounter?	*/

	ins->x.visited = 1;			/*  Mark instruction as visited */
	globr = ins;

	/*  Evaluate subtrees.  Target each subtree i into a register that is legal as
	 *  operand i of the current instruction.  If the current instruction reuses a
	 *  kid's register, try to evaluate the subtree into one of the desireable
	 *  registers.  If this is impossible, don't worry -- a register move will
	 *  probably be required for repositioning.
	 */
	for (i = kidlb(ins), lim = kidub(ins); i < lim; i++) {
	    mask = sig(ins, (int)i);
	    if (i == reslb(ins) && (mask & desireable) != 0)
		mask = AND(mask, desireable);
	    emit2(IKID(ins, i), mask);
	    }

	/*  All subtrees have been evaluated.  Make another try to position each subtree's result
	 *  into a legal register for operand i of the current instruction.
	 */
	for (i = kidlb(ins); i < lim; i++) {

	    /*  If this kid develops a result into a register, and the reg that it
	     *  develops it into is not legal as an input to the parent, then
	     *  find a register that is available & legal and move the value.
	     */
	    kid = IKID(ins, i);		/* The subdag */
	    kidtype = rtype(kid);	/* The type of the kid's result */
	    kidreg = holder(kid);	/* The register that holds the kid's result */

	    /*  Is kidreg legal as the ith operand to the current instruction? */
	    if ((BIT(kidreg) & sig(ins, (int)i)) == 0) {
#if trace_emit
		printf("kid %d width %d units in bad location: reg[%d]\n",
		    i, regpatts[kidtype].width, kidreg);
		printf("sig(ins,%d)=%o\n", i, sig(ins,i));
#endif
		/*  Not legal; it must be moved.  Find all available & legal registers */
		winner = freebit(freebies, regpatts[kidtype].width) & sig(ins, (int)i);

		/*  If this operand is current instructions' result, mask off parent's
		 *  desireable set, if possible.  
		 */
		if (i == reslb(ins) && (winner & desireable))
		    winner = AND(winner, desireable);

		/*  If there are no available and legal registers to move operand i
		 *  into, try to find another operand j which occupies a legal
		 *  register for operand i, and move operand j into a legal and available
		 *  register for operand j, to free up j's register for i.
		 *  THIS IS A HACK, DEPENDS ON THE ORDER IN WHICH OPERANDS GET PROCESSED!!
		 */
		if (winner == 0) {

		    /*  Find a register that is legal for operand i */
		    reg = lowbit(sig(ins, (int)i));

		    /*  The subtree contained in this register */ 
		    result = contents[reg];
#if trace_emit
		    printf("ins %x result %x freebies %o\n", ins,result,freebies);
#endif
		    /*  Find another place to put this subtree */
		    winner = freebit(freebies, regpatts[kidtype].width);

		    /*  Use a desireable location if possible */
		    if (winner & desireable)
			winner = AND(winner, desireable);

		    /*  If there's no other place to put this subtree */
		    if (!winner) {
#if trace_emit
			printf("going to badkid result %x\n", result);
#endif
			goto badkid;
			}

		    /*  Move operand j into the new location */
		    winner = lowbit(winner);
		    movereg(reg, BIT(winner), regpatts[kidtype].width, "reload 2");

		    /*  Now the old location is free, so use it */
		    winner = reg;
		    goto moveit;

		badkid:
		    cerror("can't reload i %d freebies %o desireable %o sig %o",
			i, freebies, desireable, sig(ins, (int)i));
		    }

		winner = lowbit(winner);

	    moveit:

		movereg(kidreg, BIT(winner), regpatts[kidtype].width, "reload");
		checkregs();
		IKID(ins,i)->x.reg = winner;
		}
#if trace_emit
	    else printf("kid %d is already in a good location\n", i);
#endif
	    }

	/*  Get the set of registers destroyed by this instruction */
#if 0
	print("ins %s alloclass %d sig:\n", skelptr[ins->op], alloclass(ins));
	outflush();
        writesig(stdout, sigptr[ins->op]);
#endif
	trashed = 0;
	if (alloclass(ins) == Call) {
	    trashed = 0xf07;			/* f0-f3 and r0-r2 */
	    }

	/*  Get the set of registers that are destroyed and not currently free */
	mask = trashed & ~freebies;

	/*  Get the set of registers that are destroyed, not currently free, and not
	 *  free after the instruction has consumed its inputs.  These registers must
	 *  be preserved by moving them to locations that are currently free and not
	 *  trashed.
	 */
	if (mask) {
	    for (i = kidlb(ins); i < lim; i++) {
		kid = IKID(ins, i);
		if (kid->count == 1) {
		    reg = holder(kid);		/* this reg is not free now but will be momentarily */
		    for (j = 0; j < regpatts[rtype(kid)].width; j++) {
			CLEARBIT(mask, reg + j);
			}
		    }
		}
	    }

	/*  Preserve these registers */
	while (mask) {

	    /*  Get the set of registers that cchop was able to find register-to-register
	     *  moves using the current type as a source.
	     */
	    from = lowbit(mask);
	    from = contents[from]->x.reg;	/* in case from is the high reg of a pair */
	    fromclass = rtype(contents[from]);
	    width = regpatts[fromclass].width;

	    tomask = 0;
	    for (toclass = 0; toclass < NOREG; toclass++)
		if (moveops[fromclass * NOREG + toclass] != -1) {
		    tomask = OR(tomask, ((1 << regpatts[toclass].many) - 1) << regpatts[toclass].bitorg);
#if trace_emit
		    print("ins %s rt %s toclass %d fromclass %d many %d bitorg %d tomask %o\n",
			skelptr[ins->op], INSRT(ins), toclass, fromclass,
			regpatts[toclass].many, regpatts[toclass].bitorg,
			tomask);
#endif
		    }

#if trace_emit
	    printf("ins %x trashes %s width %d, so save it mask %x freebies %x\n",
		    ins, regnames[0][from], regpatts[restype].width, mask, freebies);
#endif

	    /* Move to something ~Busy & ~trashed */
	    movereg((int)from,
			 AND(freebies, AND(NOT(trashed), tomask)),
			 width, "spill");
	    for (j = 0; j < width; j++) {
		CLEARBIT(mask, from + j);
		}
	    }

	/*  All subtrees have been positioned.  Free up any registers for which
	 *  the current instruction is the last use.  This is done after preserving stomped
	 *  registers, because otherwise the stomped registers will get moved on top of
	 *  the newly-freed-up inputs.
	 */
	checkregs();
#if trace_emit
	printf("ins %x looking for dead inputs ...\n", ins);
#endif

	ofreebies = freebies;
	for (i = kidlb(ins); i < lim; i++) {
	    kid = IKID(ins, i);
	    if (--kid->count == 0 && (kidtype = rtype(kid)) != NOREG) {
#if trace_emit
		printf("ins %x %%%d is dead ...\n", ins, i);
#endif
		reg = holder(kid);
		putreg(reg, regpatts[kidtype].width, __LINE__);
		checkregs();
		}
	    }

#if trace_emit
	printf("no more dead inputs\n");
#endif

	/*  Allocate the instruction's result if it generates one. */
	if ((restype = rtype(ins)) != NOREG) {

#if trace_emit
	    printf("ins %x %s allocating result freebies %o kidlb %d\n",
			ins, skelptr[ins->op], freebies, kidlb(ins));
#endif

	    /* Does this ins re-use an input?  If so, the result must be allocated to
	     * the same register as the input, even if the input is not available.
	     * The input must be made avaiable if necessary by moving its value somewhere else.
	     */
	    if (reslb(ins) < kidub(ins) && kidlb(ins) < kidub(ins)) {
#if trace_emit
	    printf("ins %x %s reuses input %d\n", ins, skelptr[ins->op], reslb(ins));
#endif
		reg = (ins->x.reg = (kid = IKID(ins, reslb(ins)))->x.reg);

		/*  Copy the input reg if this is not the last use, cuz this instruction is
		 *  about to stomp it.
		 */
		if (!TESTBIT(freebies, reg)) {

		    /* Move the value into another register (and free the input register).  */
		    if ((mask = ofreebies) & desireable)
			mask = AND(mask, desireable);
		    movereg((int) reg,(int) mask, regpatts[restype].width, "dest not dead yet!");
		    }

		/*  Allocate the input (and result) register for this instruction */
		getreg(BIT(reg), regpatts[restype].width, ins);
		}
	    else {
		/*  BUG: BROKEN FOR MULTIPLE INSTRUCTION RESULTS!! */
		/*  Prefer a location that's legal, desireable,		*/
		/*  and available.  If this is not possible we'll	*/
		/*  settle for legal and available, or just legal	*/
		mask = sig(ins, reslb(ins));		/* legal */
		if (mask & desireable)
			mask = AND(mask, desireable);	/* desireable */

		checkregs();

#if trace_emit
		printf("ins %x freebies %o desireable %o sig %o mask %o\n",
		    ins, freebies, desireable, sig(ins, reslb(ins)), mask);
#endif
		reg = getreg(mask, inswidth = regpatts[restype].width, ins);

#if trace_emit
		printf("ins %x freebies %o desireable %o sig %o mask %o\n",
		    ins, freebies, desireable, sig(ins, reslb(ins)), mask);
#endif
		/*  Must spill, vacate a register and re-try the allocation */
		if (reg == -1) {

		    /*  Get the set of useful registers */
		    spillmask = mask;
		    for (i = 0; i < inswidth; i++)
			spillmask = OR(spillmask, spillmask << 1);

		    printf("#\tmust vacate from spillmask %o\n", spillmask);

		    /*  Spill one register and retry.  If we need 2 adjacent */
		    /*  regs, this may get executed twice.                   */
		    for (i = 0; i < REGBITS; i++) {
			if (BIT(i) & spillmask && (spillins = contents[i])) {
			    spillwidth = regpatts[rtype(spillins)].width;
			    printf("#\treg %d spillable width %d\n",
				i, spillwidth);
			    movereg(i, ~mask, spillwidth, "vacate");

			    if ((reg = getreg(mask, inswidth, ins)) != -1) {
#if trace_emit
	    printf("after spill ins %x freebies %o desireable %o sig %o mask %o\n",
			ins, freebies, desireable, sig(ins, reslb(ins)), mask);
#endif
				break;
				}
			    }
			}
		    }

		ins->x.reg = reg;
		}
	    checkregs();
	    }

	checkregs();

	/*  Emit the instruction text */

	switch (ins->op) {
	case 0:
	    printf("no assembler syntax for '%s'\n", skelptr[ins->op]);
	    break;

	case LOADB: case LOADC: case LOADD: case LOADF:
	case LOADI: case LOADP: case LOADS: case LOADU:
	    break;

	/*  decline to emit movl d2,d2 */
	default:
	    if (sigs[signo(ins->op)].simplers != -1 ||
		ins->x.reg != IKID(ins, kidlb(ins))->x.reg) {
		s = skelptr[ins->op];
#if LEARNING
		s = conback(s);
#endif
		for (; *s;) {
		    if (ISVAR(s)) {
			/*	This variable is a kid pointer, or a number,	*/
			/*  or a string.  Handle the different cases.	*/
			i = VAR(s);
			if (reslb(ins) <= i && i < resub(ins)) {
			    print("%s", RESULTNAME(ins));
			    }

			else if (kidlb(ins) <= i && i < kidub(ins)) {
			    print("%s", RESULTNAME(IKID(ins,i)));
			    }

			/*
			else if (sigs[signo(ins->op)].numbers & 1 << i)
			    print("%d", INUM(ins, i));
			*/

			else if (varlb(ins) <= i && i < varub(ins)) {
			    /* else if (ISYM(ins, i)) */
			    if (sigs[signo(ins->op)].numbers & 1 << i)
				print("%d", INUM(ins, i));
			    else 
				print("%s", ISYM(ins, i)->x.name);
			    }

			else
			    print("%%%d", VAR(s));

			s += VARLN;
			}
		    else print("%c", *s++);
		    }
		print("\n");
		}
	    break;
	    }
	}

    /*  Free up the root of this dag if it has a result and no uses.  Function calls,
     *  for example.
     */
    if (ins->count == 0 && rtype(ins) != NOREG)
	putreg(ins->x.reg, regpatts[rtype(ins)].width,__LINE__);
#if trace_emit
    printf("returning ins %x freebies %o\n", ins, freebies);
#endif
    }

void emit(Node ins)
    {
    for (; ins; ins = ins->link) {
	globr = ins;
	emit2(ins, (RegSet)-1);
	}
    }

/*  We need to write do_difficult_reposition.  This routine assumes that there are
 *  n values and m registers, n < m.  There is a set of legal registers for each value,
 *  chosen from the m.  Each value currently occupies one of the m registers and the 
 *  routine must generate an efficient sequence of moves (and possibly exchanges) to
 *  reposition each of the n values into a legal register.  Must handle multi-register
 *  values.
 *
 *  Outline:
 *      Keep a vector of sets of values.  A value is at position j on this vector
 *      if the value has j legal and available locations remaining for it.
 *      (Remaining means not already pegged).
 *      Peg each value on the vector in increasing order.  When a value is
 *      pegged, recalculate how many locations remain for each remaining value
 *      and reposition that value on the vector.
 *      Within those values that are equally constrained, do the operands that are
 *      already in legal locations.
 *      Within values not in legal locations, peg operands which require free locations first.
 *      Allocate registers not required by other unpegged operands first.
 */






/*  Find a contiguous set of one bits in freebies of the given width.	*/
/*  The lowest such bit must be in the given mask.			*/
/*  Allocate all those bits (set them to zero) and set contents[bit]	*/
/*  to the given ins.	Also set usedmask to the allocated bits.	*/
int getreg(mask, width, ins)		/* allocate registers	*/
    RegSet	mask;
    int		width;
    Node	ins;
    {
    RegSet	tfreebs;
    int		lim;
    int		winner;
    int		regno;

#if 0
    printf("getreg: mask %o width %d ins %x freebies %o\n",
	mask, width, ins, freebies);
#endif

    /*  build a bit vector of contigous sets free regs of the given width */
    tfreebs = freebit(freebies,width);

    /*  that also fit the mask we were passed */
    tfreebs = AND(tfreebs, mask);
    if (!tfreebs) {
#if 0
	printf("getreg fails!\n");
#endif
	return -1;
	}

    winner = lowbit(tfreebs);
    ins->x.reg = winner;
    tfreebs = ((1 << width) - 1) << winner;	/* bits to allocate	*/
    usedmask = OR(usedmask, tfreebs);
    freebies = AND(freebies, NOT(tfreebs));	/* allocate them	*/
    for (lim = winner; lim < winner + width; lim++)
	contents[lim] = ins;

#if 0
    printf("getreg returns reg[%d]\n", winner);
#endif
    return winner;
    }


freebit(freeregs, width)		/* return free regs of given width */
    register RegSet	freeregs;
    register RegSet	width;
    {
    register int		i;

    for (i = 1; i < width; i++)
	freeregs = AND(freeregs, freeregs >> 1);
    return freeregs;
    }

/* vtoa - return string for the constant v of type ty */
char *vtoa(ty, v) Type ty; Value v; {
	ty = unqual(ty);
	switch (ty->op) {
	case CHAR:
		return stringf("%d", v.sc);	/* WAS uc */
	case SHORT:
		return stringf("%d", v.ss);
	case INT:
		return stringf("%d", v.i);
	case UNSIGNED:
		if ((v.u&~0x7fff) == 0)
			return stringf("%d", v.u);
		else
			return stringf("0x%x", v.u);
	case FLOAT:
		if (v.f == 0.0)
			return "0";
		sprintf(buf, "0r%.*g", 8, v.f);
		return string(buf);
	case DOUBLE:
		if (v.d == 0.0)
			return "0";
		sprintf(buf, "0r%.*g", 18, v.d);
		return string(buf);
	case ARRAY:
		if (ty->type->op == CHAR)
			return v.p;
		/* else fall thru */
	case POINTER: case FUNCTION:
		if (((unsigned)v.p&~0x7fff) == 0)
			return stringf("%d", v.p);
		else
			return stringf("0x%x", v.p);
	default:assert(0);
	}
	return 0;
}
