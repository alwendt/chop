/* C compiler: symbolic code generator */

#include "c.h"

static int maxoffset;		/* maximum value of offset */
static int offset;		/* current frame offset */
static Node *tail;

dclproto(static int gen1,(Node, int, int))

/* address - initialize q for addressing expression p+n */
void address(q, p, n) Symbol q, p; int n; {
	q->x.name = stringf("%s%s%d", p->x.name, n > 0 ? "+" : "", n);
}

/* asmcode - emit assembly language specified by asm */
void asmcode(str, argv) char *str; Symbol argv[]; {
	for ( ; *str; str++)
		if (*str == '%' && str[1] >= 0 && str[1] <= 9)
			print("%s", argv[*++str]->x.name);
		else
			*bp++ = *str;
	outs("\n");
}

/* blockbeg - begin a compound statement */
void blockbeg(e) Env *e; {
	*e = offset;
}

/* blockend - end a compound statement */
void blockend(e) Env *e; {
	if (offset > maxoffset)
		maxoffset = offset;
	offset = *e;
}

/* defconst - define a constant */
void defconst(ty, v) Value v; {
	print("defconst ");
	switch (ty) {
	case C: print("char %d\n",       v.uc); break;
	case S: print("short %d\n",      v.ss); break;
	case I: print("int %d\n",        v.i ); break;
	case U: print("unsigned 0x%x\n", v.u ); break;
	case P: print("void* 0x%x\n",    v.p ); break;
	case F: {
		char buf[MAXLINE];
		sprintf(buf, "float %.8e\n", v.f);  /* fix */
		outs(buf);
		break;
		}
	case D: {
		char buf[MAXLINE];
		sprintf(buf, "double %.18e\n", v.d);  /* fix */
		outs(buf);
		break;
		}
	default: assert(0);
	}
}

/* defstring - emit a string constant */
void defstring(len, s) char *s; {
	int n;

	print("defstring \"");
	for (n = 0; len-- > 0; s++) {
		if (n >= 72) {
			print("\n");
			n = 0;
		}
		if (*s == '"' || *s == '\\') {
			print("\\%c", *s);
			n += 2;
		} else if (*s >= ' ' && *s < 0177) {
			*bp++ = *s;
			n += 1;
		} else {
			print("\\%d%d%d", (*s>>6)&3, (*s>>3)&7, *s&7);
			n += 4;
		}
	}
	print("\"\n");
}

/* emit - emit the dags on list p */
void emit(p) Node p; {
	for (; p; p = p->x.next)
		if (p->op == LABEL+V) {
			assert(p->syms[0]);
			print("%s:\n", p->syms[0]->x.name);
		} else {
			int i;
			assert(p->link == 0 || p->x.lev == 0);
			print("node%c%d %s count=%d", p->x.lev == 0 ? '\'' : '#', p->x.id,
				opname(p->op), p->count);
			for (i = 0; i < MAXKIDS && p->kids[i]; i++)
				print(" #%d", p->kids[i]->x.id);
			for (i = 0; i < MAXSYMS && p->syms[i]; i++) {
				if (p->syms[i]->x.name)
					print(" %s", p->syms[i]->x.name);
				if (p->syms[i]->name != p->syms[i]->x.name)
					print(" (%s)", p->syms[i]->name);
			}
			print("\n");
		}
}

/* function - generate code for a function */
void function(f, caller, callee, ncalls) Symbol f, caller[], callee[]; {
	int i;

	sym("function", f, ncalls ? 0 : "\n");
	if (ncalls)
		print(" ncalls=%d\n", ncalls);
	offset = 0;
	for (i = 0; caller[i] && callee[i]; i++) {
		offset = roundup(offset, caller[i]->type->align);
		caller[i]->x.name = caller[i]->name;
		callee[i]->x.name = callee[i]->name;
		caller[i]->x.offset = callee[i]->x.offset = offset;
		sym("caller's parameter", caller[i], "\n");
		sym("callee's parameter", callee[i], "\n");
		offset += caller[i]->type->size;
	}
	maxoffset = offset = 0;
	gencode(caller, callee);
	print("maxoffset=%d\n", maxoffset);
	emitcode();
	print("end %s\n", f->x.name);
}

/* gen - generate code for the dags on list p */
Node gen(p) Node p; {
	int n;
	Node nodelist;

	tail = &nodelist;
	for (n = 0; p; p = p->link) {
		switch (generic(p->op)) {	/* check for valid nodelist */
		case CALL:
			break;
		case ARG:
		case ASGN: case JUMP: case LABEL: case RET:
		case EQ: case GE: case GT: case LE: case LT: case NE:
			assert(p->count == 0);
			break;
		case INDIR:
		default:
			assert(p->count);
		}
		n = gen1(p, 0, n);
	}
	*tail = 0;
	return nodelist;
}

/* gen1 - generate code for *p */
static int gen1(p, lev, n) Node p; {
	if (p && p->x.id == 0) {
		p->x.lev = lev;
		p->x.id = ++n;
		n = gen1(p->kids[0], lev + 1, n);
		n = gen1(p->kids[1], lev + 1, n);
		*tail = p;
		tail = &p->x.next;
	}
	return n;
}

/* local - local variable */
void local(p) Symbol p; {
	offset = roundup(offset, p->type->align);
	p->x.name = p->name;
	p->x.offset = offset;
	sym("local", p, "\n");
	offset += p->type->size;
}

/* progbeg - beginning of program */
void progbeg(argc, argv) char *argv[]; {
	print("progbeg argv=");
	while (argc--)
		print("%s ", *argv++);
	print("\n");
}

/* stabend - finalize stab output */
void stabend(cp, p, cpp, sp, syms) Coordinate *cp; Symbol p, *sp, *syms; Coordinate **cpp; {
	for (cp; p; p = p->up)
		print("%s@0x%x\n", p->name, p);
	for (; cpp && *cpp; cpp++, sp++) {
		assert(sp);
		print("%s:%d.%d", (*cpp)->file ? (*cpp)->file : "", (*cpp)->y, (*cpp)->x);
		for (p = *sp; p && p->scope > GLOBAL; p = p->up)
			print(" %s@0x%x", p->name, p);
		for (; p; p = p->up)
			print(" %s", p->name);
		print("\n");
	}
	for ( ; syms && (p = *syms); syms++) {
		char *file = 0;
		print("%s@0x%x src=", p->name, p);
		if (p->src.file && p->src.file != file)
			print("%s:", file = p->src.file);
		print("%d.%d uses=[", p->src.y, p->src.x);
		for (cpp = p->uses; cpp && *cpp; cpp++) {
			print(" ");
			if ((*cpp)->file && (*cpp)->file != file)
				print("%s:", file = (*cpp)->file);
			print("%d.%d", (*cpp)->y, (*cpp)->x);
		}
		print(" ]\n");
	}
}

/* sym - print symbol table entry for p, followed by str */
void sym(kind, p, str) char *kind, *str; Symbol p; {
	if (glevel > 2)
		print("0x%x ", p);
	print("%s %s", kind, p->x.name);
	if (p->name != p->x.name)
		print(" (%s)", p->name);
	print(" type=%t class=%k scope=", p->type, p->class);
	switch (p->scope) {
	case CONSTANTS: print("CONSTANTS"); break;
	case LABELS: print("LABELS"); break;
	case GLOBAL: print("GLOBAL"); break;
	case PARAM:  print("PARAM");  break;
	case LOCAL:  print("LOCAL");  break;
	default:
		if (p->scope > LOCAL)
			print("LOCAL+%d", p->scope - LOCAL);
		else
			print("%d", p->scope);
	}
	if (p->scope >= PARAM && p->class != STATIC)
		print(" offset=%d ref=%d", p->x.offset, p->ref);
	if (str)
		print(str);
}
