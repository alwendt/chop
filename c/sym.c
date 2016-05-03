/* C compiler: symbol table management */

#include "c.h"
#define hash(name) ((unsigned)name)

struct entry {		/* symbol table entries: */
	struct symbol sym;	/* the symbol; must be first field */
	List refs;		/* list form of sym.uses */
	struct entry *link;	/* link to next entry on hash chain */
};

static struct table {	/* symbol tables: */
	int level;		/* scope level for this table */
	struct table *previous;	/* table for previous scope */
	Symbol list;		/* list of entries in reverse insertion order via up fields */
	struct entry *buckets[HASHSIZE];
} tconstants =   { CONSTANTS },
  texternals =   { GLOBAL },
  tidentifiers = { GLOBAL },
  ttypes =	 { 0 };
	
int bnumber;				/* current block number */
Table constants	  = &tconstants;	/* constant table */
Table externals	  = &texternals;	/* externals table */
Table identifiers = &tidentifiers;	/* identifier table */
Table globals	  = &tidentifiers;	/* globals portion of identifiers */
Table labels[2];			/* label tables */
Table types	  = &ttypes;		/* types table */
int level;				/* current block level */
List symbols;				/* list of all symbols; used only if xref != 0 */

static int label = 1;		/* next global label */
static struct temporary {	/* temporaries: */
	Symbol sym;			/* pointer to the symbol */
	struct temporary *link;		/* next available temporary */
} *temps;			/* list of available temporaries */
static Type *btot[] = { 0, &floattype, &doubletype, &chartype,
	&shorttype, &inttype, &unsignedtype, &voidptype };

/* constant - install and return constant v of type ty */
Symbol constant(ty, v) Type ty; Value v; {
	register struct entry *p;
	register unsigned h = hash(v.u)&(HASHSIZE-1);

	ty = unqual(ty);
	for (p = constants->buckets[h]; p; p = p->link)
		if (ty == p->sym.type)
			switch (ty->op) {
			case CHAR:     if (v.uc == p->sym.u.c.v.uc) return &p->sym; break;
			case SHORT:    if (v.ss == p->sym.u.c.v.ss) return &p->sym; break;
			case INT:      if (v.i  == p->sym.u.c.v.i)  return &p->sym; break;
			case UNSIGNED: if (v.u  == p->sym.u.c.v.u)  return &p->sym; break;
			case FLOAT:    if (v.f  == p->sym.u.c.v.f)  return &p->sym; break;
			case DOUBLE:   if (v.d  == p->sym.u.c.v.d)  return &p->sym; break;
			case ARRAY: case FUNCTION:
			case POINTER:  if (v.p  == p->sym.u.c.v.p)  return &p->sym; break;
			default: assert(0);
			}
	p = (struct entry *) alloc(sizeof *p);
	BZERO(&p->sym, struct symbol);
	p->sym.name = vtoa(ty, v);
	p->sym.scope = CONSTANTS;
	p->sym.type = ty;
	p->sym.class = STATIC;
	p->sym.u.c.v = v;
	p->sym.defined = 1;
	p->link = constants->buckets[h];
	p->sym.up = constants->list;
	constants->list = &p->sym;
	constants->buckets[h] = p;
	p->refs = 0;
	defsymbol(&p->sym);
	return &p->sym;
}

/* enterscope - enter a scope */
void enterscope() {
	if (++level >= 65535)
		error("compound statements nested too deeply\n");
}

/* exitscope - exit a scope */
void exitscope() {
	rmtypes();
	rmtemps(0, level);
	if (identifiers->level == level) {
		if (Aflag >= 2) {
			int n = 0;
			Symbol p;
			for (p = identifiers->list; p && p->scope == level; p = p->up)
				if (++n > 127) {
					warning("more than 127 identifiers declared in a block\n");
					break;
				}
		}
		if (xref)
			setuses(identifiers);
		identifiers = identifiers->previous;
	}
	if (types->level == level) {
		if (xref) {
			foreach(fielduses, types, level);
			setuses(types);
		}
		types = types->previous;
	}
	assert(level >= GLOBAL);
	--level;
}

/* fielduses - convert use lists for fields in type p */
void fielduses(p) Symbol p; {
	if (isstruct(p->type) && p->u.s.ftab)
		setuses(p->u.s.ftab);
}

/* findlabel - lookup/install label lab in the labels table */
Symbol findlabel(lab) {
	char *label = stringd(lab);
	Symbol p;

	if (p = lookup(label, labels[1]))
		return p;
	p = install(label, &labels[1], 0);
	p->generated = 1;
	p->u.l.label = lab;
	p->u.l.equatedto = p;
	defsymbol(p);
	return p;
}

/* findtype - find type ty in identifiers */
Symbol findtype(ty) Type ty; {
	Table tp = identifiers;
	int i;
	struct entry *p;

	assert(tp);
	do
		for (i = 0; i < HASHSIZE; i++)
			for (p = tp->buckets[i]; p; p = p->link)
				if (p->sym.type == ty && p->sym.class == TYPEDEF)
					return &p->sym;
	while (tp = tp->previous);
	return 0;
}

/* foreach - call f(p) for each entry p in table tp */
void foreach(f, tp, lev) dclproto(void (*f),(Symbol)) Table tp; {
	assert(tp);
	while (tp && tp->level > lev)
		tp = tp->previous;
	if (tp && tp->level == lev) {
		Symbol p;
		Coordinate sav;
		sav = src;
		for (p = tp->list; p && p->scope == lev; p = p->up) {
			src = p->src;
			(*f)(p);
		}
		src = sav;
	}
}

/* genident - create an identifier with class `class', type ty at scope lev */
Symbol genident(class, ty, lev) Type ty; {
	Symbol p;

	if (lev == 0)
		lev = level;
	if (lev <= PARAM)
		p = (Symbol) alloc(sizeof *p);
	else
		p = (Symbol) talloc(sizeof *p);
	BZERO(p, struct symbol);
	p->name = stringd(genlabel(1));
	p->scope = lev;
	p->class = class;
	p->type = ty;
	p->generated = 1;
	if (lev < PARAM)
		defsymbol(p);
	return p;
}

/* genlabel - generate n local labels, return first one */
int genlabel(n) {
	label += n;
	return label - n;
}

/* install - install name in table *tp; permanently allocate entry iff perm!=0 */
Symbol install(name, tp, perm) char *name; Table *tp; {
	struct entry *p;
	unsigned h = hash(name)&(HASHSIZE-1);

	if ((tp == &identifiers || tp == &types) && (*tp)->level < level)
		*tp = table(*tp, level);
	if (perm)
		p = (struct entry *) alloc(sizeof *p);
	else
		p = (struct entry *) talloc(sizeof *p);
	BZERO(&p->sym, struct symbol);
	p->sym.name = name;
	p->sym.scope = (*tp)->level;
	p->sym.up = (*tp)->list;
	(*tp)->list = &p->sym;
	p->link = (*tp)->buckets[h];
	(*tp)->buckets[h] = p;
	p->refs = 0;
	return &p->sym;
}

/* intconst - install and return integer constant n */
Symbol intconst(n) {
	Value v;

	v.i = n;
	return constant(inttype, v);
}

/* locus - append (table, cp) to the evolving loci and symbol tables lists */
void locus(tp, cp) Table tp; Coordinate *cp; {
	extern List loci, tables;

	loci = append((Generic)cp, loci);
	tables = append((Generic)tp->list, tables);
}

/* lookup - lookup name in table tp, return pointer to entry */
Symbol lookup(name, tp) char *name; Table tp; {
	register struct entry *p;
	unsigned h = hash(name)&(HASHSIZE-1);

	assert(tp);
	do
		for (p = tp->buckets[h]; p; p = p->link)
			if (name == p->sym.name)
				return &p->sym;
	while (tp = tp->previous);
	return 0;
}

/* mkstr - make a string constant */
Symbol mkstr(str) char *str; {
	Value v;
	Symbol p;

	v.p = str;
	p = constant(array(chartype, strlen(v.p) + 1, 0), v);
	if (p->u.c.loc == 0)
		p->u.c.loc = genident(STATIC, p->type, GLOBAL);
	return p;
}

/* mksymbol - make a symbol for name, install in &globals if class==EXTERN */
Symbol mksymbol(class, name, ty) char *name; Type ty; {
	Symbol p;

	if (class == EXTERN)
		p = install(string(name), &globals, 1);
	else {
		p = (Symbol)alloc(sizeof *p);
		BZERO(p, struct symbol);
		p->name = string(name);
		p->scope = GLOBAL;
	}
	p->class = class;
	p->type = ty;
	defsymbol(p);
	p->defined = 1;
	return p;
}

/* newconst - install and return constant n with type tc */
Symbol newconst(v, tc) Value v; {
	assert(tc > 0 && tc < sizeof btot/sizeof btot[0]);
	return constant(*btot[tc], v);
}

/* newtemp - back-end interface to temporary (see below) */
Symbol newtemp(class, tc) {
	Symbol t1;

	assert(tc > 0 && tc < sizeof btot/sizeof btot[0]);
	t1 = temporary(class, *btot[tc]);
	t1->scope = LOCAL;
	if (t1->defined == 0) {
		local(t1);
		t1->defined = 1;
	}
	return t1;
}

#ifdef DEBUG
/* printtable - print entries in table *tp or all tables with scope >= lev on fd */
void printtable(tp, lev, fd) Table tp; {
	if (tp == 0) {
		printtable(identifiers, lev, fd);
		printtable(externals,   lev, fd);
		printtable(types,       lev, fd);
		printtable(constants,   lev, fd);
		printtable(labels[0],   lev, fd);
		printtable(labels[1],   lev, fd);
		return;
	}
	if (tp == identifiers)
		fprint(fd, "identifiers:\n");
	else if (tp == globals)
		fprint(fd, "globals:\n");
	else if (tp == constants)
		fprint(fd, "constants:\n");
	else if (tp == externals)
		fprint(fd, "externals:\n");
	else if (tp == types)
		fprint(fd, "types:\n");
	else if (tp == labels[0])
		fprint(fd, "labels[0]:\n");
	else if (tp == labels[1])
		fprint(fd, "labels[1]:\n");
	do {
		int i;
		for (i = 0; i < HASHSIZE; i++) {
			struct entry *p;
			for (p = tp->buckets[i]; p; p = p->link)
				if (p->sym.scope >= lev)
					printsymbol(&p->sym, fd);
			}
	} while (tp = tp->previous);
}

/* printtemps - print the temp list on fd */
void printtemps(fd) {
	struct temporary *p;

	for (p = temps; p; p = p->link)
		printsymbol(p->sym, fd);
}

/* printsymbol - print symbol p on fd */
void printsymbol(p, fd) Symbol p;{
	fprint(fd, "%s", p->name);
	if (p->defined)     fprint(fd, " defined");
	if (p->temporary)   fprint(fd, " temporary");
	if (p->generated)   fprint(fd, " generated");
	if (p->computed)    fprint(fd, " computed");
	if (p->addressed)   fprint(fd, " addressed");
	if (p->initialized) fprint(fd, " initialized");
	if (p->structarg)   fprint(fd, " structarg");
	if (p->type)
		fprint(fd, " type=%t", p->type);
	if (p->class)
		fprint(fd, " class=%k", p->class);
	fprint(fd, " scope=");
	switch (p->scope) {
	case CONSTANTS: fprint(fd, "CONSTANTS");break;
	case LABELS:    fprint(fd, "LABELS");	break;
	case GLOBAL:    fprint(fd, "GLOBAL");	break;
	case PARAM:     fprint(fd, "PARAM" );	break;
	case LOCAL:     fprint(fd, "LOCAL" );	break;
	default:
		if (p->scope > LOCAL)
			fprint(fd, "LOCAL+%d", p->scope - LOCAL);
		else
			fprint(fd, "%d", p->scope);
	}
	if (p->scope >= GLOBAL)
		fprint(fd, " ref=%d", p->ref);
	fprint(fd, "\n");
}
#endif

/* release - release a temporary for re-use */
void release(t1) Symbol t1; {
	if (t1->ref) {
		struct temporary *p = (struct temporary *) talloc(sizeof *p);
		p->sym = t1;
		p->link = temps;
		temps = p;
		t1->ref = 0;
	}
}

/* rmtemps - remove temporaries at scope `level' or with `class' */
void rmtemps(class, level) {
	struct temporary *p, **q = &temps;

	for (p = *q; p; p = *q)
		if (p->sym->scope == level || p->sym->class == class)
			*q = p->link;
		else
			q = &p->link;
}

/* setuses - convert p->refs to p->uses for all p at the current level in *tp */
void setuses(tp) Table tp; {
	if (xref) {
		int i;
		struct entry *p;
		for (i = 0; i < HASHSIZE; i++)
			for (p = tp->buckets[i]; p; p = p->link) {
				if (p->refs)
					p->sym.uses = (Coordinate **)ltoa(p->refs, 0);
				p->refs = 0;
				symbols = append((Generic)&p->sym, symbols);
			}
	}
}

/* table - create a new table with predecessor tp, scope lev */
Table table(tp, lev) Table tp; {
	int i;
	Table new;

	if (lev > GLOBAL || lev == LABELS)
		new = (Table)talloc(sizeof *new);
	else
		new = (Table)alloc(sizeof *new);
	new->previous = tp;
	new->level = lev;
	new->list = tp ? tp->list : 0;
	for (i = 0; i < HASHSIZE; i++)
		new->buckets[i] = 0;
	return new;
}

/* temporary - create temporary with class `class', type ty */
Symbol temporary(class, ty) Type ty; {
	Symbol t1;
	struct temporary *p, **q = &temps;

	for (p = *q; p; q = &p->link, p = *q)
		if (p->sym->class == class && eqtype(p->sym->type, ty)) {
			*q = p->link;
			p->sym->type = ty;
			return p->sym;
		}
	t1 = genident(class, ty, 0);
	t1->temporary = 1;
	return t1;
}

/* use - add src to the list of uses for p */
void use(p, src) Symbol p; Coordinate src; {
	if (xref) {
		Coordinate *cp = (Coordinate *)alloc(sizeof *cp);
		*cp = src;
		((struct entry *)p)->refs = append((Generic)cp, ((struct entry *)p)->refs);
	}
}
