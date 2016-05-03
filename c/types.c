/* C compiler: type handling */
#define DEBUG 1
#include "c.h"

/* include globals */
Type chartype;			/* char */
Type doubletype;		/* double */
Type floattype;			/* float */
Type inttype;			/* signed int */
Type longdouble;		/* long double */
Type longtype;			/* long */
Type shorttype;			/* signed short int */
Type signedchar;		/* signed char */
Type unsignedchar;		/* unsigned char */
Type unsignedlong;		/* unsigned long int */
Type unsignedshort;		/* unsigned short int */
Type unsignedtype;		/* unsigned int */
Type voidptype;			/* void* */
Type voidtype;			/* basic types: void */
/* end globals */

static Symbol pointersym;	/* symbol for pointer types */
static Symbol stringsym;	/* symbol for character array types */
static struct type {		/* type list entries: */
	struct tynode type;		/* the type */
	struct type *link;		/* next type on the hash chain */
} *typetable[32];		/* current set of types */
static int maxlevel;		/* maximum scope level of entries in typetable */ 

dclproto(static Field check,(Type, Type, Field, int))
dclproto(static Field isfield,(char *, Field))
dclproto(static Type tynode,(int, Type, int, int, Symbol))

#define VOID_METRICS 0,0,0

/* typeInit - initialize basic types */
void typeInit() {
#define xx(v,name,op,metrics) { Symbol p = install(string(name), &types, 1); \
	v = p->type = tynode(op, 0, metrics+1?p:0); p->addressed = (metrics); \
	assert(v->align == 0 || v->size%v->align == 0); }
	xx(chartype,	  "char",		CHAR,	  CHAR_METRICS);
	xx(doubletype,	  "double",		DOUBLE,	  DOUBLE_METRICS);
	xx(floattype,	  "float",		FLOAT,	  FLOAT_METRICS);
	xx(inttype,	  "int",		INT,	  INT_METRICS);
	xx(longdouble,	  "long double",	DOUBLE,	  DOUBLE_METRICS);
	xx(longtype,	  "long int",		INT,	  INT_METRICS);
	xx(shorttype,	  "short",		SHORT,	  SHORT_METRICS);
	xx(signedchar,	  "signed char",	CHAR,	  CHAR_METRICS);
	xx(unsignedchar,  "unsigned char",	CHAR,	  CHAR_METRICS);
	xx(unsignedlong,  "unsigned long int",	UNSIGNED, INT_METRICS);
	xx(unsignedshort, "unsigned short int",	SHORT,	  SHORT_METRICS);
	xx(unsignedtype,  "unsigned int",	UNSIGNED, INT_METRICS);
	xx(voidtype,	  "void",		VOID,	  VOID_METRICS);
#undef xx

#define xx(v,name,adr) v = install(string(name), &types, 1); v->addressed = (adr);
	xx(stringsym,	"char[]",1);
	xx(pointersym,	"T*",	 POINTER_METRICS);
#undef xx

	voidptype = ptr(voidtype);
	assert(voidptype->align > 0 && voidptype->size%voidptype->align == 0);
	assert(unsignedtype->size >= voidptype->size);
}

/* array - construct the type `array 0..n-1 of ty' with alignment a or ty's */
Type array(ty, n, a) Type ty; {
	if (ty && isfunc(ty)) {
		error("illegal type `array of %t'\n", ty);
		return array(inttype, n, 0);
	}
	if (a == 0)
		a = ty->align;
	if (ischar(ty))
		return tynode(ARRAY, ty, n*chartype->size, a, stringsym);
	if (level > GLOBAL && isarray(ty) && ty->size == 0)
		error("missing array size\n");
	if (ty->size && n > INT_MAX/ty->size) {
		error("size of `array of %t' exceeds %d bytes\n", ty, INT_MAX);
		return tynode(ARRAY, ty, ty->size, a, ty->sym);
	};
	return tynode(ARRAY, ty, n*ty->size, a, ty->sym);
}

/* atop - convert ty from `array of ty' to `pointer to ty' */
Type atop(ty) Type ty; {
	if (isarray(ty))
		return ptr(ty->type);
	error("type error: %s\n", "array expected");
	return ptr(ty);
}

/* check - check ty for ambiguous inherited fields, return augmented field set */
static Field check(ty, top, inherited, off) Type ty, top; Field inherited; {
	Field p;

	for (p = ty->sym->u.s.flist; p; p = p->link)
		if (p->name && isfield(p->name, inherited))
			error("ambiguous field `%s' of `%t' from `%t'\n", p->name, top, ty);
		else if (p->name && !isfield(p->name, top->sym->u.s.flist)) {
			Field new = (Field) talloc(sizeof *new);
			*new = *p;
			new->offset = off + p->offset;
			new->link = inherited;
			inherited = new;
		}
	for (p = ty->sym->u.s.flist; p; p = p->link)
		if (p->name == 0)
			inherited = check(p->type, top, inherited,
				off + p->offset);
	return inherited;
}

/* checkfields - check for ambiguous inherited fields in struct/union ty */
void checkfields(ty) Type ty; {
	Field p, inherited = 0;

	for (p = ty->sym->u.s.flist; p; p = p->link)
		if (p->name == 0)
			inherited = check(p->type, ty, inherited, p->offset);
}

/* checkproto - check for function types with extraneous parameters */
void checkproto(ty) Type ty; {
	while (ty)
		switch (ty->op) {
		case FUNCTION: {
			Symbol p = ty->sym;
			if (p && p->type == 0) {
				error("extraneous formal parameter specification\n");
				ty->sym = 0;
			} else
				for ( ; p; p = p->u.proto)
					checkproto(p->type);
			}
			/* fall thru */
		case CONST: case VOLATILE: case CONST+VOLATILE:
		case POINTER: case ARRAY:
			ty = ty->type;
			break;
		default:
			return;
		}
}

/* composite - return the composite type of ty1 & ty2, or 0 if ty1 & ty2 are incompatible */
Type composite(ty1, ty2) Type ty1, ty2; {
	if (ty1 == ty2)
		return ty1;
	if (ty1->op != ty2->op)
		return 0;
	switch (ty1->op) {
	case CONST+VOLATILE:
		return qual(CONST, qual(VOLATILE, composite(ty1->type, ty2->type)));
	case CONST: case VOLATILE:
		return qual(ty1->op, composite(ty1->type, ty2->type));
	case POINTER:
		return ptr(composite(ty1->type, ty2->type));
	case ARRAY: {
		Type ty;
		if (ty = composite(ty1->type, ty2->type)) {
			if (ty1->size && ty1->type->size && ty2->size == 0)
				return array(ty, ty1->size/ty1->type->size, ty1->align);
			if (ty2->size && ty2->type->size && ty1->size == 0)
				return array(ty, ty2->size/ty2->type->size, ty2->align);
			return array(ty, 0, 0);
		}
		break;
		}
	case FUNCTION: {
		Type ty;
		if (ty = composite(ty1->type, ty2->type)) {
			Symbol p, *q, p1, p2;
			if (ty1->sym && ty2->sym == 0)
				return func(ty, ty1->sym);
			if (ty2->sym && ty1->sym == 0)
				return func(ty, ty2->sym);
			q = &p;
			for (p1 = ty1->sym, p2 = ty2->sym; p1 && p2; p1 = p1->u.proto, p2 = p2->u.proto) {
				*q = (Symbol)alloc(sizeof **q);
				BZERO(*q, struct symbol);
				**q = *p1;
				if (((*q)->type = composite(p1->type, p2->type)) == 0)
					return 0;
				q = &(*q)->u.proto;
			}
			*q = 0;
			return p1 == 0 && p2 == 0 ? func(ty, p) : 0;
		}
		break;
		}
	case CHAR:   case SHORT: case INT:     case DOUBLE:
	case VOID:   case FLOAT: case UNSIGNED:
	case STRUCT: case UNION: case ENUM:
		break;
	default:
		assert(0);
	}
	return 0;
}

/* deftype - define name to be equivalent to type ty */
Symbol deftype(name, ty, pos) char *name; Type ty; Coordinate *pos; {
	Symbol p = lookup(name, identifiers);

	if (p && p->scope == level)
		error("redeclaration of `%s'\n", name);
	p = install(name, &identifiers, level < LOCAL);
	p->type = ty;
	p->class = TYPEDEF;
	p->src = *pos;
	return p;
}

/* deref - dereference ty, type *ty */
Type deref(ty) Type ty; {
	if (isptr(ty))
		ty = ty->type;
	else
		error("type error: %s\n", "pointer expected");
	return isenum(ty) ? ty->type : ty;
}

/* eqtype - is ty1==ty2?  handles arrays & functions */
int eqtype(ty1, ty2) Type ty1, ty2; {
	if (ty1 == ty2)
		return 1;
	if (ty1->op != ty2->op)
		return 0;
	switch (ty1->op) {
	case CONST: case VOLATILE: case CONST+VOLATILE: case POINTER:
		return eqtype(ty1->type, ty2->type);
	case ARRAY:
		if (eqtype(ty1->type, ty2->type)
		&& (ty1->size == ty2->size || ty1->size == 0 && ty2->size
		||  ty1->size && ty2->size == 0))
			return 1;
		break;
	case FUNCTION:
		if (eqtype(ty1->type, ty2->type)) {
			Symbol p1 = ty1->sym, p2 = ty2->sym;
			if (p1 == p2)
				return 1;
			if (p1 == 0 || p2 == 0) {
				if (p1 == 0) {
					ty1 = ty2;
					p1 = p2;
				}
				for ( ; p1; p1 = p1->u.proto) {
					Type ty = unqual(p1->type);
					if (promote(ty) != ty || ty == floattype
					|| ty == voidtype && p1 != ty1->sym)
						return 0;
				}
				return 1;
			}
			for ( ; p1 && p2; p1 = p1->u.proto, p2 = p2->u.proto)
/*				if (eqtype(unqual(p1->type), unqual(p2->type)) == 0) */
				if (eqtype(p1->type, p2->type) == 0)
					return 0;
			if (p1 == p2)
				return 1;
		}
		break;
	case CHAR:   case SHORT: case INT:     case DOUBLE:
	case VOID:   case FLOAT: case UNSIGNED:
	case STRUCT: case UNION: case ENUM:
		break;
	default:
		assert(0);
	}
	return 0;
}

/* extends - if ty extends fty, return a pointer to field structure */
Field extends(ty, fty) Type ty, fty; {
	Field p, q;

	for (p = unqual(ty)->sym->u.s.flist; p; p = p->link)
		if (p->name == 0 && unqual(p->type) == unqual(fty))
			return p;
		else if (p->name == 0 && (q = extends(p->type, fty))) {
			static struct field f;
			f = *q;
			f.offset = p->offset + q->offset;
			return &f;
		}
	return 0;
}

/* fieldlist - construct a flat list of fields in type ty */
Field fieldlist(ty) Type ty; {
	Field p, q, t, inherited = 0, *r;

	ty = unqual(ty);
	for (p = ty->sym->u.s.flist; p; p = p->link)
		if (p->name == 0)
			inherited = check(p->type, ty, inherited, p->offset);
	if (inherited == 0)
		return ty->sym->u.s.flist;
	for (q = 0, p = inherited; p; q = p, p = t) {
		t = p->link;
		p->link = q;
	}
	for (r = &inherited, p = ty->sym->u.s.flist; p && q; )
		if (p->name == 0)
			p = p->link;
		else if (p->offset <= q->offset) {
			*r = (Field) talloc(sizeof **r);
			**r = *p;
			r = &(*r)->link;
			p = p->link;
		} else {
			*r = q;
			r = &q->link;
			q = q->link;
		}
	for ( ; p; p = p->link)
		if (p->name) {
			*r = (Field) talloc(sizeof **r);
			**r = *p;
			r = &(*r)->link;
		}
	*r = q;
	return inherited;
}

/* fieldref - find field name of type ty, return entry */
Field fieldref(name, ty) char *name; Type ty; {
	Field p;

	if (p = isfield(name, unqual(ty)->sym->u.s.flist)) {
		if (xref) {
			Symbol q;
			assert(unqual(ty)->sym->u.s.ftab);
			q = lookup(name, unqual(ty)->sym->u.s.ftab);
			assert(q);
			use(q, src);
		}
		return p;
	}
	for (p = unqual(ty)->sym->u.s.flist; p; p = p->link) {
		Field q;
		if (p->name == 0 && (q = fieldref(name, p->type))) {
			static struct field f;
			f = *q;
			f.offset = p->offset + q->offset;
			return &f;
		}
	}
	return 0;
}

/* freturn - for `function returning ty', return ty */
Type freturn(ty) Type ty; {
	if (isfunc(ty))
		return ty->type;
	error("type error: %s\n", "function expected");
	return inttype;
}

/* func - construct the type `function (proto) returning ty' */
Type func(ty, proto) Type ty; Symbol proto; {
	if (ty && (isarray(ty) || isfunc(ty)))
		error("illegal return type `%t'\n", ty);
	return tynode(FUNCTION, ty, 0, 0, proto);
}

/* hasproto - true iff ty has no function types or they all have prototypes */
int hasproto(ty) Type ty; {
	if (Aflag < 1 || ty == 0)
		return 1;
	switch (ty->op) {
	case CONST: case VOLATILE: case CONST+VOLATILE: case POINTER:
	case ARRAY:
		return hasproto(ty->type);
	case FUNCTION:
		return hasproto(ty->type) && ty->sym && ty->sym->type;
	case STRUCT: case UNION:
	case CHAR:   case SHORT: case INT:  case DOUBLE:
	case VOID:   case FLOAT: case ENUM: case UNSIGNED:
		return 1;
	default:
		assert(0);
	}
	return 0;
}

/* isfield - if name is a field in flist, return pointer to the field structure */
static Field isfield(name, flist) char *name; Field flist; {
	for ( ; flist; flist = flist->link)
		if (flist->name == name)
			break;
	return flist;
}

/* newfield - install a new field in ty with type fty */
Field newfield(name, ty, fty) char *name; Type ty, fty; {
	Field p, *q = &ty->sym->u.s.flist;
	static struct field z;

	if (name == 0)
		name = stringd(genlabel(1));
	for (p = *q; p; q = &p->link, p = *q)
		if (p->name == name)
			error("duplicate field name `%s' in `%t'\n", name, ty);
	p = (Field)alloc(sizeof *p);
	*q = p;
	*p = z;
	p->name = name;
	p->type = fty;
	if (xref) {
		if (ty->sym->u.s.ftab == 0)
			ty->sym->u.s.ftab = table(0, level);
		install(name, &ty->sym->u.s.ftab, 1)->src = src;
	}
	return p;
}

/* newstruct - install a new structure/union/enum depending on op */
Type newstruct(op, tag) char *tag; {
	Symbol p;

	if (!tag || *tag == '\0')  /* anonymous structure/union/enum */
		tag = stringd(genlabel(1));
	if ((p = lookup(tag, types)) && p->scope == level) {
		if (p->type->op == op && !p->defined)
			return p->type;
		error("redeclaration of `%s'\n", tag);
	}
	p = install(tag, &types, 1);
	p->type = tynode(op, 0, 0, 0, p);
	p->src = src;
	return p->type;
}

/* outtype - output type ty */
void outtype(ty) Type ty; {
	switch (ty->op) {
	case CONST+VOLATILE:
		print("%k %k %t", CONST, VOLATILE, ty->type);
		break;
	case CONST: case VOLATILE:
		print("%k %t", ty->op, ty->type);
		break;
	case STRUCT: case UNION: case ENUM:
		assert(ty->sym);
		if (ty->size == 0)
			print("incomplete ");
		assert(ty->sym->name);
		if (*ty->sym->name >= '1' && *ty->sym->name <= '9') {
			Symbol p = findtype(ty);
			if (p == 0)
				print("%k defined at %w", ty->op, &ty->sym->src);
			else
				print(p->name);
		} else {
			print("%k %s", ty->op, ty->sym->name);
			if (ty->size == 0)
				print(" defined at %w", &ty->sym->src);
		}
		break;
	case VOID: case FLOAT: case DOUBLE:
	case CHAR: case SHORT: case INT: case UNSIGNED:
		print(ty->sym->name);
		break;
	case POINTER:
		print("pointer to %t", ty->type);
		break;
	case FUNCTION:
		print("%t function", ty->type);
		if (ty->sym) {
			Symbol p = ty->sym->u.proto;
			print("(%t", ty->sym->type);
			for ( ; p; p = p->u.proto)
				if (p->type == voidtype)
					print(",...");
				else
					print(",%t", p->type);
			print(")");
		}
		break;
	case ARRAY:
		if (ty->size > 0 && ty->type && ty->type->size > 0) {
			print("array %d", ty->size/ty->type->size);
			while (ty->type && isarray(ty->type) && ty->type->type->size > 0) {
				ty = ty->type;
				print(",%d", ty->size/ty->type->size);
			}
		} else
			print("incomplete array");
		if (ty->type)
			print(" of %t", ty->type);
		break;
	default:
		assert(0);
	}
}

/* printdecl - output a C declaration for symbol p of type ty */
void printdecl(p, ty) Symbol p; Type ty; {
	switch (p->class) {
	case AUTO:
		fprint(2, "%s;\n", typestring(ty, p->name));
		break;
	case STATIC: case EXTERN:
		fprint(2, "%k %s;\n", p->class, typestring(ty, p->name));
	case TYPEDEF: case ENUM:
		break;
	default:
		assert(0);
	}
}

/* printproto - output a prototype declaration for function p */
void printproto(p, callee) Symbol p, callee[]; {
	struct symbol arg, *q;

	if (p->type->sym)
		q = p->type->sym;
	else if (callee[0] == 0) {
		arg.class = AUTO;
		arg.name = "";
		arg.type = voidtype;
		arg.u.proto = 0;
		q = &arg;
	} else {
		int i;
		for (i = 0; callee[i]; i++)
			callee[i]->u.proto = callee[i+1];
		q = callee[0];
	}
	printdecl(p, func(freturn(p->type), q));
}

#ifdef DEBUG
/* printtype - print details of type ty on fd */
void printtype(ty, fd) Type ty; {
	switch (ty->op) {
	case STRUCT: case UNION: {
		Field p;
		fprint(fd, "%k %s size=%d {\n", ty->op, ty->sym->name, ty->size);
		for (p = ty->sym->u.s.flist; p; p = p->link) {
			fprint(fd, "field %s: offset=%d", p->name, p->offset);
			if (p->to)
				fprint(fd, " bits=%d..%d", p->from, p->to);
			fprint(fd, " type=%t", p->type);
		}
		fprint(fd, "}\n");
		break;
		}
	case ENUM: {
		int i;
		Symbol p;
		fprint(fd, "enum %s {", ty->sym->name);
		for (i = 0; p = ty->sym->u.idlist[i]; i++) {
			if (i > 0)
				fprint(fd, ",");
			fprint(fd, "%s=%d", p->name, p->u.value);
		}
		fprint(fd, "}\n");
		break;
		}
	default:
		fprint(fd, "%t\n", ty);
	}
}
#endif

/* ptr - construct the type `pointer to ty' */
Type ptr(ty) Type ty; {
	return tynode(POINTER, ty, POINTER_METRICS+1?pointersym:0);
}

/* qual - construct the type `op ty' where op is CONST or VOLATILE */
Type qual(op, ty) Type ty; {
	if (isarray(ty))
		ty = tynode(ARRAY, qual(op, ty->type), ty->size,
			ty->align, 0);
	else if (isfunc(ty))
		warning("qualified function type ignored\n");
	else if (isconst(ty) && op == CONST || isvolatile(ty) && op == VOLATILE)
		error("illegal type `%k %t'\n", op, ty);
	else {
		int i;
		struct type *tn;
		if (isqual(ty)) {
			op += ty->op;
			ty = ty->type;
		}
		for (i = 0; i < sizeof typetable/sizeof typetable[0]; i++)
			for (tn = typetable[i]; tn; tn = tn->link)
				if (tn->type.op == op && tn->type.type == ty) {
					tn->type.size = ty->size;
					tn->type.align = ty->align;
					return &tn->type;
				}
		return tynode(op, ty, ty->size, ty->align, 0);
	}
	return ty;
}

/* rmtypes - remove type nodes at the current scope level */
void rmtypes() {
	if (maxlevel >= level) {
		int i;
		maxlevel = 0;
		for (i = 0; i < sizeof typetable/sizeof typetable[0]; i++) {
			struct type *tn, **tq = &typetable[i];
			for (tn = *tq; tn; tn = *tq)
				if (tn->type.sym && tn->type.sym->scope == level)
					*tq = tn->link;
				else {
					if (tn->type.sym && tn->type.sym->scope > maxlevel)
						maxlevel = tn->type.sym->scope;
					tq = &tn->link;
				}
		}
	}
}

/* ttob - map arbitrary type ty to integer basic type */
int ttob(ty) Type ty; {
	switch (ty->op) {
	case CONST: case VOLATILE: case CONST+VOLATILE:
		return ttob(ty->type);
	case VOID: case CHAR: case INT: case SHORT:
	case UNSIGNED: case FLOAT: case DOUBLE:
		return ty->op;
	case POINTER: case FUNCTION:
		return POINTER;
	case ARRAY: case STRUCT: case UNION:
		return STRUCT;
	case ENUM:
		return INT;
	default:
		assert(0);
	}
	return I;
}

/* tynode - allocate and initialize a type node */
static Type tynode(op, type, size, align, sym) Type type; Symbol sym; {
	int i = (opindex(op)^((unsigned)type>>2))&(sizeof typetable/sizeof typetable[0]-1);
	struct type *tn;

	if (op != ARRAY || size > 0)
		for (tn = typetable[i]; tn; tn = tn->link)
			if (tn->type.op   == op   && tn->type.type  == type
			&&  tn->type.size == size && tn->type.align == align
			&&  tn->type.sym  == sym)
				return &tn->type;
	tn = (struct type *) alloc(sizeof *tn);
	tn->type.op = op;
	tn->type.type = type;
	tn->type.size = size;
	tn->type.align = align;
	BZERO((&tn->type.x), Xtype);
	if ((tn->type.sym = sym) && op != FUNCTION && sym->scope > maxlevel)
		maxlevel = sym->scope;
	tn->link = typetable[i];
	typetable[i] = tn;
	return &tn->type;
}

/* typestring - return ty as C declaration for str, which may be "" */
char *typestring(ty, str) Type ty; char *str; {
	for ( ; ty; ty = ty->type) {
		Symbol p;
		switch (ty->op) {
		case CONST+VOLATILE:
			if (isptr(ty->type))
				str = stringf("%k %k %s", CONST, VOLATILE, str);
			else
				return stringf("%k %k %s", CONST, VOLATILE, typestring(ty->type, str));
			break;
		case CONST: case VOLATILE:
			if (isptr(ty->type))
				str = stringf("%k %s", ty->op, str);
			else
				return stringf("%k %s", ty->op, typestring(ty->type, str));
			break;
		case STRUCT: case UNION: case ENUM:
			assert(ty->sym);
			if (p = findtype(ty))
				return *str ? stringf("%s %s", p->name, str) : p->name;
			if (*ty->sym->name >= '1' && *ty->sym->name <= '9')
				warning("unnamed %k in prototype\n", ty->op);
			if (*str)
				return stringf("%k %s %s", ty->op, ty->sym->name, str);
			else
				return stringf("%k %s", ty->op, ty->sym->name);
		case VOID: case FLOAT: case DOUBLE:
		case CHAR: case SHORT: case INT: case UNSIGNED:
			return *str ? stringf("%s %s", ty->sym->name, str) : ty->sym->name;
		case POINTER:
			if (unqual(ty->type)->op != CHAR && (p = findtype(ty)))
				return *str ? stringf("%s %s", p->name, str) : p->name;
			str = stringf(isarray(ty->type) || isfunc(ty->type) ? "(*%s)" : "*%s", str);
			break;
		case FUNCTION:
			if (p = findtype(ty))
				return *str ? stringf("%s %s", p->name, str) : p->name;
			if (ty->sym == 0)
				str = stringf("%s()", str);
			else {
				str = stringf("%s(%s", str, typestring(ty->sym->type, ""));
				for (p = ty->sym->u.proto; p; p = p->u.proto)
					if (p->type == voidtype)
						str = stringf("%s, ...", str);
					else
						str = stringf("%s, %s", str, typestring(p->type, ""));
				str = stringf("%s)", str);
			}
			break;
		case ARRAY:
			if (p = findtype(ty))
				return *str ? stringf("%s %s", p->name, str) : p->name;
			if (ty->type && ty->type->size > 0)
				str = stringf("%s[%d]", str, ty->size/ty->type->size);
			else
				str = stringf("%s[]", str);
			break;
		default:
			assert(0);
		}
	}
	assert(0);
	return 0;
}

/* variadic - is function type ty variadic? */
int variadic(ty) Type ty; {
	Symbol p;

	if (isfunc(ty) && (p = ty->sym)) {
		while (p->u.proto)
			p = p->u.proto;
		return p != ty->sym && p->type == voidtype;
	}
	return 0;
}
