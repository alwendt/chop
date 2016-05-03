/* C compiler: main program */

#include "version.h"
#include "c.h"

int Aflag;			/* >= 0 if -A specified */
int Pflag;			/* != 0 if -P specified */
int npoints;			/* # of execution points if -b specified */
int ncalled = -1;		/* #times prof.out says current function was called */
Symbol YYcounts;		/* symbol for _YYcounts if -b specified */
Symbol YYlink;			/* symbol for file's struct _bbdata */
Symbol YYnull;			/* symbol for _YYnull if -n specified */
Symbol YYprintf;		/* symbol for printf, if -t[name] specified */
int glevel;			/* == [0-9] if -g[0-9] specified */
int xref;			/* != 0 for cross-reference data */

static char *infile;		/* input file */
static char *outfile;		/* output file */
static char *progname;		/* argv[0] */
static Symbol symroot;		/* root of the global symbols */

List loci, tables;		/* current (locus,table) lists */

dclproto(static int bbfile,(char *))
dclproto(static void bbsetup,(void))
dclproto(static void bbvars,(int))
dclproto(static void compile,(char *))
dclproto(static int doargs,(int, char **))
dclproto(static void emitYYnull,(void))
dclproto(static Type ftype,(Type, Type))
dclproto(static void typestab,(Symbol))

int main(argc, argv) char *argv[]; {
	assert(MAXKIDS >= 2);
	assert(MAXSYMS >= 2);
	progname = argv[0];
	typeInit();
	level = GLOBAL;
	argc = doargs(argc, argv);
	assert(inttype->size >= voidptype->size);
	if (infile && *infile != '-') {
		close(0);
		if (open(infile, 0) != 0) {
			fprint(2, "%s: can't read %s\n", argv[0], infile);
			exit(1);
		}
	}
	if (outfile && *outfile != '-') {
		close(1);
		if (creat(outfile, 0666) != 1) {
			fprint(2, "%s: can't write %s\n", argv[0], outfile);
			exit(1);
		}
	}
	inputInit(0);
	t = gettok();
	progbeg(argc, argv);
	stabinit(firstfile);
	program();
	bbvars(npoints);
	emitYYnull();
	finalize();
	if (glevel || xref) {
		Coordinate src;
		foreach(typestab, types, GLOBAL);
		foreach(typestab, identifiers, GLOBAL);
		src.file = firstfile;
		src.x = 0;
		src.y = lineno;
		if (glevel > 2 || xref)
			stabend(&src, symroot, (Coordinate **)ltoa(append((Generic)0, loci), 0),
				(Symbol *)ltoa(append((Generic)0, tables), 0),
				symbols ? (Symbol *)ltoa(symbols, 0) : 0);
		else
			stabend(&src, 0, 0, 0, 0);
	}
#ifdef progend
	progend(0);
#else
	progend();
#endif
	outflush();
	exit(errcnt > 0);
	return 0;
}

/* compile - compile str */
static void compile(str) char *str; {
	inputstring(str);
	t = gettok();
	program();
}

/* doargs - process program arguments, removing top-half arguments from argv */
static int doargs(argc, argv) char *argv[]; {
	char *s;
	int i, j, x;
	Symbol p;

	for (i = j = 1; i < argc; i++)
		if (strcmp(argv[i], "-g") == 0)
			glevel = 2;
		else if (strncmp(argv[i], "-g", 2) == 0
		&& argv[i][2] && argv[i][2] >= '0' && argv[i][2] <= '9')
			glevel = argv[i][2] - '0';
		else if (strcmp(argv[i], "-x") == 0)
			xref++;
		else if (strcmp(argv[i], "-A") == 0)
			Aflag++;
		else if (strcmp(argv[i], "-P") == 0)
			Pflag++;
		else if (strcmp(argv[i], "-w") == 0)
			wflag++;
		else if (strncmp(argv[i], "-a", 2) == 0) {
			if (ncalled == -1 && process(argv[i][2] ? &argv[i][2] : "prof.out") > 0)
				ncalled = 0;
		} else if (strcmp(argv[i], "-C") == 0) {
			if (!YYlink)
				YYlink = genident(STATIC, array(unsignedtype, 0, 0), GLOBAL);
		} else if (strcmp(argv[i], "-b") == 0) {
			if (!YYcounts)
				bbsetup();
		} else if (strcmp(argv[i], "-n") == 0) {
			if (!YYnull)
				YYnull = mksymbol(EXTERN, "_YYnull", ftype(voidtype, inttype));
			YYnull->class = STATIC;
		} else if (strncmp(argv[i], "-t", 2) == 0) {
			if (!YYprintf)
				YYprintf = mksymbol(STATIC, argv[i][2] ? &argv[i][2] : "printf",
					ftype(voidtype, ptr(chartype)));
			YYprintf->class = EXTERN;
		} else if (strcmp(argv[i], "-v") == 0)
			fprint(2, "%s version %d.%d\n", progname, VERSION>>8, VERSION&0xff);
		else if (strncmp(argv[i], "-s", 2) == 0)
			density = strtod(&argv[i][2], (char **)0);
		else if (strncmp(argv[i], "-e", 2) == 0) {
			if ((x  = strtol(&argv[i][2], (char **)0, 0)) > 0)
				errlimit = x;
		} else if ((s = strchr(argv[i], '=')) &&
			(p = lookup(stringn(argv[i], s - argv[i]), types))) {
			if (*s == '=') {
				if ((x = strtol(s + 1, &s, 0)) > 0)
					p->type->size = x;
			}
			if (*s == ',') {
				if ((x = strtol(s + 1, &s, 0)) > 0)
					p->type->align = x;
			}
			if (*s++ == ',')
				p->addressed = !(*s == 0 || *s == '0');
		} else if (strcmp(argv[i], "-") == 0 || *argv[i] != '-') {
			if (infile == 0)
				infile = argv[i];
			else if (outfile == 0)
				outfile = argv[i];
			else
				argv[j++] = argv[i];
		} else {
			if (strcmp(argv[i], "-XP") == 0)
				argv[i] = "-p";
			else if (strncmp(argv[i], "-X", 2) == 0)
				*++argv[i] = '-';
			argv[j++] = argv[i];
		}
	argv[j] = 0;
	return j;
}

/* emitYYnull - compile definition for _YYnull, if referenced */
static void emitYYnull() {
	if (YYnull && YYnull->ref > 0) {
		Aflag = 0;
		YYnull->defined = 0;
		YYnull = 0;
		compile(stringf("static char *_YYfile = \"%s\";\n", file));
		compile("static void _YYnull(int line,...) {\n\
	char buf[200];\n\
	sprintf(buf, \"null pointer dereferenced @%s:%d\\n\", _YYfile, line);\n\
	write(2, buf, strlen(buf));\n\
	abort();\n\
}\n");
	} else if (YYnull)
		YYnull->ref = 1000;
}

/* ftype - return a function type for `rty function (ty,...)' */
static Type ftype(rty, ty) Type rty, ty; {
	Symbol p = (Symbol) alloc(sizeof *p);

	BZERO(p, struct symbol);
	p->type = ty;
	p->u.proto = (Symbol) alloc(sizeof *p);
	BZERO(p->u.proto, struct symbol);
	p->u.proto->type = voidtype;
	return func(rty, p);
}

/* typestab - emit stab entries for p */
static void typestab(p) Symbol p; {
	if (symroot == 0 && p->class && p->class != TYPEDEF)
		symroot = p;
	if (p->class == TYPEDEF || p->class == 0)
		stabtype(p);
}

/* Profiling */

struct callsite {
	char *file, *name;
	union coordinate {
		struct {
#ifdef LITTLE_ENDIAN
			unsigned int y:16,x:10,index:6;
#else
			unsigned int index:6,x:10,y:16;
#endif
		} c;
		unsigned int coord;
	} u;
};
struct func {
	struct func *link;
	struct caller *callers;
	char *name;
	union coordinate src;
};
struct map {		/* source code map; 200 coordinates/map */
	int size;
	union coordinate u[200];
};
static List maplist;	/* list of struct map *'s */
static List filelist;	/* list of file names */
static Symbol funclist;	/* list of struct func *'s */
static Symbol afunc;	/* current function's struct func */

/* bbcall - return tree to set _callsite at call site src, emit call site data */
Tree bbcall(src) Coordinate src; {
	static Symbol caller;
	Value v;
	union coordinate u;
	Symbol p = genident(STATIC, array(voidptype, 0, 0), GLOBAL);

	defglobal(p, LIT);
	defpointer(src.file ? mkstr(src.file)->u.c.loc : 0);
	defpointer(mkstr(cfunc->name)->u.c.loc);
	u.c.x = src.x;
	u.c.y = src.y;
	defconst(U, (v.u = u.coord, v));
	if (caller == 0)
		caller = mksymbol(EXTERN, "_caller", ptr(voidptype));
	return asgn(caller, idnode(p));
}

/* bbentry - return tree for `_prologue(&afunc, &YYlink)' */
Tree bbentry() {
	static Symbol p;
	
	afunc = genident(STATIC, array(voidptype, 4, 0), GLOBAL);
	if (p == 0)
		p = mksymbol(EXTERN, "_prologue", ftype(inttype, voidptype));
	return callnode(idnode(p), freturn(p->type),
		tree(ARG+P, ptr(unsignedtype), idnode(YYlink),
		tree(ARG+P, ptr(unsignedtype), idnode(afunc), 0)));
}

/* bbexit - return tree for `_epilogue(&afunc)' */
Tree bbexit() {
	static Symbol p;
	
	if (p == 0)
		p = mksymbol(EXTERN, "_epilogue", ftype(inttype, voidptype));
	return callnode(idnode(p), freturn(p->type),
		tree(ARG+P, ptr(unsignedtype), idnode(afunc), 0));
}

/* bbfile - add file to list of file names, return its index */
static int bbfile(file) char *file; {
	if (file) {
		List lp;
		int i = 1;
		if (lp = filelist)
			do {
				lp = lp->link;
				if (((Symbol)lp->x)->u.c.v.p == file)
					return i;
				i++;
			} while (lp != filelist);
		filelist = append(mkstr(file), filelist);
		return i;
	}
	return 0;
}

/* bbfuncs - emit function name and src coordinates */
void bbfuncs(name, src) char *name; Coordinate src; {
	Value v;
	union coordinate u;

	defglobal(afunc, DATA);
	defpointer(funclist);
	defpointer(0);
	defpointer(mkstr(name)->u.c.loc);
	u.c.x = src.x;
	u.c.y = src.y;
	u.c.index = bbfile(src.file);
	defconst(U, (v.u = u.coord, v));
	funclist = afunc;
}

/* bbincr - return tree to increment execution point at src */
Tree bbincr(src) Coordinate src; {
	struct map *mp = (struct map *)maplist->x;
	Tree e = incr('+', rvalue((*opnode['+'])(ADD, pointer(idnode(YYcounts)),
		constnode(npoints++, inttype))), constnode(1, inttype), 1);

	/* append src to source map */
	if (mp->size >= sizeof mp->u/sizeof mp->u[0]) {
		mp = (struct map *)alloc(sizeof *mp);
		mp->size = 0;
		maplist = append((Generic *)mp, maplist);
	}
	mp->u[mp->size].c.x = src.x;
	mp->u[mp->size].c.y = src.y;
	mp->u[mp->size++].c.index = bbfile(src.file);
	return e;
}

/* bbsetup - initialize basic block counting variables */
static void bbsetup() {
	if (YYlink == 0)
		YYlink = genident(STATIC, array(unsignedtype, 0, 0), GLOBAL);
	YYcounts = genident(STATIC, array(unsignedtype, 0, 0), GLOBAL);
	maplist = append((Generic)alloc(sizeof(struct map)), maplist);
	((struct map *)maplist->x)->size = 0;
}

/* bbvars - emit definition for basic block counting data */
static void bbvars(n) {
	int i, j;
	Value v;
	struct map **mp;
	Symbol coords, files, *p;

	if (!YYcounts && !YYlink)
		return;
	if (YYcounts) {
		if (n <= 0)
			n = 1;
		defglobal(YYcounts, BSS);
		space(n*YYcounts->type->type->size);
	}
	files = genident(STATIC, array(ptr(chartype), 1, 0), GLOBAL);
	defglobal(files, LIT);
	for (p = (Symbol *)ltoa(filelist, 0); *p; p++)
		defpointer((*p)->u.c.loc);
	defpointer(0);
	coords = genident(STATIC, array(unsignedtype, n, 0), GLOBAL);
	defglobal(coords, LIT);
	for (i = n, mp = (struct map **)ltoa(maplist, 0); *mp; i -= (*mp)->size, mp++)
		for (j = 0; j < (*mp)->size; j++)
			defconst(U, (v.u = (*mp)->u[j].coord, v));
	if (i > 0)
		space(i*coords->type->type->size);
	defpointer(0);
	defglobal(YYlink, DATA);
	defpointer(0);
	defconst(U, (v.u = n, v));
	defpointer(YYcounts);
	defpointer(coords);
	defpointer(files);
	defpointer(funclist);
	YYcounts = YYlink = 0;
}

/* Tracing */

static char *fmt, *fp, *fmtend;	/* format string, current & limit pointer */
static Tree args;		/* printf arguments */
static Symbol frameno;		/* local holding frame number */

dclproto(static void appendstr,(char *))
dclproto(static void tracefinis,(void))
dclproto(static void tracevalue,(Tree, int))

/* appendstr - append str to the evolving format string, expanding it if necessary */
static void appendstr(str) char *str; {
	do
		if (fp == fmtend) {
			if (fp) {
				char *s = (char *)talloc(2*(fmtend - fmt));
				strncpy(s, fmt, fmtend - fmt);
				fp = s + (fmtend - fmt);
				fmtend = s + 2*(fmtend - fmt);
				fmt = s;
			} else {
				fp = fmt = (char *)talloc(80);
				fmtend = fmt + 80;
			}
		}
	while (*fp++ = *str++);
	fp--;
}

/* tracecall - generate code to trace entry to f */
void tracecall(f, callee) Symbol f, callee[]; {
	int i;
	Symbol counter = genident(STATIC, inttype, GLOBAL);

	defglobal(counter, BSS);
	space(counter->type->size);
	frameno = genident(AUTO, inttype, 0);
	addlocal(frameno);
	appendstr(f->name); appendstr("#");
	tracevalue(asgn(frameno, incr(INCR, idnode(counter), constnode(1, inttype), 1)), 0);
	appendstr("(");
	for (i = 0; callee[i]; i++) {
		if (i)
			appendstr(",");
		appendstr(callee[i]->name); appendstr("=");
		tracevalue(idnode(callee[i]), 0);
	}
	if (variadic(f->type))
		appendstr(",...");
	appendstr(") called\n");
	tracefinis();
}

/* tracefinis - complete & generate the trace code */
static void tracefinis() {
	Tree *ap;
	Symbol p;

	*fp = 0;
	p = mkstr(string(fmt));
	for (ap = &args; *ap; ap = &(*ap)->kids[1])
		;
	*ap = tree(ARG+P, ptr(chartype), pointer(idnode(p->u.c.loc)), 0);
	walk(callnode(idnode(YYprintf), freturn(YYprintf->type), args), 0, 0);
	args = 0;
	fp = fmtend = 0;
}

/* tracereturn - generate code to trace return x */
void tracereturn(f, x) Symbol f, x; {
	appendstr(f->name); appendstr("#");
	tracevalue(idnode(frameno), 0);
	appendstr(" returned");
	if (freturn(f->type) != voidtype && x) {
		appendstr(" ");
		tracevalue(idnode(x), 0);
	}
	appendstr("\n");
	tracefinis();
}

/* tracevalue - append format and argument to print the value of e */
static void tracevalue(e, lev) Tree e; {
	Type ty = unqual(e->type);

	switch (ty->op) {
	case CHAR:
		appendstr("'\\x%2x'");
		break;
	case SHORT:
		if (ty == unsignedshort)
			appendstr("0x%x");
		else /* fall thru */
	case INT:
			appendstr("%d");
		break;
	case UNSIGNED:
		appendstr("0x%x");
		break;
	case FLOAT: case DOUBLE:
		appendstr("%g");
		break;
	case POINTER:
		if (unqual(ty->type) == chartype) {
			static Symbol null;
			if (null == 0)
				null = mkstr("(null)");
			tracevalue(constnode(0, unsignedtype), lev + 1);
			appendstr(" \"%s\"");
			e = condnode(e, e, pointer(idnode(null->u.c.loc)));
		} else {
			appendstr("("); appendstr(typestring(ty, "")); appendstr(")0x%x");
		}
		break;
	case STRUCT: {
		Field q;
		appendstr("("); appendstr(typestring(ty, "")); appendstr("){");
		for (q = ty->sym->u.s.flist; q; q = q->link) {
			appendstr(q->name); appendstr("=");
			tracevalue(field(addrof(e), q->name), lev + 1);
			if (q->link)
				appendstr(",");
		}
		appendstr("}");
		return;
		}
	case UNION:
		appendstr("("); appendstr(typestring(ty, "")); appendstr("){...}");
		return;
	case ARRAY:
		if (lev && ty->type->size > 0) {
			int i;
			e = pointer(e);
			appendstr("{");
			for (i = 0; i < ty->size/ty->type->size; i++) {
				Tree p = (*opnode['+'])(ADD, e, constnode(i, inttype));
				if (isptr(p->type) && isarray(p->type->type))
					p = retype(p, p->type->type);
				else
					p = rvalue(p);
				if (i)
					appendstr(",");
				tracevalue(p, lev + 1);
			}
			appendstr("}");
		} else
			appendstr(typestring(ty, ""));
		return;
	default:
		assert(0);
	}
	if (ty == floattype)
		e = cast(e, doubletype);
	else if ((isint(ty) || isenum(ty)) && ty->size != inttype->size)
		e = cast(e, promote(ty));
	args = tree(ARG + widen(e->type), e->type, e, args);
}
