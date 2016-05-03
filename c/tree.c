/* C compiler: tree management */

#define DEBUG 1
#include "c.h"

static struct tree trees[100];	/* default allocation area for trees */
int ntree = 0;			/* next free tree in trees */

/* cvtconst - convert a constant tree into tree for a global variable */
Tree cvtconst(p) Tree p; {
	Symbol q = constant(p->type, p->u.v);
	Tree e;

	if (q->u.c.loc == 0)
		q->u.c.loc = genident(STATIC, p->type, GLOBAL);
	if (isarray(p->type)) {
		e = tree(ADDRG+P, atop(p->type), 0, 0);
		e->u.sym = q->u.c.loc;
	} else
		e = idnode(q->u.c.loc);
	return e;
}

/* genconst - generate/check constant expression e; return size */
int genconst(e, def) Tree e; {
	for (;;)
		switch (generic(e->op)) {
		case ADDRG:
			if (def)
				defaddress(e->u.sym);
			return e->type->size;
		case CNST:
			if (e->op == CNST+P && isarray(e->type)) {
				e = cvtconst(e);
				continue;
			}
			if (def)
				defconst(ttob(e->type), e->u.v);
			return e->type->size;
		case RIGHT:
			assert(e->kids[0] || e->kids[1]);
			if (e->kids[1] && e->kids[0])
				error("initializer must be constant\n");
			e = e->kids[1] ? e->kids[1] : e->kids[0];
			continue;
		case CVP:
			if (isarith(e->type))
				error("cast from `%t' to `%t' is illegal in constant expressions\n",
					e->kids[0]->type, e->type);
			/* fall thru */
		case CVC: case CVI: case CVS: case CVU:
		case CVD: case CVF:
			e = e->kids[0];
			continue;
		default:
			error("initializer must be constant\n");
			if (def)
				genconst(constnode(0, inttype), def);
			return inttype->size;
		}
}

/* hasop - does tree p contain an op? */
int hasop(p, op) Tree p; {
	if (p == 0)
		return 0;
	if (generic(p->op) == op)
		return 1;
	return hasop(p->kids[0], op) || hasop(p->kids[1], op);
}

#ifdef DEBUG
static int nid = 1;		/* identifies trees & nodes in debugging output */
static struct nodeid {
	int printed;
	Tree node;
} ids[500];			/* if ids[i].node == p, then p's id is i */

dclproto(static void printtree1,(Tree, int, int))

/* nodeid - lookup id for tree or node p */
int nodeid(p) Tree p; {
	int i = 1;

	ids[nid].node = p;
	while (ids[i].node != p)
		i++;
	if (i == nid)
		ids[nid++].printed = 0;
	return i;
}

/* opname - return string for operator op */
char *opname(op) {
	static char buf[30], types[] = TYPENAMES, *opnames[] = {
	"",
#define xxop(a,b,c,d,e,f) d,
#define yyop(a,b,c,d,e,f)
#include "ops.h"
	};
	char *s1, *s = buf;

	switch (op) {
	case AND:  return "AND";
	case NOT:  return "NOT";
	case OR:   return "OR";
	case COND: return "COND";
	case RIGHT:return "RIGHT";
	case FIELD:return "FIELD";
	}
	if (opindex(op) > 0 && opindex(op) < sizeof opnames/sizeof opnames[0])
		s1 = opnames[opindex(op)];
	else
		s1 = stringd(opindex(op));
	while (*s = *s1++)
		s++;
	if (optype(op) > 0 && optype(op) < sizeof types - 1)
		*s++ = types[optype(op)];
	else {
		*s++ ='+';
		for (s1 = stringd(optype(op)); *s = *s1++; s++)
			;
	}
	*s = 0;
	return buf;
}

/* printed - return pointer to ids[id].printed */
int *printed(id) {
	if (id)
		return &ids[id].printed;
	nid = 1;
	return 0;
}

/* printtree - print tree p on fd */
void printtree(p, fd) Tree p; {
	(void)printed(0);
	printtree1(p, fd, 1);
}

/* printtree1 - recursively print tree p */
static void printtree1(p, fd, lev) Tree p; {
	int i;
	static char blanks[] = "                                         ";

	if (p == 0 || *printed(i = nodeid(p)))
		return;
	fprint(fd, "#%d%s%s", i, &"   "[i < 10 ? 0 : i < 100 ? 1 : 2],
		 &blanks[sizeof blanks - lev]);
	fprint(fd, "%s %t", opname(p->op), p->type);
	*printed(i) = 1;
	for (i = 0; i < sizeof p->kids/sizeof p->kids[0]; i++)
		if (p->kids[i])
			fprint(fd, " #%d", nodeid(p->kids[i]));
	if (generic(p->op) == FIELD && p->u.field)
		fprint(fd, " %s %d..%d", p->u.field->name, p->u.field->from,
			p->u.field->to);
	else if (generic(p->op) == CNST)
		fprint(fd, " %s", vtoa(p->type, p->u.v));
	else if (p->u.sym)
		fprint(fd, " %s", p->u.sym->name);
	if (p->node)
		fprint(fd, " node=0x%x", p->node);
	fprint(fd, "\n");
	for (i = 0; i < sizeof p->kids/sizeof p->kids[0]; i++)
		printtree1(p->kids[i], fd, lev + 1);
}
#endif

/* retype - return a copy of tree p with type field = ty */
Tree retype(p, ty) Tree p; Type ty;{
	Tree q;

	if (p->type == ty)
		return p;
	q = tree(p->op, ty, p->kids[0], p->kids[1]);
	q->u = p->u;
	return q;
}

/* root - tree p will be a root; remove unnecessary temporaries */
Tree root(p) Tree p; {
	if (p == 0)
		return p;
	switch (generic(p->op)) {
	case COND: {
		Tree q = p->kids[1];
		assert(q && q->op == RIGHT);
		if (p->u.sym && q->kids[0] && generic(q->kids[0]->op) == ASGN)
			q->kids[0] = root(q->kids[0]->kids[1]);
		else
			q->kids[0] = root(q->kids[0]);
		if (p->u.sym && q->kids[1] && generic(q->kids[1]->op) == ASGN)
			q->kids[1] = root(q->kids[1]->kids[1]);
		else
			q->kids[1] = root(q->kids[1]);
		if (p->u.sym)
			release(p->u.sym);
		p->u.sym = 0;
		if (q->kids[0] == 0 && q->kids[1] == 0)
			p = root(p->kids[0]);
		}
		break;
	case AND: case OR:
		if ((p->kids[1] = root(p->kids[1])) == 0)
			p = root(p->kids[0]);
		break;
	case NOT:
		return root(p->kids[0]);
	case RIGHT:
		if (p->kids[1] == 0)
			return root(p->kids[0]);
		if (p->kids[0] && p->kids[0]->op == CALL+B
		&&  p->kids[1] && p->kids[1]->op == INDIR+B)
			/* avoid premature release of the CALL+B temporary */
			return p->kids[0];
		if (p->kids[0] && p->kids[0]->op == RIGHT
		&&  p->kids[1] == p->kids[0]->kids[0])
			/* de-construct e++ construction */
			return p->kids[0]->kids[1];
		/* fall thru */
	case EQ:  case NE:  case GT:   case GE:  case LE:  case LT: 
	case ADD: case SUB: case MUL:  case DIV: case MOD:
	case LSH: case RSH: case BAND: case BOR: case BXOR:
		p = tree(RIGHT, p->type, root(p->kids[0]), root(p->kids[1]));
		return p->kids[0] || p->kids[1] ? p : 0;
	case INDIR:
		if (isptr(p->kids[0]->type) && isvolatile(p->kids[0]->type->type))
			warning("reference to `volatile %t' elided\n", p->type);
		/* fall thru */
	case CVI: case CVF:  case CVD:   case CVU: case CVC: case CVS: case CVP:
	case NEG: case BCOM: case FIELD:
		return root(p->kids[0]);
	case ADDRL:
		if (p->u.sym->temporary)
			release(p->u.sym);
		/* fall thru */
	case ADDRG: case ADDRF: case CNST:
		return 0;
	case ARG: case ASGN: case CALL: case JUMP: case LABEL:
		break;
	default: assert(0);
	}
	return p;
}

/* texpr - parse an expression via f(tok), allocating trees in transient area */
Tree texpr(f, tok) dclproto(Tree (*f),(int)) {
	int n = ntree;
	Tree p;

	ntree = sizeof trees/sizeof trees[0];
	p = (*f)(tok);
	ntree = n;
	return p;
}

/* tfree - release space in all transient arenas and default tree area */
void tfree() {
	if (glevel < 3 && !xref)
		deallocate(&transient);
	ntree = 0;
}

/* tree - allocate and initialize a tree node */
Tree tree(op, type, left, right) Type type; Tree left, right; {
	register Tree p;

	if (ntree < sizeof trees/sizeof trees[0])
		p = &trees[ntree++];
	else
		p = (Tree)talloc(sizeof *p);
	p->op = op;
	p->type = type;
	p->kids[0] = left;
	p->kids[1] = right;
	p->node = 0;
	p->u.sym = 0;
	return p;
}
