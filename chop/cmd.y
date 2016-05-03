%{
/*	machine description processor.			*/

/*	Read a machine description and provide bidirectional translator
 *	between register transfers and assembly language syntax.
 *
 *	Uses Yacc to read in the machine description, and a modified
 *	Earley parsing algorithm to do the translation.
 *
 *	abbreviations:  {lr}hs: {left,right} hand side
 *			nt: nonterminal
 *			pn: production
 *			rt: register transfer
 *			md: machine description
 */

#include <ctype.h>
#include <stdio.h>
#include "c.h"
#include "hop2.h"
#include "md.h"

#define STATEHASH 2003
#define MAXSTATES	500
#define MAXDIGITS 12 /* maximum number of digits in a # */

/*	set of states list pointers.	*/
struct State   *heads[MAXSTATES], *tails[MAXSTATES], **hashheads[MAXSTATES];

char           *terminals[100];
struct State   *bog;
struct State   *translate(), *trans2(), *parse(), *parse2(), *addvar();
struct State   *addterm(), *remainder(), *transgram();
static char	*stalloc();

#define BOG { printf("at %d:\n", __LINE__); \
      if (bog && (struct State *)(memx+mem-100)>=bog) dumpstate(bog,0); }

static int      side;		/* 0 = assem 1 = rt		 */
char		*epsilon;	/* the empty string		 */
char		*phistring;	/* grammar start symbol "$PHI$"	 */
char		*rangestr;	/* "%range"			 */
char		*termstr;	/* "%term"			 */
static          scanstring(), scannumber(), zzerror();
struct Pn      *pns[MAXNTS];	/* set of pns for each nt	 */
static long	maxmemx;	/* hi-water mark */
static long	memx;
int 		Statesfree;
int		MaxStatesfree;
int             current;	/* current state set number	 */
int		maxfreevars;
#if 0
int             flag;		/* used to distinguish par and par1 */
#endif
static char    *globline;
static int      globlen;

static unsigned long semantics();

/*  Maximum number of %type declarations allowed in machine description */
#define MAXTYPE	40
short	ntypes = 0;
struct Type {
    char	*name;		/* type's name e.g. "l" */
    unsigned long type_bits;	/* type bits to be intersected */
    } md_types[MAXTYPE];

static char    *ts[] = {"NONTERM", "RANGE", "VAR", "TERM", "UNKNOWN"};

static void dumpsets()		/* dump all sets of states	 */
    {
    int             n;
    printf("sets for input '%s':\n", globline);

    for (n = 0; n <= current; n++) {
	printf("\n\nSET %d:  ", n);
	printf("'%.*s ^ %s'\n", n, globline, n + globline);
	dumpset(n);
	}
    printf("\n");
    }

struct State   *Statehead = NULL;
#define trace_Statealloc 0
struct State   *Statealloc()
    {
    struct State   *s;
#if trace_Statealloc
    printf("Statealloc(), Statehead = %d\n", Statehead);
#endif
    if (Statehead == NULL) {
#if trace_Statealloc
	printf("Statealloc(), grabs from stalloc\n");
	printf("memx %d maxmemx %d\n", memx, maxmemx);
#endif
	s = (struct State *) stalloc((unsigned) sizeof(struct State));
#if trace_Statealloc
	printf("memx %d maxmemx %d\n", memx, maxmemx);
#endif
	}
    else {
#if trace_Statealloc
	printf("Statealloc(), grabs Statehead\n");
#endif
	Statesfree--;
	s = Statehead;
	Statehead = Statehead->next;
	}
#if trace_Statealloc
    printf("Statealloc(), returns %d\n", s);
#endif
    s->trans = NULL;
    return s;
    }

struct State   *Statefree(s)
    struct State   *s;
    {
    struct State   *n;
    n = s->next;
    s->next = Statehead;
    if (++Statesfree > MaxStatesfree) {
	MaxStatesfree = Statesfree;
	}
    Statehead = s;
    return n;
    }

struct State   *leftStatefree(s)
    struct State   *s;
    {
    struct State   *next = s->next;
    if (s->left)
	leftStatefree(s->left);
    return Statefree(s);
    }

#define MAXMEM 32000L
static char	*banks[200];
static int	nbanks = 0;

static char	*stalloc(n)		/* allocate memory */
    unsigned	n;
    {
    long	result;

    retry:

    memx += sizeof(double) - 1;		/* align */
    memx &= ~(sizeof(double) - 1);
    result = memx;
    memx += n;
    if (nbanks == 0 || memx > MAXMEM) {
	nbanks++;
	if (nbanks > nelts(banks)) {
	    fprintf(stderr, "no memory in stalloc(%d)\n", n);
	    dumpsets();
	    exit(1);
	    }
	memx = 0;
	if (banks[nbanks - 1] == NULL) {
	    banks[nbanks - 1] = sbrk((int)MAXMEM);
	    maxmemx = nbanks * MAXMEM;
	    }
	goto retry;
	}
    return banks[nbanks - 1]+result;
    }


/*   Copy a string into the translator's private memory pool.  This
 *   pool is reset when a new translation is begun.
 */
char *cmdstring(s)			/* copy a string by allocing it */
    char           *s;
    {
    char           *result;
    result = stalloc((unsigned) (strlen(s) + 1));
    strcpy(result, s);
    return result;
    }

/*  The following contain translations for nonterminals that we've already */
/*  translated, so that when we are expanding all alternatives for some    */
/*  nonterminal that appears twice on the right-hand side, we expand it    */
/*  the same both times.                                                   */
struct Toklist *tokens[40];
char           *begtrans[40];	/* pt to first char in trans of tk	 */
char           *endtrans[40];	/* follows last char			 */
struct Toklist  defs[MAXNTS];	/* names of ranges, terms, and nonterms	 */
				 /* (next field not used)		 */
char		refs[MAXNTS];	/* Has this token been used?		*/

struct Toklist *firsts[MAXNTS][2];	/* first sets for each nt	 */

FILE           *mdfile;		/* machine description file	 */


#define isterminal(x) ((x)->tokty == TERMINAL)
#define termtext(x) ((x)->text)
#define termlen(x)  (strlen((x)->text))

int             maxstate;	/* maximum set of states with contents	 */

static void     addstate();
dumppn(pn, dot, pnside)
    struct Pn      *pn;
    struct Toklist *dot;
    {
    struct Toklist *e;
    printf("%s -> ", defs[pn->lhn].text);
    for (e = pn->rhs[pnside];; e = e->next) {
	if (dot == e)
	    printf(" . ");
	else
	    printf(" ");
	if (e == 0)
	    break;
	printf("%c", ":-%\"?"[(int) e->tokty]);
	if (e->tokty == NONTERM) {
	    printf("%c", "-<>"[e->tkclass]);
	    }
	printf("%s", e->text);
	if (e->tokty == TERMINAL)
	    putchar('"');
	}
    }

dumpstate(s, indent)		/* dump a parse state	 */
    struct State   *s;
    {
    int             locv;
    for (locv = 0; locv < indent; locv++)
	putchar(' ');

    printf("sp %d init %d left %d next %d dot %d\n", s, s->init,
	   s->left, s->next, s->dot);

    for (locv = 0; locv < indent; locv++)
	putchar(' ');
    if (s->left) {
	if (!s->left->dot)
	    printf("s->left->dot NIL\n");
	else if (s->left->dot->tokty == NONTERM)
	    printf("kid %d ", s->vk.kid);
	else if (s->left->dot->tokty != TERMINAL)
	    printf("var %s ", s->vk.var);
	}
    printf("cost %f pn %d\n", (double) s->pn->cost, s->pn);

    for (locv = 0; locv < indent; locv++)
	putchar(' ');
    printf("adder %s types %o ", s->adder, s->types);
    if (s->trans)
	printf("trans '%s' ", s->trans);
    printf("\n");
    for (locv = 0; locv < indent; locv++)
	putchar(' ');
    printf("type_bits %o cost %f allocl %d\n",
        s->pn->type_bits, (double)s->pn->cost, s->pn->allocl);
    dumppn(s->pn, s->dot, side);
    printf("; %s ", s->look);
    for (locv = 0; locv < MAXGLOBALS + MAXFREENONTERMS; locv++) {
	if (s->constraints[locv]) {
	    printf(VARFMT, locv);
	    printf("=%s ", s->constraints[locv]);
	    }
	}
    printf("\n\n");
    fflush(stdout);
    }

/*  Make this string into a token.  If tokty != UNKNOWN, we know what
 *  the token type is.
 */
struct Toklist *mktok(x, tokty)
    char	*x;
    short	tokty;
    {
    struct Toklist *result;
    int		n;

    /* always make a new token because we are going to link it into */
    /* a chain in the production */
    result = get(struct Toklist);

    result->tokty = tokty;
    result->next = NULL;
    result->text = string(x);

    /* If not a TERMINAL or UNKNOWN install it. */
    if (tokty != TERMINAL && tokty != UNKNOWN) {
	n = ntlook(x, tokty);
	if (n < 0 || MAXNTS <= n) {
	    fprintf(stderr, "subscript error in mktok\n");
	    exit(-1);
	    }
	*result = defs[ntlook(x, tokty)];
	}

    return result;
    }

/*  Look up and install the name of a range, nonterminal, or term.
 *  If the input token type is not UNKNOWN, install the token if it
 *  does not already reside in the defs vector.
 *  Return index in defs vector or -1 for UNKNOWN token types which
 *  were not found.
 */
ntlook(nt, tokty)		/* look up or install a range,	 */
    register char  *nt;		/* nonterminal, or term		 */
    short	tokty;		/* return index in defs vector	 */
    {
    register int    i;
    register unsigned sum = 0;
    static int      totalnts;	/* # of nts in the table	 */
    for (i = 0; nt[i]; i++)
	sum += nt[i];

    for (i = sum % MAXNTS;;) {
	if (defs[i].text == 0) {
	    if (tokty == UNKNOWN)
		return -1;	/* not found	 */
	    if (totalnts == MAXNTS) {
		cerror("too many nonterminals!");
		}
	    defs[i].text = string(nt);
	    defs[i].next = NULL;
	    defs[i].tokty = tokty;
	    totalnts++;
	    return i;
	    }
	if (!strcmp(defs[i].text, nt))
	    return i;
	if (i == MAXNTS)
	    i = 0;
	else
	    i++;
	}
    }

int             mdlineno = 1;

typedef union Ystack
{
    struct Toklist *tok;
    char		*text;
    struct Pn      *pn;
}               ystack;
#define YYSTYPE ystack		/* make this the yacc stack type	 */

struct Toklist *append_toks(e1, e2)	/* append_toks token lists */
struct Toklist *e1, *e2;
    {
    struct Toklist *e;
    if (!e1)
	return e2;
    if (!e2)
	return e1;
    for (e = e1; e->next; e = e->next)	/* get to end of first	 */
	continue;
    e->next = e2;		/* tack on second	 */
    return e1;
    }

/* assemble up a production's rhs
 *  deref(toks) says to check for consistency among the names listed
 *  and to give the defiens the intersection of the types of the nonterminals listed.
 *  Other nonterminals are assumed to carry the type of the source.
 *  Def checks all nonterminals in the definition for consistency, and the defiens gets the
 *  intersection.
 *  A nonterminal standing alone adds one more thing to be intersected as in def.
 *  Set just gives the defiens the type of the named nonterminal.
 */
struct Pn *makerhs(assm, rt, sem, cost, allocl)
    struct Toklist	*assm, *rt, *sem;
    int			cost;
    char		*allocl;		/* allocation class */
    {
    struct Pn		*result;

    result = get(struct Pn);
    result->cost = cost;
    result->rhs[0] = assm;
    result->rhs[1] = rt;
    result->symsem = sem;
    result->allocl = alloclassindex(string(allocl));
    return result;
    }


/*  Run through the production and mark which nonterminals carry input types and
 *  which ones carry output types.  This used to be done in make_rhs but it must
 *  actually be deferred until we known which tokens are nonterminals.
 */
static void fix_semantics(pn)
    struct Pn		*pn;
    {
    int			found;
    struct Toklist	*sem = pn->symsem;
    int			i;
    struct Toklist	*tok;
    char		bf[100];

    /*  Default all token classes to NONE so that they won't participate */
    for (EACHTOK(pn, 0, tok))
	tok->tkclass = TKCLASS_NONE;
    for (EACHTOK(pn, 1, tok))
	tok->tkclass = TKCLASS_NONE;

    pn->type_bits = -1;

    /*	The semantic action "set(name)" means that the type of the defiens is
     *  the same as that of the name.  name can either be a typename or the
     *  name of a nonterminal in the definition.
     */
    if (sem->text == string("set") &&
	(sem = sem->next) &&			/* point to LPAR */
	sem->text == string("(") &&		/* check for LPAR */
	(sem = sem->next) &&			/* point to name */
	sem->next &&				/* check for RPAR */
	sem->next->text == string(")")) {

	/*  If the name is a typename, just set type_bits; no token types will
	 *  participate.
	 */	
	for (i = 0; i < ntypes; i++) {
	    if (md_types[i].name == sem->text) {
		pn->type_bits = md_types[i].type_bits;
		return;
		}
	    }

	/*  Otherwise one token will participate and
	 *  it will govern the type of the result.
	 */
	found = 0;
	for (EACHTOK(pn, 0, tok)) {
	    if (tok->text == sem->text) {
		tok->tkclass = TKCLASS_OUTPUT;
		found = 1;
		}
	    }

	for (EACHTOK(pn, 1, tok)) {
	    if (tok->text == sem->text) {
		tok->tkclass = TKCLASS_OUTPUT;
		found = 1;
		}
	    }

	if (found)
	    return;
	else
	    yyerror("name %s not found for set semantic action", sem->text);
	}

    /*  The semantic action "deref(name1,name2,etc)" means that the type of the
     *  defiens is the intersection of the types of all of the supplied typenames
     *  and nonterminals.  Nonterminals must appear in the definition.
     *  Unmentioned nonterminals are assumed to carry input types, and they
     *  are all intersected together.
     */
    if (sem->text == string("deref") &&
	(sem = sem->next) &&			/* point to LPAR */
	sem->text == string("(")) { 		/* check for LPAR */
	sem = sem->next;

	/*  set all nonterminals in definition to TKCLASS_INPUT */
	for (EACHTOK(pn, 0, tok)) {
	    if (tok->tokty == NONTERM)
	        tok->tkclass = TKCLASS_INPUT;
	    }

	for (EACHTOK(pn, 1, tok)) {
	    if (tok->tokty == NONTERM)
	        tok->tkclass = TKCLASS_INPUT;
	    }

	for (;; sem = sem->next) {

	    /*  expecting a name or RPAR */
	    if (!sem) {
		yyerror("syntax error");
		return;
		}

	    if (sem->text == string(")"))
		break;

	    if (sem->text == string(","))
		continue;

	    /* if the name is a typename */	
	    for (i = 0; i < ntypes; i++) {
		if (md_types[i].name == sem->text) {
		    /*  intersect type's bits into pn */
		    pn->type_bits &= md_types[i].type_bits;
		    goto nexttok;
		    }
		}

	    /* else look for a nonterminal by that name in the definition */
	    found = 0;
	    for (EACHTOK(pn, 0, tok)) {
		if (tok->text == sem->text) {
		    tok->tkclass = TKCLASS_OUTPUT;
		    found = 1;
		    }
		}

	    for (EACHTOK(pn, 1, tok)) {
		if (tok->text == sem->text) {
		    tok->tkclass = TKCLASS_OUTPUT;
		    found = 1;
		    }
		}

	    if (!found)
		yyerror("name %s not found for deref semantic action", sem->text);

	    nexttok:;
	    }

	return;
	}

    else if (sem->text == string("def") && !sem->next) {

	/*  Set everything in definition to TKCLASS_OUTPUT.  Every nonterminal
	 *  will participate.
	 */
	for (EACHTOK(pn, 0, tok))
	    if (tok->tokty == NONTERM)
		tok->tkclass = TKCLASS_OUTPUT;

	for (EACHTOK(pn, 1, tok))
	    if (tok->tokty == NONTERM)
		tok->tkclass = TKCLASS_OUTPUT;

	return;
	}

    /*	Semantic actions whose names are typenames mean that the type of the
     *  defiens is the intersection of all of the nonterminal types in the
     *  definition, intersected with the type of the type name.
     */
    else {
	for (i = 0; md_types[i].name; i++) {
	    if (md_types[i].name == sem->text) {

		pn->type_bits = md_types[i].type_bits;

		/*  set all nonterms in definition to TKCLASS_OUTPUT */ 
		for (EACHTOK(pn, 0, tok))
		    if (tok->tokty == NONTERM)
			tok->tkclass = TKCLASS_OUTPUT;
		for (EACHTOK(pn, 1, tok))
		    if (tok->tokty == NONTERM)
			tok->tkclass = TKCLASS_OUTPUT;
		return;
		}
	    }
	}

    fprintf(stderr, "For the production: ");
    dumppn(pn, (struct Toklist *) NULL, 0);
    sprintf(bf, "semantic routine %s not found", pn->symsem->text);
    zzerror(bf);
    }

/* to strip the "par" from the rt and assemble a new rhs */

struct Toklist *strip_par(rt)		/* assemble up a production's rhs */
    struct Toklist *rt;
    {
    struct Toklist *result, *p, *ptr;
    int             count;
    struct Toklist *head;
    result = get(struct Toklist);
    head = rt;
    /* NOTE that this stuff makes some big assumptions about the validity */
    /* of the rt.  We probably should put some extra checks in because this */
    /* should only be done once per rt per execution */
    if (strcmp(rt->text, "par") == 0) {
	head = head->next->next;	/* will have a ( and then a rt */

	/* Now keep track of the "(" and ")" */
	/* when the # of "(" and ")" are equal stop */
	result->text = string(head->text);
	result->tokty = head->tokty;
	result->next = NULL;
	p = result;
	count = 1;
	while (head != NULL && count != 0) {
	    head = head->next;
	    if (strcmp(head->text, "(") == 0) {
		count++;
		}
	    if (strcmp(head->text, ")") == 0) {
		count--;
		}
	    ptr = get(struct Toklist);
	    ptr->text = string(head->text);
	    ptr->tokty = head->tokty;
	    ptr->next = NULL;
	    p->next = ptr;
	    p = p->next;
	    }

	return result;
	}
    else return rt;
    }

/* Get the rt for the side effect */

/* These two routines can probably be combined somehow */

struct Toklist *strip_first(rt)
    struct Toklist *rt;
    {
    struct Toklist *result, *p, *ptr;
    int             count;
    struct Toklist *head;
    result = get(struct Toklist);
    head = rt;
    /* NOTE that this stuff makes some big assumptions about the validity */
    /* of the rt.  We probably should put some extra checks in because this */
    /* should only be done once per rt per execution */
    if (!strcmp(rt->text, "par")) {
	head = head->next->next;/* will have a ( and then a rt */

	/* strip off the first rt */
	head = head->next;
	count = 1;
	while (head != NULL && count != 0) {
	    head = head->next;
	    if (strcmp(head->text, "(") == 0)
		count++;
	    if (strcmp(head->text, ")") == 0)
		count--;
	    }
	head = head->next->next;/* get rid of '(' and ',' */
	result = get(struct Toklist);
	result->text = string(head->text);
	result->tokty = head->tokty;
	result->next = NULL;
	p = result;
	count = 1;

	while (head != NULL && count != 0) {
	    head = head->next;
	    if (strcmp(head->text, "(") == 0)
		count++;
	    if (strcmp(head->text, ")") == 0)
		count--;
	    ptr = get(struct Toklist);
	    ptr->text = string(head->text);
	    ptr->tokty = head->tokty;
	    ptr->next = NULL;
	    p->next = ptr;
	    p = p->next;
	    }

	return result;
	}
    else
	return rt;
    }
%}
%token Range Type Term Identifier Included Integer String Openquote Closequote Register
%%

/*    This is the grammar for the language used to describe machines.   */
/*    (Which is itself a grammar).                                      */

stmts	:	empty
	|	stmts stmt
	;

stmt	:	range
	|	include
	|	terminal
	|	regstmt
	|	pn
	|	typestmt
   	;

/*    %register assemblyname rtname first number width stride volatile	*/
/*    first = first bit number in allocation vector			*/
/*    number = # of registers of this class				*/
/*    width = width in # of bits from allocation vector that must be grabbed */
/*    stride = distance in allocation bits between adjacent regs of class  */
/*    volat = 1 if register is set by instructions that don't mention it   */

typestmt :      Type Identifier Integer ';'
		{
		if (ntypes == MAXTYPE) {
		    yyerror("Too many %type declarations");
		    }
		else {
		    md_types[ntypes].name = string($2.text);
		    md_types[ntypes].type_bits =
			strtol($3.text, (char **)NULL, 0);
		    ntypes++;
		    }
		}

regstmt	:	Register tok tok tok tok tok tok tok ';'
		{
		}

range	:	Range Identifier Integer Integer ';'
		{
		char	bf[40];
		$$.pn = get(struct Pn);
		sprintf(bf, "%s-%s", $3.text, $4.text);
		    $$.pn->range = string(bf);
		    addpn($$.pn, mktok($2.text, RANGE)->text);
		}
	    ;

include	:	Included
		    {
		    printf("%s", yytext);
		    }
	    ;

terminal :	Term Identifier ';'
		    {
		    $$.pn = get(struct Pn);
		    addpn($$.pn, mktok($2.text, VARIABLE)->text);
		    }
	    ;

pn	:	Identifier
		{
		int             n;
		mktok($1.text, NONTERM);		/* define id as nonterminal */
		n = ntlook($1.text, NONTERM);		/* get table number */
		if (pns[n]) {
		    yyerror("%s multiply-defined", $1.text);
		    }
		} '=' rhss ';'
			    
	    ;

rhss	:	rhs
		{
		/* The Yacc stack currently holds
		 * Identifer, Marker, '=', rhs
		 * rhs is $1.
		 * The identifier is $-2.
		 * The Marker drives the embedded action for pn above.
		 */
		addpn($1.pn, mktok($-2.text, NONTERM)->text);
		}

	    |	rhss '|' rhs 
		{
		addpn($3.pn, mktok($-2.text, NONTERM)->text);
		}
	    ;

rhs	:	tok ',' tok ',' tok ',' Integer ',' Identifier 
		{
		$$.pn = makerhs($1.tok, $3.tok, $5.tok, atoi($7.text), $9.text);
		}

	|	tok ',' tok ',' tok ',' Integer
		{
		$$.pn = makerhs($1.tok, $3.tok, $5.tok, atoi($7.text), "Normal");
		}

	|	tok ',' tok ',' tok
		{
		$$.pn = makerhs($1.tok, $3.tok, $5.tok, 0, "Normal");
		}

	|	tok ',' tok
		{
		$$.pn = makerhs($1.tok, $3.tok, mktok("def", TERMINAL), 0, "Normal");
		}

	|	tok
		{
		$$.pn = makerhs($1.tok, $1.tok, mktok("def", TERMINAL), 0, "Normal");
		}
	;

tok	:	Integer
		{
		$$.tok = mktok($1.text, TERMINAL);
		}

	|	Identifier
		{
		$$.tok = mktok($1.text, UNKNOWN);
		}

	|	String	
		{
		$$.tok = mktok($1.text, TERMINAL);
		}

	|	Openquote opttoks Closequote
		{
		$$.tok = $2.tok;
		}

	|	Identifier '(' opttoks ')'
		{
		struct Toklist *e1, *e2, *e4;
		e1 = mktok($1.text, UNKNOWN);
		e2 = mktok("(", TERMINAL);
		e4 = mktok(")", TERMINAL);
		$$.tok = append_toks(e1, append_toks(e2, append_toks($3.tok, e4)));	
		}

	|	'(' opttoks ')'
		{
		struct Toklist *e1, *e3;
		e1 = mktok("(", TERMINAL);
		e3 = mktok(")", TERMINAL);
		$$.tok = append_toks(e1, append_toks($2.tok, e3));
		}
	;

opttoks	:	toks
		{
		$$.tok = $1.tok;
		}

	|	empty
		{
		$$.tok = NULL;
		}

toks	:	tok
		{
		$$ = $1;
		}

	|	toks ',' tok
		{
		struct Toklist *e2;
		e2 = mktok(",", TERMINAL);
		$$.tok = append_toks($1.tok, append_toks(e2, $3.tok));
		}

	|	toks tok
		{
		$$.tok = append_toks($1.tok, $2.tok);
		}
	;

empty	:
	;
%%

#include "lex.yy.c"

static yyerror(s, t)
    char           *s, *t;
    {
    printf(s, t);
    printf("\n\n%s", bf + 200);
    for (s = strptr; s > bf + 200; s--)
	printf(" ");
    printf("^\n");
    exit(1);
    }

getmd(mdfilename)			/* suck up the grammar	 */
    char           *mdfilename;		/* and compute first	 */
    {					/* sets			 */
    struct Toklist *e1, *e2;
    int             locv;
    struct Toklist *tok;
    int             i;
    struct Pn      *p;
    mdfile = fopen(mdfilename, "r");

    if (mdfile == NULL) {
	cerror("can't open %s\n", mdfilename);
	}

    for (locv = 0; locv < nelts(terminals); locv++) {
	terminals[locv] = malloc(VARLN + 1);
	sprintf(terminals[locv], VARFMT, locv);
	}

    /* initialize the parser with the base production phi -> . inst $  */

    e1 = mktok("inst", NONTERM);
    e2 = mktok("$END$", TERMINAL);
    e1->next = e2;

    phi = makerhs(e1, e1, mktok("def", UNKNOWN), 0, "Normal");
    addpn(phi, phistring = mktok("$PHI$", NONTERM)->text);

    epsilon = mktok("", TERMINAL)->text;
    rangestr = mktok("range", RANGE)->text;
    termstr = mktok("term", VARIABLE)->text;
    endstring = e2->text;

    yyparse();			/* read machine description */

    /* Run through all the previous productions and fix up any unknown
       token types. */
    for (i = 0; i < MAXNTS; i++) {
	if (defs[i].text && defs[i].tokty == NONTERM) {

	    /* for each alternative rhs */
	    for (EACHALT(i, p)) {

		for (side = 0; side < 2; side++) {
		    for (EACHTOK(p, side, tok)) {
			if (tok->tokty == UNKNOWN) {
			    if ((locv = ntlook(tok->text, UNKNOWN)) == -1)
				tok->tokty = TERMINAL;
			    else 
				tok->tokty = defs[locv].tokty;
			    }
			}
		    }

		fix_semantics(p);
#if 0
		printf("/*\n");
	        printf("type_bits %o cost %f allocl %d\n",
		    p->type_bits, (double)p->cost, p->allocl);
		dumppn(p, (struct Toklist *) NULL, 0);
		printf("\n");
		dumppn(p, (struct Toklist *) NULL, 1);
		printf("*/\n\n");
#endif
		}
	    }
	}

    getfirst();			/* get first sets		 */
    checkrefs();		/* figure out which nonterms are used */

#if 0
    /* dump the first sets for debugging */
    for (side = 0; side < 2; side++) {
	printf("side %d\n", side);
	for (i = 0; i < MAXNTS; i++) {
	    if (defs[i].text) {
		printf("first[%s] = ", defs[i].text);
		for (e1 = firsts[i][side]; e1; e1 = e1->next)
		    printf("%s ", e1->text);
		printf("\n");
		}
	    }
	}
#endif
    }

addpn(pn, nt)			/* add production to the chain	 */
    struct Pn      *pn;		/* of alternative pns for	 */
    char		*nt;		/* this nonterminal		 */
    {
    struct Toklist *result = NULL;
    int             n = ntlook(nt, UNKNOWN);	/* get the nonterminal's
							   #	 */
    pn->next = pns[n];		/* link this on the chain	 */
    pns[n] = pn;
    pn->lhn = n;		/* remember our nt's #		 */

#if 0
	{
	struct Pn      *headx;
	headx = pns[n];
	while (headx != NULL) {
	    if (headx->rhs[0] != NULL && headx->rhs[1] != NULL)
		printf("%s %s\n", headx->rhs[0]->text, headx->rhs[1]->text);
	    headx = headx->next;
	    }
	printf("\n");
	}
#endif

    /* I do not believe rhs[1] will ever be NULL */
    if ( /* flag == 0 && */ pn->rhs[1] != NULL && !strcmp(pn->rhs[1]->text, "par")) {
	/* This assumes "par"s are limited to 2 args */
	/* Add the two rt's as alternate translations. */
	result = strip_par(pn->rhs[1]);
	add_nextpn(result, pn, n);
	result = strip_first(pn->rhs[1]);
	add_nextpn(result, pn, n);
	}
#if 0
	{
	int             i;
	struct Toklist *e;
	printf("add pn for %s cost %f\n", nt, (double) pn->cost);
	for (i = 0; i < 2; i++) {
	    printf("side %d: ", i);
	    for (e = pn->rhs[i]; e; e = e->next)
		printf("%s ", e->text);
	    printf("\n");
	    }
	printf("\n");
	}
#endif
    }

/* These two routines can probably be combined somehow */

add_nextpn(rt, pn, n)		/* add production to the chain	 */
    struct Toklist *rt;
    struct Pn      *pn;		/* of alternative pns for	 */
    int             n;		/* this nonterminal's #		 */
    {
    struct Pn      *pn1;
    struct Toklist *p, *ptr, *head;	/* to strip the par rt          */
    pn1 = get(struct Pn);
    *pn1 = *pn;
    pn1->rhs[1] = rt;
    p = NULL;
    head = pn->rhs[0];
    while (head != NULL) {
	ptr = get(struct Toklist);
	ptr->text = string(head->text);
	ptr->tokty = head->tokty;
	ptr->next = NULL;
	if (p == NULL) {
	    pn1->rhs[0] = ptr;
	    p = pn1->rhs[0];
	    }
	else {
	    p->next = ptr;
	    p = p->next;
	    }
	head = head->next;
	}

    pn1->next = pns[n];
    pns[n] = pn1;
    pn1->lhn = n;
    }

static int      changed;	/* changes made? */
/* fill in first sets for each nonterminal
   each entry in firsts is a list of two lists
   first list is assem side, second is rt side.
*/
getfirst()
    {
    struct Toklist *tok, *f;
    struct Pn      *p;
    int             side, i, nullable;

    for (side = 0; side < 2; side++) {				/* for assem's & rt's */
	changed = 1;
	while (changed == 1) {
	    changed = 0;

	    /* process each nonterminal and add stuff to its firsts list */
	    for (i = 0; i < MAXNTS; i++) {
		if (defs[i].text) {		/* for each nonterminal A */

		    if (defs[i].tokty == RANGE)
			addf(i, rangestr, side);

		    else if (defs[i].tokty == VARIABLE)
			addf(i, termstr, side);

		    else {
			for (EACHALT(i, p)) {	/* for each alternative rhs */

			    if (!p->rhs[side]) {
				yyerror("Cannot handle empty strings in machine description grammar");
				}

			    for (EACHTOK(p, side, tok)) {

				if (tok == 0) {
				    /* everything on rhs is nullable hence the */
				    /* nt is itself nullable 		 */
				    addf(i, epsilon, side);
				    break;
				    }
				/* terminal on rhs? */
				else if (tok->tokty == TERMINAL) {
				    addf(i, tok->text, side);
				    break;
				    }
				else {
				    /* nonterminal on rhs, anything that can */
				    /* begin it can begin our nonterminal    */
				    nullable = 0;
				    for (f = firsts[ntlook(tok->text, UNKNOWN)][side]; f; f = f->next) {
					if (f->text == epsilon)
					    nullable = 1;
					else
					    addf(i, f->text, side);
					}

				    if (!nullable)
					break;
				    }
				}
			    }
			}
		    }
		}
	    }
	}
    }

/*  Check for unused nonterminals */
checkrefs()
    {
    int		tn;
    struct Toklist *tok, *f;
    struct Pn      *p;
    int             side, i, nullable;

    for (side = 0; side < 2; side++) {		/* for assem's & rt's */

	/* process each nonterminal */
	for (i = 0; i < MAXNTS; i++) {

	    if (defs[i].text && defs[i].tokty == NONTERM) {

		for (EACHALT(i, p)) {	/* for each alternative rhs */

		    for (EACHTOK(p, side, tok)) {

			if (tok->tokty != TERMINAL) {

			    /* mark the nonterminal reffed */
			    tn = ntlook(tok->text, UNKNOWN);
			    if (tn != -1)
				refs[tn] = 1;
			    }
			}
		    }
		}
	    }
	}

    for (i = 0; i < MAXNTS; i++) {
	if (defs[i].text && !refs[i] && defs[i].text != rangestr &&
		defs[i].text != phistring) {
	    fprintf(stderr, "/* Unused nonterminal: %s */\n", defs[i].text);
	    }
	}
    }

#define trace_addf 0
addf(ntn, s, side)		/* add a token to first(nonterm) */
    int             ntn;		/* nonterminal # */
    char		*s;		/* thing to add */
    int             side;		/* side #  assem or rt */
    {
    struct Toklist *f, **pf;
#if trace_addf
    printf("addf(ntn=%d %s s='%s' side=%d)\n",
	ntn, defs[ntn].text, s, side);
#endif
    for (pf = &firsts[ntn][side]; *pf; pf = &(*pf)->next) {
	if ((*pf)->text == s)
	    return;
	}

    f = mktok(s, UNKNOWN);
    /* Of course it is UNKNOWN, because mktok won't look it up if we */
    /* pass in UNKNOWN as the type, probably want to use ntlook */
    if (f->tokty == UNKNOWN)
	f->tokty = TERMINAL;
    changed = 1;

    (*pf) = f;
    }

static conint(c1, c2,pfreevars)	/* intersect 2 constraint lists */
    register char **c1, **c2;	/* in place		 */
    int *pfreevars;
    {
    register        locv;
    /* should this loop be reversed because of the way conadd works??? */
    /* to make sure that we have the constraint of a variable before */
    /* we say that another is constrained to be equal to it??? */
    for (locv = 0; locv < MAXGLOBALS + MAXFREENONTERMS; locv++) {
	if (!c1[locv])
	    c1[locv] = c2[locv];
	else if (c2[locv] && c1[locv] != c2[locv] &&
	    !conadd(c1, locv, c2[locv]))
	    return 0;
	}
    if (pfreevars) {
	while(c2[MAXGLOBALS+(*pfreevars)+1]) {
		(*pfreevars)++;
	    }
	}
    conclean(c1);
    return 1;
    }

/*	add a constraint on variable n to a constraint list in place	*/
/*	return 1 if you can, 0 if inconsistent				*/
conadd(constraints, locv, s)
    char          **constraints;
    char            locv;		/* 0 <= var < MAXGLOBALS +	*/
				/* MAXFREENONTERMS or we punt	 */
    register char  *s;		/* to have this value		*/
				/* s must be installed already	*/
    {
    register char  *t;		/* current constraint on %n */
    if (locv > MAXGLOBALS + MAXFREENONTERMS)	/* punt if we cannot store */
	cerror("conadd locv %d\n", locv);	/* info on this variable   */

#if 0
    printf("conadd %%%02d=%s\n", locv, s);
#endif
    t = constraints[locv];	/* existing constraint on %n */

    if (terminals[locv] == s) /* where and why would we constrain it to itself??? */
	return 1;		/* %00==%00 */

    /* if variable is not currently constrained or we are constraining it */
    /* equal to another variable which is not currently constrained or is */
    /* constrained to the same value as this one.			   */
    else if (t == NULL || ISVAR(s) && constraints[VAR(s)] && t == constraints[VAR(s)]) {
	constraints[locv] = s; /* this is where we really add it */
	conclean(constraints); /* all others must get here to add */
	return 1;
	}
    /* if we are trying to constraint it to a value it already has */
    else if (t == s)
	return 1;

    else if (!ISVAR(s) && ISVAR(t)) /* follow a constraint chain */
	return conadd(constraints, VAR(t), s);

    /* we are constraining it to be equal to a variable which is not */
    /* currently constrained */
    else if (ISVAR(s) && !constraints[VAR(s)])
	return conadd(constraints, VAR(s), terminals[locv]);

    /* we are constraining this to be equal to something which is	 */
    /* constrained to us.  adding %01==%02 when %02==%01 is already there */
    else if (ISVAR(s) && constraints[VAR(s)] == terminals[locv])
	return 1;

    else
	return 0;
    }

/* avoid redundant constraints e.g.:
 *
 *  incl %03(fp) cost=1004 %01=%03 %02=1 %03=-32768-32767
 *  incl %03(fp) cost=1004 %01=-32768-32767 %02=1 %03=%01
 *
 *   if %i=%j ensure i<j
 */
conclean(p)
    register char **p;
    {
    register int    i, j;
    register char  *tmp;
    /* If %i=%j and i > j */
    for (i = 0; i < MAXGLOBALS + MAXFREENONTERMS; i++)
recheckourself:
/*	if (p[i] && ISVAR(p[i]) && (j = VAR(p[i])) < i) { */
	if ((tmp = *(p + i)) && ISVAR(tmp) && (j = VAR(tmp)) < i) {
	    tmp = p[j];		/* constraint on lesser var if any */
	    p[j] = terminals[i];/* %j=%i */
	    p[i] = tmp;		/* %i=whatever %j was = */
	    goto recheckourself;
	    }
    }

inittrans()			/* reinitialize stalloc allocator */
    {
    Statesfree = 0;
    Statehead = NULL;
    nbanks = memx = 0;
    }

int             gdumpsets;

struct State   *parse(lin, s)	/* main Earley parser function	 */
    char           *lin;	/* text to be parsed/translated	 */
    int             s;		/* 0: assem->rt; 1: rt->assem	 */
    {
    struct State   *rsp;
    register struct State *sp, *next, **prior = &rsp;
    rsp = parse2(lin, s);	/* do the actual parsing        */
#if 0
    printf("/* memx = %d maxmemx = %d */\n", memx, maxmemx);
#endif
#if 0
    if (rsp == 0)
	printf("/* In parse: rsp = NULL */\n");
    else
	printf("/* In parse: rsp = %x */\n", rsp);
#endif

#if 0
    if (rsp->next == 0)
	printf("/* In parse: rsp->next = NULL */\n");
    else
	printf("/* In parse: rsp->next = %x */\n", rsp);
#endif

    if (gdumpsets)
	dumpsets();
#if 0
    printf("/* In parse: ready to eliminate states */\n");
#endif

    /* eliminate all parse states that are not instructions.		 */
    for (sp = rsp; sp;) {
#if 0
	dumpstate(sp, 0);
#endif
	*prior = sp; /* yes, this probably can be cut down more */

	/* Either prior points to the last good instruction on a chain	 */
	/* from  rsp, or sp == rsp.					 */
	/* See if sp is a good instruction too.			 */
	if (sp->dot == 0 && sp->pn == phi && sp->look == endstring) {
#if 0
	    printf("/* In parse: good sp */\n");
#endif
	    prior = &(*prior)->next;
	    sp = sp->next;
	    }
	else {
	    sp = sp->next;	/* leftStatefree(sp); */
	    }
	}

#if 0
    printf("/* In parse: ready to translate states */\n");
#endif
    /* Translate all of the instructions.  Translate may decide to delete the state
     * you pass it; it returns NULL in this case.  It may also decide to add some
     * alternative states following the one that you pass.  This happens if there
     * is a nonterminal on the input side of a production that is not matched on the
     * output side.  In this case, all alternatives for that nonterm are produced.
     */
#if 0
    printf("\n/*\n\nresulting parse trees:\n");
    for (sp = rsp; sp; sp = sp->next)
	dumpparse(sp, 0);
    printf("\n\n*/\n\n");
#endif

    for (prior = &rsp; *prior;) {
	next = (*prior)->next;
#if 0
	dumpparse(*prior, 0);
#endif
	if ((sp = translate(*prior, -1, 0, 0, 0, __FILE__, __LINE__)) == NULL) {
#if 0
	    printf("/* In parse: translate == NULL */\n");
#endif
	    *prior = next;
	    }
	else {
#if 0
	    printf("/* In parse: translate != NULL */\n");
#endif
	    *prior = sp;
	    for (;*prior != next;) {
		prior = &(*prior)->next;
		}
	    }
	}


    /* To do: if we are translating from assembly to rt, run through the
       rt's and pull comma operators out to top level.  EG: x = y++ =>
       move(comma(move(add(y,1),y),y),x) =>
       par(move(y,x),move(add(y,1),y)) comma(a,b) means perform a and
       return the value b. note that the rhs of a comma operator uses the
       old value of y. */

    return rsp;
    }

/*  The main body of the Earley parser used to parse assembly language */
/*  strings and register transfer strings.                             */
/*  lin is the string to be parsed.                                    */
/*  s   is 0 if lin is an assembly string, 1 if lin is a rt            */
/*  returns a factored parse tree for lin.                             */
#define trace_parse2 0
struct State   *parse2(lin, s)
    register char  *lin;
    int             s;
    {
    register struct State *sp, *startp;	/* a state pointer */
    struct Pn      *pn;		/* a production pointer	 */
    int             n;
    struct State    new;
    static struct State initstate = {-1}; /* types = any, all else NULL */
    globline = lin;		/* saved for debugging		 */
    globlen = strlen(lin);

#if trace_parse2
    printf("/*\n");
#endif

    if (!phistring)
	getmd("md");		/* read machine description	 */
    /* if not done so already	 */
    side = s;
    for (n = 0; n <= maxstate; n++)
	heads[n] = (struct State *) NULL;

    maxstate = -1;

    n = ntlook(phistring, UNKNOWN);
    current = 0;

    new = initstate;
    new.pn = pns[n];
    new.dot = pns[n]->rhs[side];
    new.look = endstring;

    addstate("parser", 0, new);

    for (;;) {

#if trace_parse2
	printf("parse2:examine S[%d]\n", current);
#endif
	for (sp = heads[current]; sp; sp = sp->next) {
	    /* at the end of the production? */
	    if (sp->dot) {
		/* No in this case */
#if trace_parse2
		printf("parse2: middle of production:: %s is a ", lin + current);
#endif
		if (sp->dot->tokty == NONTERM) {

#if trace_parse2
		    printf("NONTERM\n");
#endif
		    /* The token at the current position is a nonterminal. */
		    /* Add a new state to the current stateset */
		    /* for each of its alternatives.			 */
		    /* Lookahead string is first of whatever follows the */
		    /* current tok concated to lookahead for this state  */
		    /* Avoid doing this if the predicted state is	 */
		    /* obviously bogous.				 */
		    new = *sp;
		    new.init = current;
		    new.left = (struct State *) NULL;

		    /* For each rhs that current nt can produce	 */
		    /* Before predicting, check if first(rhs) matches	 */
		    /* the beginning of the rest of the line.		 */

		    for (EACHALT(ntlook(sp->dot->text, NONTERM), pn)) {
			register struct Toklist *tk;	/* 1st tok on
							   alternative rhs */
			tk = pn->rhs[side];
#if trace_parse2
			printf("parse2:consider predicting ");
			dumppn(pn, pn->rhs[side], side);
			printf("\n");
			printf("tk %s %s\n", tk->text, ts[tk->tokty]);
			printf("lin+current %s\n", lin + current);
#endif

			if (ISVAR(lin + current)) {
				/* line has var here */
		    dopredict:	/* so anything goes */
			    new.pn = pn;
			    new.dot = pn->rhs[side];
			    new.cost = pn->cost;
			    predict(new, sp->dot->next, sp->look);
			    continue;
			    }
			if (isterminal(tk)) {	/* rhs starts with term */
			    if (!strncmp(lin + current, termtext(tk),
					  (int) termlen(tk)))
				goto dopredict;
			    }
			else if (tk->text == termstr)	/* rhs starts with */
			    goto dopredict;	/* a variable	 */

			else if (tk->text == rangestr)
				if (lin[current] == '-' ||
				      isdigit(lin[current])) {
				    goto dopredict;	/* rhs starts with */
							/* a range	 */
				    }
				else {
				    goto nextalt; /* try next alternative */
				    }

			/* rhs starts with a nonterminal, check firsts(tk) */
			/* if 1st nt is nullable, go ahead and predict */
			else {
#if trace_parse2
			    printf("ntlook(%s) => %d\n",
				   tk->text, ntlook(tk->text, UNKNOWN));
			    printf("firsts[] => \n");
#endif
			    /* We should have no UNKNOWNs left, so ntlook */
			    /* should not return -1 */
			    for (tk = firsts[ntlook(tk->text,
					             UNKNOWN)][side];
				 tk; tk = tk->next) {
#if trace_parse2
				printf(" => %s \n", tk->text);
#endif
				if (tk->text == termstr) {
				    goto dopredict;
				    }
				else if (tk->text == rangestr)
				    if (lin[current] == '-' ||
					      isdigit(lin[current])) {
				        goto dopredict;
					}
				    else {
					goto nextfirst; /* next first */
				    }
				else if (tk->text == epsilon) {
				    goto dopredict;
				    }
#if trace_parse2
				printf("tokty %s termtext '%s' termlen %d\n",
				       ts[tk->tokty], termtext(tk), termlen(tk));
#endif
				if (isterminal(tk) &&
				       !strncmp(lin + current,
					      termtext(tk), (int) termlen(tk)))
				    {
#if trace_parse2
				    printf("first matches line!\n");
#endif
				    goto dopredict;
				    }
				nextfirst:;
				}
			    }
			nextalt:;
			}
		    }
		else if (sp->dot->tokty == RANGE || sp->dot->tokty == VARIABLE) {
#if trace_parse2
		    printf("expecting numeric RANGE or VARIABLE\n");
#endif
		    scannumber(sp, lin);	/* scanner */
		    }
		else {
#if trace_parse2
		    printf("expecting string TERMINAL\n");
#endif
		    scanstring(sp, lin);	/* scanner */
		    }
		}
	    else {		/* yes, at the end of the production */
#if trace_parse2
		printf(" end of production:: %s vs. %.*s ", sp->look,
		       strlen(sp->look), lin + current);
		printf(" and current %d globlen %d\n", current, globlen);
#endif
		if ((!strncmp(sp->look, lin + current, (int) strlen(sp->look)) ||
		    sp->look == endstring && current == globlen) && semantics(sp)) {
#if trace_parse2
		    printf(" MATCHES\n");
		    dumpstate(sp, 0);
#endif
		    for (startp = heads[sp->init]; startp;
		    	startp = startp->next) {
			/* look for stuff with P to right of dot */
			if (startp->dot &&
			       startp->dot->text == defs[sp->pn->lhn].text) {
			    new = *startp;
			    if (conint(new.constraints, sp->constraints,NULL)) {
				int             t;
				/* make a new state with the dot to */
				/* right of the nonterm */
			        new.vk.kid = sp;
				new.left = startp;
				new.dot = new.dot->next;
				/* SUPPRESS 560 */
				if (t = eqchk(&new)) {
				    if (t == 1)
					new.cost += sp->cost;
				    addstate("completer", current, new);
				    }
				}
			    }
			}
		    }
		else {
		    /* SUPPRESS 530 */
#if trace_parse2
		    printf("DOES NOT MATCH\n");
		    dumpstate(sp, 0);
#endif
		    }
		}
	    }

	/* blow away the hashheads when we are done looking at the */
	/* 'current' character in the parse */
	/* Note: this is an array of pointers, not any states */
	if (hashheads[current]) {
	    free(hashheads[current]);
	    hashheads[current] = 0;
	    }
	++current;

	if (current == globlen + 1) {

	    if (hashheads[current]) {
		free(hashheads[current]);
		hashheads[current] = 0;
		}
#if trace_parse2
	    printf("*/\n");
#endif
	    return heads[current];
	    }
	}
    }

/*  Record that we peeked at character x */
/*  So we can determine the shortest bogus prefix of a bogus input. */
#define check(x) ((maxstate = (maxstate < (x)) ? (x) : maxstate), 1)

checkstr(line, current, tok)	/* see if tok follows in line	 */
    char           *line;		/* starting at current		 */
    struct Toklist *tok;
    {				/* and keep track of maxstate	 */
    register        len;
    len = termlen(tok);
    if (maxstate < current + len) {
	maxstate = current + len;
	if (maxstate > globlen + 1)
	    maxstate = globlen + 1;
	}
    return !strncmp(line + current, termtext(tok), len);
    }

/*  Scanner.  We are expecting a numeric VARIABLE or a RANGE.           */
static scannumber(sp, line)
    struct State   *sp;		/* current parse state		 */
    register char  *line;		/* input line			 */
    {
    register int    n;
    register int    locurr = current;	/* local copy of scan loc */
    struct State    new;	/* new state */
    new = *sp;			/* initialize new state		 */
    new.left = sp;		/* point to predecessor state	 */
    new.vk.var = NULL;
    new.trans = NULL;

    /* Seeing a variable and expecting a range or variable.             */
    /* We must install a state and return here because we need the .var */
    /* in order to translate the resulting state.                       */
    if (check(locurr) && line[locurr] == '%' &&
	   check(locurr + 1) && isdigit(line[locurr + 1]) &&
	   check(locurr + 2) && isdigit(line[locurr + 2]))
    {

	new.vk.var = terminals[VAR(line + locurr)];

	if (new.dot->tokty == RANGE)
	{
	    n = ntlook(new.dot->text, UNKNOWN);
	    if (conadd(new.constraints, VAR(line + locurr), pns[n]->range))
	    {
		new.dot = new.dot->next;	/* move dot */
		addstate("scan1", locurr + VARLN, new);
	    } else
	    {
	    /* two range constraints did not match */
	    cerror("range constraint mismatch");
	    ;
	    }
	} else if (new.dot->tokty == VARIABLE)
	{
	    new.dot = new.dot->next;	/* move dot */
	    addstate("scan5", locurr + VARLN, new);
	} else
	{
		cerror("expecting a RANGE or VARIABLE got %d",new.dot->tokty);
	}
    }
    /* We do not see a variable or the end of the input, must be some  */
    /* other character.                                                */
    else
    {
	char           *endptr, buf[100];
	long            lo, hi, val;
	int             len;
	/* expecting a range and getting a constant number */
	n = ntlook(new.dot->text, UNKNOWN);

	if (line[locurr] != '-' && !isdigit(line[locurr]))
	    return;

	val = strtol(line + locurr, &endptr, MAXDIGITS);
	len = endptr - (line + locurr);

	if (len == 0)
	{
	    return;
	}			/* no digits!	 */
	if (maxstate < endptr - line)
	    maxstate = endptr - line;

	if (new.dot->tokty == RANGE)
	{
	    lo = strtol(pns[n]->range, &endptr, MAXDIGITS);
	    hi = strtol(endptr + 1, &endptr, MAXDIGITS);
	} else
	    lo = hi = val;

	if (lo <= val && val <= hi)
	{
	    strncpy(buf, line + locurr, len);
	    buf[len] = 0;
	    new.vk.var = /* cmd */ string(buf);
	    new.dot = new.dot->next;	/* move dot past tok */
	    addstate("scan6", locurr + len, new);	/* scan over the # */
	}
    }
}

/* Scanner.  The grammar specifies a string to be matched.  If this string
 * appears in the input, advance the parse past the input string If the
 * input contains a pattern variable, advance the parse past the pattern
 * variable and record a constraint on the variable.  If the input
 * contains a number and the grammar contains a range, check the range.
 * Maintain maxstate at the highest examined input character location.
 * Keep matching the input against string TERMINAL tokens in the parse; do
 * not install an advanced parse state unless it is necessary.  It will be
 * necessary if the scan comes to something other than a TERMINAL.
 */
static scanstring(sp, line)
    struct State   *sp;		/* current parse state		 */
    register char  *line;		/* input line			 */
    {
    register int    locurr = current;	/* local copy of scan loc */
    struct State    new;	/* new state */
    new = *sp;			/* initialize new state		 */
    new.left = sp;		/* point to predecessor state	 */
    new.vk.var = NULL;
    new.trans = NULL;

    for (;;) {

	if (new.dot == NULL || new.dot->tokty != TERMINAL) {
	    /* We must have made some progress, as this routine is only      */
	    /* called to scan string TERMINALS.                              */
	    /* Install a new state to represent our progress, and return.    */
	    addstate("scan7", locurr, new);
	    return;
	    }

	/* Seeing a variable and expecting a terminal, range, or variable.  */
	/* We must install a state and return here because we need the .var */
	/* in order to translate the resulting state.                       */
	if (check(locurr) && line[locurr] == '%' &&
	       check(locurr + 1) && isdigit(line[locurr + 1]) &&
	       check(locurr + 2) && isdigit(line[locurr + 2])) {

	    new.vk.var = terminals[VAR(line + locurr)];

	    if (new.dot->tokty == TERMINAL) {
		if (conadd(new.constraints, VAR(line + locurr),
			      new.dot->text)) {
		    new.dot = new.dot->next;	/* move dot */
		    addstate("scan2", locurr + VARLN, new);
		    }
		}
	    return;
	    }
	/* We do not see a variable in the input.                        */
	/* Do we see the end of the input?                               */
	else if (locurr >= globlen) {
	    if (new.dot->text == endstring) {
		locurr++;
		new.dot = new.dot->next;	/* new.dot is now NULL       */
		continue;	/* will install state & exit */
		}
	    return;
	    }

	/* We do not see a variable or the end of the input, must be some   */
	/* other character.  Expecting a string and getting a string.        */
	/* In this case we keep going instead of creating a possibly
	   useless */
	/* state record.                                                     */
	else if (checkstr(line, locurr, new.dot)) {
	    locurr += termlen(new.dot);
	    new.dot = new.dot->next;	/* move dot past one token	 */
	    continue;
	    }
	/* We've reached a dead end.                       */
	/* nothing matches, no need to install a new state */
	else
	    return;
	}
    }

dumpparse(sp, indent)		/* output a parse tree	 */
struct State   *sp;
    {
    struct State   *stk[200];
    int             n;
    dumpstate(sp, indent);
    putchar('\n');
    for (n = 0;;) {		/* push all the states on a stack */
	stk[n++] = sp;
	if (!(sp = sp->left))
	    break;
	}
    while (--n > 0) {
	if (stk[n]->dot && stk[n]->dot->tokty == NONTERM) {
	    dumpparse(stk[n - 1]->vk.kid, indent + 4);
	    }
	}
    }

/*  This encapsulates a pending call to trans2 so that we can call	*/
/*  trans2 recursively and pass down a call to perform when the		*/
/*  recursion bottoms out.						*/
struct Pending
{
    struct Toklist *tk;		/* next tok to trans	 */
    int ty;
    struct Pending *pending;
};
/*  Instantiate the translation of this complete state. Translate is called
 *  after the dot has gotten to the end of the production.  It caches the
 *  translation for a state in the trans field of the last state in the
 *  sequence.
 *
 *  Translate may return a set of possible translations, connected by the
 *  next field.  It adds new states in order to do this.
 */
#define trace_translate 0
struct State   *translate(rsp, ty, firsttoken, ntrans, freevars, fromfile, fromline)
    struct State   *rsp;
    int             ty;		/* type codes */
    int             firsttoken;
    int             ntrans;
    char           *fromfile;	/* debugging... */
    int             fromline;
    int             freevars;	/* # of free vars used so far */
    {
    char            bf[2048];
    struct State   *next = rsp->next, *s, *result;
#if trace_translate
    int             nalts;
    printf("translate(%d,%o,%d,%d,%d,%s,%d)\n",
	   rsp, ty, firsttoken, ntrans, freevars, fromfile, fromline);
    dumpstate(rsp, 0);
#endif

    if (rsp == (struct State *) NULL) {
#if trace_translate
	printf("translate from %s line %d returns NULL\n", fromfile, fromline);
#endif
	return rsp;
	}

    /* When does this happen ??? */
    if (rsp->trans) {
#if trace_translate
	printf("translate from %s line %d returns '%s'\n", fromfile, fromline, rsp->trans);
#endif
	/* this messes things up because we may have actually ended up with */
	/* many alternates for this rsp in earlier translations */
	return rsp;
	}

    result = trans2(rsp, rsp->pn->rhs[1 - side], bf, bf, (struct Pending *) 0,
	   ty, 1, firsttoken, ntrans, (struct Toklist *) 0, bf, freevars, __LINE__);

    if (result == NULL) {
#if trace_translate
	printf("translate from %s line %d returns NULL (trans2 failed)\n", fromfile, fromline);
#endif
	return NULL;
	}
#if trace_translate
    nalts = 0;
    for (s = result; s != next; s = s->next) {
	printf("translate from %s line %d returns alts[%d] = '%s'\n",
	       fromfile, fromline, nalts++, s->trans);
	}
#endif
    return result;
    }

/*  The state rsp is being translated.    
 *  Add the rest of these tokens onto the string beginning at beg and
 *  currently ending at end.
 *  We are in the process of getting a translation for rsp.
 *  We have generated the string deliminted by char pointers beg to end-1.
 *  The next token in the output production is at tk.
 *  Finish up the translation.
 *  After you add an alternative to a parse, resume adding stuff
 *  beginning at the resume pointer.
 *  If bound = 1, we are generating from the parse tree; else we are
 *  generating from the grammar.
 *
 *  Returns NULL if no translations were found, otherwise returns rsp, which
 *  may have had additional alternatives linked in.
 */
#define trace_trans2 0
struct State *trans2(rsp, tk, beg, end, pending, ty, bound, firsttoken, ntrans, nt,
    ntbeg, freevars, fromline)
    struct State   *rsp;		/* state to update	 */
    struct Toklist *tk;			/* next tok to trans	 */
    char           *beg, *end;		/* current bounds of so-far xlation */
    struct Pending *pending;		/* holds parameters of a pending call */
    int             ty;
    int             bound;		/* 0 if we are generating all alternatives. */
    int             firsttoken;		/* # of first ent in tokens	 */
    int             ntrans;		/* # of ents in tokens		 */
    struct Toklist *nt;			/* the nonterminal being xlated	 */
    char           *ntbeg;		/* where we started xlating it	 */
    int             freevars;		/* # of free vars used so far   */
    {
    struct State   *funrsp;
    struct State   *returnrsp=rsp,*newrsp, *sp, *oldkid, *alt, *next;
    struct State    oldrsp, **altp = &returnrsp, *rspnext = rsp->next;
    int             ntn;	/* a nonterminal #	 */
    int             dtnalts;	/* # of alternatives	 */
    int             nalts=0;	/* # of alternatives	 */
    int             aalts;	/* # of alternatives from translate	 */
    struct Pn      *pn;		/* a production pointer	 */
    struct Pending  newpending;
    int             pnty;
    int             i;
    int             oldmemx;
    struct State   *result;
#if trace_trans2
    printf("trans2(rsp=%d tk=%s str='%.*s' pending=%d ty=%o bound=%o\n",
	   rsp, tk ? tk->text : "NIL",
	   end - beg, beg, pending, ty, bound);
    printf("firsttoken=%d ntrans=%d nt=%s ntbeg=%d freevars=%d from=%d)\n",
	   firsttoken, ntrans, nt ? nt->text : "NIL",
	   ntbeg, freevars, fromline);
    /* dumpparse(rsp, 0); */
    printf("output side: ");
    dumppn(rsp->pn, tk, 1 - side);
    printf("\n\n");
#endif
restart:

    if (!(semantics(returnrsp) & ty)) {
#if trace_trans2
	printf("/* -->died on types */\n");
#endif
	return NULL;
	}

    /* for each token in the output side of this production	 */
    for (; tk; tk = tk->next) {
#if trace_trans2
	printf("next token to translate = %s rsp=%d at line %d\n", tk->text, rsp, __LINE__);
#endif

	/* if a contstant string just copy */
	if (isterminal(tk)) {
#if trace_trans2
	    printf("    is terminal string\n");
#endif
	    if (tk->text != endstring) {
		strcpy(end, termtext(tk));
		end += strlen(end);
		}
	    goto nextok;
	    }

#if trace_trans2
	printf("%s searching previous translations\n", tk->text);
#endif

	/*  else if nonterminal already translated, use the same translation */
	for (i = firsttoken; i < firsttoken + ntrans; i++) {
	    if (tokens[i]->text == tk->text) {
		sprintf(end, "%.*s", endtrans[i] - begtrans[i], begtrans[i]);
		end = endof(end);
#if trace_trans2
		printf("%s was previously translated as '%*.s'\n",
		       tk->text, endtrans[i] - begtrans[i], begtrans[i]);
#endif
		goto nextok;
		}
	    }

	/* else if this nonterminal appears on input side, translate it */
	if (bound) {
#if trace_trans2
	    printf("looking for %s on input side of parse tree, rsp = %d:\n", tk->text, rsp);
#endif
	    for (sp = rsp; sp->left; sp = sp->left) {
#if trace_trans2
		if (sp->left->dot->text == tk->text)
		    printf("%s == %s\n", sp->left->dot->text, tk->text);
		else
		    printf("%s != %s\n", sp->left->dot->text, tk->text);
#endif
		if (sp->left->dot->text == tk->text) {

		    /* VARIABLE or RANGE, copy the value from the input */
		    if (sp->left->dot->tokty != NONTERM) {
			strcpy(end, sp->vk.var);
			end = endof(end);
			goto nextok;
			}

		    else {
			/* NONTERM, translate the variable recursively */
			next = sp->vk.kid->next;
			oldrsp = *rsp;	/* holds old constraints */
			rsp->next = NULL;
#if trace_trans2
			printf("calling translate sp->vk.kid\n");
			for (dtnalts = 0, alt = sp->vk.kid; alt && alt != next; alt = alt->next) {
			    dtnalts++;
			    printf("%s\n", alt->pn->rhs[1 - side]->text);
			    }
			printf("before %d alts translations of %s\n", dtnalts, tk->text);
#endif
			maxfreevars = freevars;

			/* translate the kid	 */
			if (alt = translate(sp->vk.kid, -1,
			    firsttoken + ntrans, 0, freevars, __FILE__, __LINE__)) {
			    freevars = maxfreevars;
			    oldkid = sp->vk.kid;
			    sp->vk.kid = alt;

			    /* Check to see if the previous translate call */
			    /* returned more than one alternative.	    */
			    /* If so, link them into the list.		    */
			    aalts = alt->next != next;
			    for (alt = sp->vk.kid;
				alt && alt != next && alt != sp &&
				alt != sp->next && (!altp || alt != *altp);
				alt = aalts ? Statefree(alt): alt->next) {
#if trace_trans2
				printf("ty %o alt->trans alt->types %o\n", ty, alt->trans, alt->types);
#endif

				if (!alt->trans)
				    continue;

				strcpy(end, alt->trans);

				/* put the trans in the token list */
				begtrans[firsttoken + ntrans] = end;
				endtrans[firsttoken + ntrans] = endof(end);
				tokens[firsttoken + ntrans] = tk;

				newrsp = Statealloc();
				*newrsp = oldrsp;
				rspnext = newrsp->next;

				sp->vk.kid = alt;
				if (sp == rsp) {
				    newrsp->vk.kid = alt;
				    }

				/* check it now that we have a new kid for sp */
				if (!(semantics(newrsp) & ty)) {
				    Statefree(newrsp);
				    continue;
				    }
#if trace_trans2
				printf("alternative translation %d:\n", nalts);
				dumpstate(newrsp, 0);
#endif
				if (conint(newrsp->constraints, alt->constraints, &freevars)) {
				    if (funrsp = trans2(newrsp, tk->next, beg, endof(end),
						  (struct Pending *) 0, newrsp->types, 1,
						  firsttoken, ntrans, nt, end,
						  freevars, __LINE__)) {
#if trace_trans2
					printf("translation of %s succeeded\n", tk->text);
#endif
					for (newrsp=funrsp; newrsp != rspnext; newrsp = newrsp->next) {
#if trace_trans2
					    printf("nalt %d succeeded\n", nalts);
					    printf("newrsp = %d alt[%d] = '%s' ty = %o\n", newrsp,nalts,
						   newrsp->trans, newrsp->types);
#endif
					    *altp = newrsp;
					    altp = &(*altp)->next;
					    nalts++;
					    }
					}
				    else {
					Statefree(newrsp);
#if trace_trans2
					printf("translation of %s failed\n", tk->text);
#endif
					}
				    }
				else {
				    Statefree(newrsp);
#if trace_trans2
				    printf("nalt %d conint failed\n", nalts);
#endif
				    }
				}
			    sp->vk.kid = oldkid;
			    }
#if trace_trans2
			printf("trans2 returns %d alts from line %d for %s\n", nalts, __LINE__, tk->text);
#endif
			if (nalts == 1) {
			    *rsp = *returnrsp;
			    Statefree(returnrsp);
			    return rsp;
			    }
			return nalts == 0 ? (struct State *) NULL : returnrsp;
			}
		    }
		}
	    }
#if trace_trans2
	printf("%s not found in parse tree\n", tk->text);
#endif
	if (tk->tokty == RANGE || tk->tokty == VARIABLE) {
#if trace_trans2
	    printf("tk %s is a RANGE or VARIABLE rsp = %d line %d\n",
		   tk->text, rsp, __LINE__);
#endif

	    /* we may have added constraints in a recursive call */
	    while (rsp->constraints[MAXGLOBALS + freevars + 1]) {
		freevars++;
		}

	    /* No translation for this range or variable.  */
	    /* Generate a unique variable number.          */
	    if (freevars >= MAXFREENONTERMS) {
#if trace_trans2
		printf("trans2 returns NULL (no freevars)\n");
#endif
		return NULL;
		}
	    if (tk->tokty == RANGE) {
		if (!conadd(rsp->constraints, (char) freevars + MAXGLOBALS,
			      pns[ntlook(tk->text, UNKNOWN)]->range)) {
		    printf("variable %%%02d new range %s old range %s\n",
			   freevars + MAXGLOBALS, pns[ntlook(tk->text, UNKNOWN)]->range,
			   rsp->constraints[freevars+MAXGLOBALS]);
		    cerror("can't constrain a new variable!");
		    }
		}
	    sprintf(end, "%%%d", freevars++ + MAXGLOBALS);
	    if (freevars > maxfreevars) {
		maxfreevars  = freevars;
		}
	    end = endof(end);
	    goto nextok;
	    }

	/* No translation for this nonterminal, include all alternatives */
	/* "pending" encodes the rest of the current task so that it	 */
	/* can be finished after the alternatives are added.		 */
	/* Have we already translated this nonterminal?  If so, we are	 */
	/* executing a recursive call from the call that translated	 */
	/* the alternative in the first place.				 */
#if trace_trans2
	printf("%s not previously translated, expanding possibilities\n", tk->text);
#endif
	ntn = ntlook(tk->text, UNKNOWN);	/* get nonterminal #	 */

	/* For each alternative production for this nonterminal.	 */
	/* Start trans2 working on the first token in the alternative.	 */
	/* Tell it (via pending) to continue at the next token in the	 */
	/* current production.						 */
	oldrsp = *rsp;		/* hold constraints */

	for (EACHALT(ntn, pn)) {
	    pnty = pn->type_bits;
#if trace_trans2
	    printf("checking next alt for %s types %o %o %o %o\n",
	       tk->text, oldrsp.types, ty, pnty, oldrsp.types & ty & pnty);
#endif
	    newrsp = Statealloc();
	    *newrsp = oldrsp;
	    rspnext = newrsp->next;
	    if (!(semantics(newrsp) & ty & pnty)) {
		Statefree(newrsp);
		continue;
		}

	    newpending.tk = tk->next;
	    newpending.pending = pending;

	    if (funrsp = trans2(newrsp, pn->rhs[1 - side], beg, end,
		&newpending,
		newrsp->types, 0, firsttoken + ntrans, 0, tk, end,
		freevars, __LINE__)) {
		/* is it possible for a pn to return more than one alt? */
		for (newrsp = funrsp; newrsp != rspnext; newrsp = newrsp->next) {
		    if (semantics(newrsp) & ty & pnty) {
#if trace_trans2
			printf("nalt %d succeeded\n", nalts);
			printf("newrsp = %d alt[%d] = '%s' ty = %o\n", newrsp,nalts,
			   newrsp->trans, newrsp->types);
#endif
			*altp = newrsp;
			altp = &(*altp)->next;
			nalts++;
			}
		    }
		}
	    else {
		Statefree(newrsp);
		}
	    }

#if trace_trans2
	printf("trans2 returns %d alts from line %d for %s\n", nalts, __LINE__,
	       tk->text);
#endif
	if(nalts == 1) {
	    *rsp = *returnrsp;
	    Statefree(returnrsp);
	    return rsp;
	    }
	return (nalts == 0) ? (struct State *) NULL : returnrsp;
nextok:;
	}

    if (nt) {
	begtrans[firsttoken+ntrans] = ntbeg;
	endtrans[firsttoken+ntrans] = end;
	tokens[firsttoken+ntrans++] = nt;
	nt = 0;
	}

    *end = 0;
    returnrsp->trans = cmdstring(beg);

    if (pending) {
	tk = pending->tk;
	pending = pending->pending;
	bound = !pending;
#if trace_trans2
	printf("going to restart to process the pendings\n");
#endif
	goto restart;
	}
#if trace_trans2
    printf("trans2 returns returnrsp = %d '%s' ty %o from bottom of function\n",
	   returnrsp, returnrsp->trans, returnrsp->types);
#endif
    return returnrsp;
    }


/*  Add a possibly new state to the set of states anchored at head	*/
/*  There's a hash by the pn number to speed searching.			*/
/*  The new state will have zero or one kids.				*/
#define trace_addstate 0
static void addstate(name, set, new)
    char           *name;		/* name of calling function	 */
    int             set;		/* which stateset to mung	 */
    struct State    new;		/* state to add			 */
    {
    register struct State *s;
    register int    i;
    register unsigned long hix;
    char            bf[MAXREQLEN];
#if trace_addstate
    printf("\n/* %s adds new state ", name);
    dumpstate(&new, 0);
    printf("to S[%d]\n", set);
    fflush(stdout);
    printf("*/\n\n");
#endif
    if (!hashheads[set]) {
	hashheads[set] = (struct State **)
	       calloc((unsigned) sizeof(*hashheads[set]) * STATEHASH, (unsigned) 1);
	}

    /* Why are these what is used in the hash??? */
    hix = (unsigned long) new.pn + (unsigned long) new.dot +
	   (unsigned long) new.vk.kid + (unsigned long) new.left
	   + (unsigned long) new.constraints[0]
	   + (unsigned long) new.constraints[1]
	   + (unsigned long) new.constraints[2]
	   + (unsigned long) new.constraints[3]
	   + (unsigned long) new.constraints[4]
	   + (unsigned long) new.constraints[5]
	   + (unsigned long) new.constraints[6]
	   ;
#if trace_addstate
    printf("hix %d\n", hix);
#endif

    hix %= STATEHASH;
#if trace_addstate
    printf("hix after mod %d\n", hix);
#endif

    /* See if the new state is the same as or can be merged into an
       existing one.  If everything is the same except costs, use the
       cheaper.  If two multi-character lookaheads share a common prefix,
       discard the suffixes and merge them anyway. */

    for (s = hashheads[set][hix]; s; s = s->hashnext) {
	if (s->dot == new.dot && s->init == new.init && s->vk.kid == new.vk.kid && s->left == new.left) {
	    for (i = 0; i < MAXGLOBALS + MAXFREENONTERMS; i++)
		if (s->constraints[i] != new.constraints[i]) {
#if trace_addstate
		    printf("failed on constraint %d; %d != %d\n", i,
			   s->constraints[i], new.constraints[i]);
#endif
		    goto nexts;
		    }

		/* One is a final state while the other is not */
		if ((s->look == endstring) != (new.look == endstring)) {
#if trace_addstate
		    printf("failed on end != end ; %d != %d\n",
			s->look == endstring, new.look == endstring);
#endif
		    goto nexts;
		    }
		if (s->look != endstring) {
		    if (s->look[0] != new.look[0]) {
#if trace_addstate
			printf("failed on look[0] ; %d != %d\n", s->look[0], new.look[0]);
#endif
			goto nexts;
			}

		    for (i = 0; s->look[i] == new.look[i]; i++) {
			if (s->look[i] == 0)
			    goto same;
			}
		    /* shorten to the common prefix */
		    sprintf(bf, "%.*s", i, s->look);
		    s->look = string(bf);
#if trace_addstate
		    printf("shorted look to %s\n", s->look);
#endif
		    }
	    same:  ;
#if trace_addstate
	    printf("\n/* %s finds already ", name);
	    dumpstate(&new, 0);
	    printf("in S[%d]\n", set);
	    fflush(stdout);
	    printf("*/\n\n");
#endif

	    /* same cost, so merge them */
	    if (s->cost == new.cost) {
		s->types |= new.types;	/* if they cost the same, */
#if trace_addstate
		printf("/* merged types */\n");
#endif
		return;		/* add the new types */
		}

	    /* if they are of the same type(s), note the cheaper cost */
	    if (s->types == new.types) {
		if (new.cost < s->cost) {
#if trace_addstate
		    /* Tell people that we have found a cheaper */
		    /* alternative. Should this ever happen ??? */
		    printf("\n/* %s finds already ", name);
		    dumpstate(&new, 0);
		    printf("in S[%d], but the old cost was %f\n", set, s->cost);
		    fflush(stdout);
		    printf("*/\n\n");
#endif
		    s->cost = new.cost;
		    }
#if trace_addstate
		printf("/* dropped through */\n");
#endif
		return;
		}
	    }
	nexts:	;
	}

    s = Statealloc();
    *s = new;
    s->next = (struct State *) NULL;
#if trace_addstate
    printf("\n\n\n%s adds ", name);
    dumpstate(s, 0);
    printf("to S[%d]\n", set);
    fflush(stdout);
#endif
    /* We have to add at the end because we may be in the middle of a */
    /* loop which is processing this set */
    if (heads[set] == NULL)
	heads[set] = s;
    else
	tails[set]->next = s;
    tails[set] = s;
    s->adder = name;
    s->hashnext = hashheads[set][hix];
    hashheads[set][hix] = s;
#if trace_addstate
    printf("\nresulting state set:\n");
    for (s = heads[set]; s; s = s->next)
	dumpparse(s, 0);
    printf("\n\n");
#endif
    if (maxstate < set)
	maxstate = set;
    }

/*   add a state for each terminal in first(lookahead string gamma) to	*/
/*   the current set of states.	*/
predict(new, look1, look2)
    struct State    new;
    struct Toklist *look1;		/* first part of lookahead	 */
    char		*look2;		/* rest of lookahead 		 */
					 /* guaranteed to be a terminal	 */
    {
    struct Toklist *s;		/* next symbol in lookahead	 */
    struct Toklist *fir;
    int             nullable, ntn;
    register int    i;
    for (i = 0; i < MAXGLOBALS + MAXFREENONTERMS; i++) {
	new.constraints[i] = 0;
	}

    /* These are used in addstate for the hash, will this cause problems??? */
    new.vk.kid = NULL;
    new.left = NULL;
    for (s = look1; s; s = s->next) {
	if (isterminal(s)) {
	    new.look = s->text;
	    addstate("predict1", current, new);
	    return;
	    }
	ntn = ntlook(s->text, UNKNOWN);	/* get nonterminal # */

	nullable = 0;
	for (fir = firsts[ntn][side]; fir; fir = fir->next) {
	    if (fir->text == epsilon)
		nullable = 1;
	    else {
		new.look = fir->text;
		addstate("predict2", current, new);
		}
	    }
	if (nullable == 0)
	    return;
	}

    new.look = look2;
    addstate("predict3", current, new);
    }

dumpset(n)			/* dump every state in a set	 */
    {				/* of states			 */
    struct State   *s;
    for (s = heads[n]; s; s = s->next)
	dumpstate(s, 0);
    }

int eqchk(s)			/* check to see if this nonterminal */
    struct State   *s;		/* is already defined		 */
    {				/* => 0 if inconsistent		 */
    struct State   *t;		/* 1 for new definition	 */
    char           *x, *y;	/* 2 for consistent redef	 */


#if 0
    printf("\ncheck other defs of\n");
    dumpstate(s->vk.kid, 0);
    printf("\nin\n");
    dumpstate(s, 0);
    printf("\n\n");
#endif
    for (t = s->left; t->left; t = t->left) {
	if (t->left->dot->text == defs[s->vk.kid->pn->lhn].text) {
	    if(!(t->vk.kid = translate(t->vk.kid, -1, 0, 0, 0, __FILE__, __LINE__)))
		return 0;
	    if(!(s->vk.kid = translate(s->vk.kid, -1, 0, 0, 0, __FILE__, __LINE__)))
		return 0;
	    /* if for some reason, we cannot translate one, then say */
	    /* it is inconsistent(we cannot translate this alt then */
	    for (x = t->vk.kid->trans, y = s->vk.kid->trans; *x && *y; x++, y++) {
		if (ISVAR(x) && ISVAR(y) && conadd(s->constraints, VAR(x), terminals[VAR(y)])) {
		    x += VARLN - 1;
		    y += VARLN - 1;
		    continue;
		    }
		else if (*x == *y)
		    continue;
		else
		    return 0;
		}
	    if (*x != *y)
		return 0;
	    return 2;
	    }
	}
    return 1;
    }

typedef struct
    {
    char           *ptr;
    int             len;
    }               KEY;

typedef struct State *ITEM;

typedef struct splaytree
{
    KEY             key;
    ITEM            item;
    struct splaytree    *left, *right;
}               SPLAYTREE, SPLAYNODE;

cmpbuf(p, plen, q, qlen)	/* compare buffers	 */
    register char  *p, *q;		/* containing nulls	 */
    register        plen;		/* if they are = up to	 */
    int             qlen;		/* the length of the	 */
    {				/* shorter, the longer	 */
    register char  *plim;	/* one is bigger	 */
    int             lres;
    lres = plen - qlen;		/* length result */
    if (lres > 0)
	plen = qlen;		/* minimum length */
    plim = p + plen;		/* last char */
    do {
	if (p == plim)
	    return lres;	/* whichever is short */
	} while ((char) *p++ == (char) *q++);
    return (char) p[-1] - (char) q[-1];
    }


#define LESS(l,r) (cmpbuf((l).ptr, (l).len, (r).ptr, (r).len) < 0)
#define EQUAL(l,r) (cmpbuf((l).ptr, (l).len, (r).ptr, (r).len) == 0)
#define MATCH(l,r) (cmpbuf((l).ptr, (l).len, (r).ptr, (l).len) == 0)
extern SPLAYTREE    *insert();
/* Top-down splay trees

   O(n) inserts and joins, and O(m) deletes, accesses, and splits,
   in worst-case time O((m + n) log n).  See Sleator and Tarjan,
   "Self-adjusting binary search trees," _JACM_ 32:3 (July 1985), 652-686.

   John Kececioglu
   December 1987     Implemented algorithms.
*/


#define	NIL ((SPLAYNODE *) 0)
#define	FREE(node)   { (node)->left = avail; avail = (node); }

static SPLAYNODE    *avail = NIL, *splaynode(), *splay();
/* insert -- insert item into splaytree not containing key */
SPLAYTREE *insert(i, k, t)
    ITEM            i;
    KEY             k;
    register SPLAYTREE  *t;
    {
    if (t == NIL)
	return splaynode(i, k, NIL, NIL);

    t = splay(t, k);
    if (LESS(t->key, k)) {
	t = splaynode(i, k, t, t->right);
	t->left->right = NIL;
	}
    else {				/* k < t->key */
	t = splaynode(i, k, t->left, t);
	t->right->left = NIL;
	}
    return t;
    }


 /* splay -- splay non-empty splaytree around key */
static SPLAYNODE    *splay(t, k)
    SPLAYTREE           *t;
    KEY             k;
    {
    static SPLAYNODE     null;
    register SPLAYNODE  *l, *r, *s;
    for (l = r = null.left = null.right = &null;;) {
	if (LESS(k, t->key) && (s = t->left) != NIL)
	    if (LESS(k, s->key) && s->left != NIL) {
		t->left = s->right;
		s->right = t;	/* rotate right */
		r = r->left = s;
		t = s->left;	/* link right */
		}
	    else if (LESS(s->key, k) && s->right != NIL) {
		r = r->left = t;/* link right */
		l = l->right = s;
		t = s->right;	/* link left */
		}
	    else {
		r = r->left = t;
		t = s;		/* link right */
		}
	else if (LESS(t->key, k) && (s = t->right) != NIL)
	    if (LESS(k, s->key) && s->left != NIL) {
		l = l->right = t;	/* link left */
		r = r->left = s;
		t = s->left;	/* link right */
		}
	    else if (LESS(s->key, k) && s->right != NIL) {
		t->right = s->left;
		s->left = t;	/* rotate left */
		l = l->right = s;
		t = s->right;	/* link left */
		}
	    else {
		l = l->right = t;
		t = s;		/* link left */
		}
	else
	    break;
	}
    if (l != &null) {
	l->right = t->left;
	t->left = null.right;
	}
    if (r != &null) {
	r->left = t->right;
	t->right = null.left;
	}
    return t;
    }

/* splaynode -- create a splaynode */
static SPLAYNODE    *splaynode(item, key, left, right)
    ITEM            item;
    KEY             key;
    SPLAYNODE           *left, *right;
    {
    register SPLAYNODE  *n;
    if (avail) {
	n = avail;
	avail = avail->left;
	}
    else if ((n = (SPLAYNODE *) malloc((unsigned) sizeof(SPLAYNODE))) == NULL) {
	cerror("Cannot allocate a splay tree node.\n");
	}
    n->item = item;
    n->key = key;
    n->left = left;
    n->right = right;
    return n;
    }


#define MAXSP 8000
static          nsps;

char *buybuf(p, len)		/* allocate memory and copy a	 */
    char           *p;		/* structure.			 */
    unsigned        len;
    {
    char           *result;
    result = malloc(len);
    if (!result)
	cerror("no memory for buybuf");
    memcpy(result, p, len);
    return result;
    }

static void cpysp(sp, q)		/* copy all states in this set */
    struct State   *sp, **q;		/* into a vector.	*/
    {
    for (nsps = 0; sp; sp = sp->next, nsps++) {
	if (nsps >= MAXSP)
	    cerror("too many sps");
	sp->trans = buybuf(sp->trans, (unsigned)(strlen(sp->trans) + 1));
	sp = (struct State *)buybuf((char *)sp, (unsigned)sizeof(struct State));
	q[nsps] = sp;
	}
    }

static compcost(r1, r2)		/* compare costs for sorting	 */
    struct State  **r1, **r2;	/* alternative translations	 */
    {
    return (*r1)->cost - (*r2)->cost;
    }

/*  This routine puts a cache on the front of parse or canonparse */
struct State   *newinst2(txt, parser)	/* parse an rt and return all translations */
    register char  *txt;	 	/* input string */
    struct State *(*parser)();		/* parse (in comb) or canonparse (in cchop) */
    {
    static SPLAYTREE    *tree, *r;
    KEY             key;
    struct State   *q[MAXSP];
    struct State   *p;
    register int    i;
#if 0
    printf("/* newinst2 '%s' len %d tree %d => */\n", txt, strlen(txt), tree);
#endif

    key.len = strlen(txt) + 1;	/* include those terminators! */
    key.ptr = txt;

    if (tree != NIL) {
	r = tree = splay(tree, key);	/* look up our key.	 */

	if (LESS(key, tree->key) && tree->left) {
	    r = tree->left;
	    while (r->right)
		r = r->right;
	    }
	/* check for an invalid prefix	 */
#if 0
	printf("/* found %s '%.*s' len %d */\n",
	       r->item == NULL ? "bogus prefix" : "valid parse",
	       r->key.len, r->key.ptr, r->key.len);
#endif

	if (r->item == NULL && MATCH(r->key, key)) {
#if 0
	    printf("/* found bogus prefix '%.*s' len %d */\n",
		   r->key.len, r->key.ptr, r->key.len);
#endif
	    return NULL;
	    }
	/* check for a valid register transfer	 */
	if (r->item != NULL && EQUAL(r->key, key)) {
#if 0
	    printf("/* thats good */\n");
#endif
	    return r->item;
	    }
	}
#if 0
    printf("/* not found -- parsing --  */");
#endif
    inittrans();

    /*  11/17/93 
     *  If cchop uses parse instead of canonparse, it calculates incorrect rt
     *  for 'move(add(m(r(%06,4),l,4),r(%07,4),l),m(m(add(%00,ap,l),l,4),l,4),l)', translating
     *  it into assem 'addl3 (%06),%07,*%00(ap)'.
     *  This does not match the version that comb gets, which causes the cost for this instruction
     *  to be evaulated at 999999, and 2 versions of this instruction get installed, which inhibits
     *  optimizations.
     *  p = parse((char *)txt, 1);
	TEST CASE: run cchop on this optimization and see what costs you get for the input instructions.
	# line 130
	"KK"
	;;%02.str==%03.str
	;:%04.str=="1"
	move(%04,r(%01,4),l)	# 807
	movl $%04,%01
	{6,7,6,6,0,1,0,0,0,0,0,0,0,0,0,0,4095,0,0,0,0,0,5,}
	move(m(add(%03,ap,l),l,4),r(%00,4),l)	# 807
	movl %03(ap),%00
	{6,7,6,6,0,1,0,0,0,0,0,0,0,0,0,0,4095,0,0,0,0,0,5,}
	move(add(m(r(%00,4),l,4),r(%01,4),l),m(m(add(%02,ap,l),l,4),l,4),l)	# 1808
	addl3 %00,(%01),*%02(ap)
	{8,8,6,8,0,1,5,0,0,0,0,0,0,0,0,0,4095,4095,0,0,0,0,5,}
	=
	move(add(m(m(add(%02,ap,l),l,4),l,4),%04,l),m(m(add(%02,ap,l),l,4),l,4),l)	# 1006
	incl *%02(ap)
	{6,6,6,6,0,2,5,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,}

     */
    p = ((*parser)((char *)txt, 1));
    cpysp(p, q);
    if (nsps) {
	for (i = 0; i < nsps; i++)
	    q[i]->allocl = q[i]->left->vk.kid->pn->allocl;
	qsort(q, nsps, sizeof(q[0]), &compcost);
	for (i = 0; i < nsps - 1; i++)
	    q[i]->next = q[i + 1];
	q[nsps - 1]->next = (struct State *) NULL;
	p = q[0];
	key.ptr = (char *) buybuf((char *) txt, (unsigned) key.len);
#if 0
	printf("/* ok! */\n");
#endif
	}
    else {
	key.len = maxstate + 1;	/* len of losing prefix	 */
	key.ptr = (char *) buybuf((char *) txt, (unsigned) key.len);
#if 0
	printf("/* bogus! */\n");
	printf("/* insert bogus prefix '%.*s' */\n", key.len, key.ptr);
#endif
	}

    tree = insert(p, key, tree);/* insert into tree		 */
#if 0
    printf("/* insert returns %d */\n", tree);
#endif
    return p;
    }


/*  Translate rt->assembly or vice-versa.
 *  Assumes that we have a canonical asmbf coming in.
 *  We will make the parse canonical also (move free nonterms)
 */
struct State *canonparse(asmbf, whichway)
    char           *asmbf;
    int		   whichway;	/* 1 = rt->assembly */
    {
    struct State   *p, *r;
    struct patrec  *pat;
    register int    newvar, neweqvar;
    int		    oldvar, oldeqvar;
    char           *newconstraints[MAXGLOBALS + MAXFREENONTERMS];
    inittrans();
    p = parse((asmbf), whichway);

    for (r = p; r; r = r->next) {
#if 0
	printf("before: %s ", r->trans);
	for (newvar = 0; newvar < MAXGLOBALS + MAXFREENONTERMS; newvar++)
	    if (r->constraints[newvar])
		printf("%%%02d=%s ", newvar, r->constraints[newvar]);
	printf("\n");
#endif
	/* canonicalize the translation */
	pat = cvtpatt((struct Optrec *)NULL,
	    whichway ? asmbf : r->trans,
	    whichway ? r->trans : asmbf, 1);
#if 0
	printf("after cvtpatt: '%s' '%s'\n", pat->assem, pat->p_rt);
#endif
	/* copy the canonicalization back into the trans */
	strcpy(r->trans, whichway ? pat->assem : pat->p_rt);

	/* Move constraints to their new locations.  */
	for (newvar = 0; newvar < MAXGLOBALS + MAXFREENONTERMS; newvar++)
	    newconstraints[newvar] = (char *) NULL;

	for (newvar = 0; newvar < MAXGLOBALS + MAXFREENONTERMS; newvar++) {
#if 0
	    if (r->constraints[oldvar]) {
		printf("r->constraints[%d]=%s\n", newvar, r->constraints[newvar]);
		}
#endif
	    oldvar = pat->map[newvar];
	    if (oldvar != NOVAR) {
		if (r->constraints[oldvar] && ISVAR(r->constraints[oldvar])) {
		    oldeqvar = VAR(r->constraints[oldvar]);
		    for (neweqvar = 0; neweqvar < MAXGLOBALS + MAXFREENONTERMS;
			neweqvar++) {
			if (pat->map[neweqvar] == oldeqvar) {
			    newconstraints[newvar] = terminals[neweqvar];
			    goto found;
			    }
			}
		    cerror("canonparse: cannot map %%%d=%s\n",
			oldvar, r->constraints[oldvar]);
#if 0
		    printf("new[%d] := %s\n", oldvar, newconstraints[oldvar]);	
#endif
		    }
		else {
		    newconstraints[newvar] = r->constraints[oldvar];
#if 0
		    printf("new[%d] := %s\n", oldvar, newconstraints[oldvar]);	
#endif
		    }
		}
	    found:;
	    }

	for (newvar = 0; newvar < MAXGLOBALS + MAXFREENONTERMS; newvar++)
	    r->constraints[newvar] = newconstraints[newvar];
#if 0
	printf("after: %s ", r->trans);
	for (newvar = 0; newvar < MAXGLOBALS + MAXFREENONTERMS; newvar++)
	    if (r->constraints[newvar])
		printf("%%%02d=%s ", newvar, r->constraints[newvar]);
	printf("\n\n\n");
#endif
	}
    return p;
    }


/*  The semantic routine is called with a pointer to a final state of the form
 *
 *  C -> E F G .
 *
 *  It's job is to synthesize type information from
 *  the state's predecessors' final kids, e.g.
 *
 *   C -> . E F G
 *          E -> a b c .
 *
 *   C -> E . F G
 *            F -> d e f .
 *
 *   C -> E F . G
 *              G -> g h i .
 *
 *  (for the nonterminals E, F, G.  Terminals are ignored.)
 *  and to leave the information in the final state.
 *
 *
 *  The type word of the defiens (and of the result of the operation) is
 *  obtained by intersecting the type bits of some of the nonterminals in
 *  the definition (those whose tkclass is TKCLASS_OUTPUT), plus the type_bits
 *  field from the production.
 *
 *  This routine is used to implement the following semantic actions:
 *
 *  def:              Intersect type bits from all nt's in the definition.
 *
 *  set(nonterminal): set the result's type bits from a particular nt in the
 *                    definition.  The nt must appear in the definition!
 *
 *  set(typename):    set the result's type bits to those of the named type.
 * 
 *  All declared types such as "b", "d", "bwl":
 *                    intersects the type bits for the declared type and
 *                    all of the type bits of the other nonterminals in the
 *                    definition.
 *  deref(name,..)    names can be typenames or nt names.
 *		      The destination type is obtained by intersecting the
 *		      types of all mentioned nt's and typenames.  The source
 *		      type is obtained by intersecting the types of all
 *		      unmentioned nt's.
 *  For example
 *      inst := xxx, move(cvt(src,srctype,dsttype),dst,dsttype),
 *						deref(dst,dsttype).
 *
 *  Another example, Vax movab (or movaw, moval) instruction:
 *      inst := mova%t %inx,%z, move(x,z,type_l), deref(z,type_l).
 *
 *  In this example, the "source's" address is moved rather than the source
 *  itself.  So t's type must be consistent with x's, and z's type must be
 *  consistent with "type_l".
 *
 *  In the call instruction
 *      inst := "call %inx", move(call(inx,l,0,t),dest), deref(t,dest)
 *  the inx and l nonterminals must have the same type (ie inx must be a long
 *  address) and the destination register and t must have the same type.
 *
 *  The class of the token (input, output, or non-participant) is held in
 *  "tkclass".  tkclass is set when the md grammar is read in and processed.
 *  For example, the "deref(z,type_l)" notation above will cause the types of
 *  z and type_l to be intersected, and the type of the result (and of z and
 *  type_l) will be set to the intersection.
 *
 *  It is necessary to use the nonterminal type_l in this example, because "l"
 *  is a terminal and terminals carry no types.
 */
static unsigned long semantics(lastsp)
    struct State	*lastsp;
    {
    struct State	*q;
    unsigned long 	dstty = lastsp->pn->type_bits;
    unsigned long	srcty = -1;

    for (q = lastsp; q->left; q = q->left) {
	if (q->left->dot->tkclass == TKCLASS_OUTPUT)
	    dstty &= q->vk.kid->types;
	else if (q->left->dot->tkclass == TKCLASS_INPUT)
	    srcty &= q->vk.kid->types;
	}

    lastsp->types = dstty;

    /* I think that these translate calls are unecessary
    if (dstty && (dstty & dstty - 1) == 0) {
	for (q = lastsp; q->left; q = q->left) {
	    if (q->left->dot->tkclass == TKCLASS_OUTPUT) {
		    q->vk.kid = translate(q->vk.kid, dstty, 0, 0, 0, __FILE__,__LINE__);
		    }
		}
	    }

    if (srcty && (srcty & srcty - 1) == 0) {
	for (q = lastsp; q->left; q = q->left) {
	    if (q->left->dot->tkclass == TKCLASS_INPUT) {
		    q->vk.kid = translate(q->vk.kid, srcty, 0, 0, 0, __FILE__,__LINE__);
		    }
		}
	    }
    */

    return (srcty) ? dstty : 0;
    }

