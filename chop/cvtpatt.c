/* You have this code because you wanted it now rather than correct.
 * Bugs abound!  Contact Alan Wendt for a later version or to be
 * placed on the chop mailing list.  Parts are missing due to licensing
 * constraints.
 *
 * Alan Wendt / Computer Science / Colorado State Univ. / Ft Collins CO 80523
 * 303-491-7323.  wendt@cs.colostate.edu
 */
#include <ctype.h>
#include <stdio.h>
#include "c.h"
#include "hop2.h"
#include "md.h"

#define MAXPATS 60000*sizeof(struct patrec)+20000
#define MAXCONS ((int)((MAXGLOBALS+MAXFREENONTERMS)*1.5))

char patterns[1], *patp = patterns;

static int rclass;
static getfield();

/*  lcc has forced a change in variable numbering conventions.
 *  Symbols are now sequentially numbered beginning at %00.
 *  Kids begin at %dd = MAXSYMS.
 *  Results begin where the kids leave off.  Any variables that are
 *  both kids and result, overlap both kids and results.
 *  These changes effect kidlb, kidub, reslb, resub, varlb, and varub.
 */


/*  get the name of the register denoted by a variable in a register transfer */
getregname(rt, var, to)
    char	*rt;
    int		var;
    char	*to;
    {
    char	*p;

#if 0
    printf("getregname of %%%d in rt '%s' => ", var, rt);
#endif
    *to = 0;
    for (p = rt; *p; p++) {			/* search for the variable */
	if (ISVAR(p) && VAR(p) == var) {
	    for (;p >= rt; p--) {		/* search back to the regname */
		if (regvarb(p) == var) {
		    sprintf(to, "%.*s", strlen(regpatts[rclass].rt), p);
#if 0
		    printf("%s\n", to);
#endif
		    return 1;
		    }
		}
#if 0
	    printf("fails at line %d\n", __LINE__);
#endif
	    return 0;
	    }
	}
#if 0
    printf("fails at line %d\n", __LINE__);
#endif
    return 0;
    }

regvarb(os)			/* if s begins a register exp	*/
    char *os;			/* return the variable number	*/
    {
    int		v;
    char	*p, *s;
#if 0
    printf("/* regvarb %s => ", os);
#endif
    for (rclass = 0; rclass < NOREG; rclass++) {
	p = regpatts[rclass].rt;	/* next register pattern	*/
	s = os;
	v = NOVAR;
	for (;;) {
	    if (*p == 0 && v != NOVAR)		/* got entire register name */
		{
#if 0
		printf("%02d */\n", v);
#endif
		return v;
		}
	    else if (ISVAR(p) && ISVAR(s) && VAR(p) == FIRSTVAR) {
		v = VAR(s);			/* remember variable number */
		p += VARLN;
		s += VARLN;
		}
	    else if (*p != *s) break;
	    p++;
	    s++;
	    }
	}
#if 0
    printf("%d */\n", v);
#endif
    return NOVAR;
    }

getresultype(s)
    char	*s;
    {
    int		t;
    t = setslvar(s);
    return (t == NOVAR) ? NOREG : regtype(s, t);
    }

/*  Does this register transfer set this variable? */
test_setslvar(s,c)
    char	*s;
    int          c;
    {
    char dst[MAXRTLINE], src[MAXRTLINE], type[MAXRTLINE];
    char *indx;

    for (indx = s; indx = gtds(indx, dst, src, type);) {
#if 0
	printf("/* setslvar %s => %s */\n", s, dst);
#endif
	if (regvarb(dst) == c)
	    return 1;
	}
    return 0;
    }

setslvar(s)		/* determine local var set by pattern		*/
    char	*s;
    {
    char dst[MAXRTLINE], src[MAXRTLINE], type[MAXRTLINE];
#if 0
    printf("/* setslvar %s => %%%02d */\n",
	s, (gtds(s, dst, src, type)) ? regvarb(dst) : NOVAR);
#endif
    return (gtds(s, dst, src, type)) ? regvarb(dst) : NOVAR;
    }

#define trace_regtype 0
regtype(rt, l)			/* if l is a reg # in rt	*/
    char	*rt;	/* return the regtype number	*/
    {
    register int	i;
    register char	*p, *s;
    char		*q;
    char		*ort = rt;


#if trace_regtype
    printf("/* regtype(%s,%d) => ", rt, l);
#endif
    for (;*rt; rt++) {
	
	if (ISVAR(rt) && VAR(rt) == l) {

	    /*  for each type of register that could rt here	*/
	    for (i = 0; i < NOREG; i++) {

		/*  find "%00" in register pattern */
		for (q = regpatts[i].rt; *q; q++)
		    if (ISVAR(q) && VAR(q) == FIRSTVAR) goto gotreg;

		cerror("regtype: bad pattern %s", regpatts[i].rt);

		/* look forward from the variable */
		gotreg:
		for (p=q+VARLN,s=rt+VARLN;*p;p++, s++) {
		    if (*p != *s) goto nextreg;	/* not this register */
		    }

		/* look backward from the variable */
		for (p = q - 1, s = rt - 1; p >= regpatts[i].rt; p--, s--) {
		    if (*p != *s) goto nextreg;	/* not this reg */
		    }

		if (s < ort || !isalpha(*s)) {
#if trace_regtype
		    printf("%d */\n", i);
#endif
		    return i;
		    }
		nextreg: ;
		}
	    }
	}
#if trace_regtype
    printf("NOREG=%d */\n", NOREG);
#endif
    return NOREG;
    }

static char *allonames[20];
static int nallonames;
int alloclassindex(name)
    char	*name;
    {
    int i;

    for (i = 0; i < nallonames; i++)
	if (name == allonames[i])
	    return i;
    if (nallonames == nelts(allonames))
	cerror("too many allocation classes\n");
    allonames[nallonames] = name;
    return nallonames++;
    }
   
   
dump_alloclasses()
    {
    int i;
    FILE	*f;

    f = fopen("../chop/allocl.h", "w");
    if (!f) {
	cerror("cannot open ../chop/allocl.h\n");
	}
    fprintf(f,"enum Alloclasses { ");
    for (i = 0; i < nallonames; i++)
	fprintf(f,"%s, ", allonames[i]);
    fprintf(f," };\n\n\n");
    fclose(f);
    }


readslvar(s, l)			/* determine if pattern reads local var	*/
    char	*s;
    int		l;
    {
    char dst[MAXRTLINE], src[MAXRTLINE], type[MAXRTLINE];
    if (!gtds(s, dst, src, type)) SAFESTRCPY(src, s);
    for (s = src; *s; s++)		/* is it part of source?	*/
	if (ISVAR(s) && VAR(s) == l) return 1;
    if (regvarb(dst) == l) return 0;	/* not the dst?			*/
    for (s = dst; *s; s++)		/* used to address dest?	*/
	if (ISVAR(s) && VAR(s) == l) return 1;
    return 0;
    }

setsvar(p)		/*  determine if this pattern sets a variable	*/
    struct patrec *p;
    {
    int i;
    return ((i = setslvar(p->p_rt)) != NOVAR) ? p->map[i] : NOVAR;
    }

#define ASSIGN_VAR() \
    if (map[c] == NOVAR) { \
	map[c] = n; \
	if (n >= MAXSYMS+MAXKIDS) { \
	    return NULL; \
	    } \
	n++; \
	}

/*  cvtpatt - convert one pattern to internal form.  See the comments at
 *  the top of the file about the canonical variable numbering.
 */
#define trace_cvtpatt 0
struct patrec *cvtpatt(o, lin, assm, assm_first)
    struct Optrec	*o;
    char		*lin, *assm;
    int			assm_first;		/* allocate vars in assm string first */
    {						/* so that intermediate strings determine ordering */
    register		c;
    char		*lp, bf[MAXRTLINE];
    signed char		map[MAXGLOBALS+MAXFREENONTERMS];
    register char	*s;
    int16		locv, n, i, globv;
    static struct patrec	p;	/* static result area */
    char		*np;
    static char		rt[MAXRTLINE];

#if trace_cvtpatt
    printf("/* cvtpatt '%s' assm_first %d assm '%s' ", lin, assm_first, assm);
#endif
    bzero(&p, sizeof(p));

    p.p_rt = rt;
    for (locv = 0; locv < MAXGLOBALS+MAXFREENONTERMS; locv++)
	p.map[locv] = NOVAR;

    SAFESTRCPY(bf, lin);		/* don't change the input	*/
    lin = bf;

    /*  remove a trailing comment, consisting of some nonzero number of	*/
    /*	tabs or spaces followed by # followed by anything.	*/
    for (i = 0; lin[i]; i++) {
	if ((lin[i] == '\t' || lin[i] == ' ') && lin[i + 1] == '#') {
	    while (lin[i - 1] == '\t' || lin[i - 1] == ' ') i--;
	    lin[i] = 0;
	    break;
	    }
	}

    /*  Move all requirements into the optimization record */
    if (o) {
	while (s = lastreq(lin + REQPREFLEN)) {
	    addreq(o->o_reqs, s, 0, __FILE__, __LINE__);
	    *s = 0;
	    }
	}

    /*	Renumber variables in the line starting from FIRSTVAR, and remember
     *  the new variable number in the map vector.  Map[i]
     *	contains the new var character for the old variable %i.
     *  The result if any gets var zero, then come kids, and finally
     *  constants.
     */
    for (globv = 0; globv < nelts(map); globv++)
	map[globv] = NOVAR;

    /*	add non-kid variables from the assembly string to the map */
    p.p_varlb = n = FIRSTVAR;
    if (assm && assm_first) {
	for (lp = assm; *lp; lp++) {
	    if (ISVAR(lp) && (c = VAR(lp)) < MAXGLOBALS+MAXFREENONTERMS && regtype(lin, c) == NOREG) {
		ASSIGN_VAR()
		}
	    }
	}
    p.p_varub = n;

    /*	Assign numbers for input registers that are not results */
    p.p_kidlb = n = FIRSTKID;			/* start inputs */

    /*  If the intermediate code string comes in as ASGNI %06,%07 we want it
     *  to stay that way and not get reversed because the rt mentions r(%07)
     *  first.  Scanning the assembly language string first arranges this.
     */
    if (assm && assm_first) {
	for (lp = assm; *lp; lp++) {
	    if (ISVAR(lp) && regtype(lin, c = VAR(lp)) != NOREG &&
		c < MAXGLOBALS+MAXFREENONTERMS && readslvar(lin, c) &&
		!test_setslvar(lin, c)) {
		ASSIGN_VAR()
		}
	    }
	}

    for (lp = lin; *lp; lp++) {
	if (ISVAR(lp) && regtype(lin, c = VAR(lp)) != NOREG &&
	    c < MAXGLOBALS+MAXFREENONTERMS && readslvar(lin, c) &&
	    !test_setslvar(lin, c)) {
	    ASSIGN_VAR()
	    }
	}

    if (assm && !assm_first) {
	for (lp = assm; *lp; lp++) {
	    if (ISVAR(lp) && regtype(lin, c = VAR(lp)) != NOREG &&
		c < MAXGLOBALS+MAXFREENONTERMS && readslvar(lin, c) &&
		!test_setslvar(lin, c)) {
		ASSIGN_VAR()
		}
	    }
	}

    p.p_reslb = n;

    /*  Assign numbers for result registers that are also inputs */
    for (lp = lin; *lp; lp++)
	if (ISVAR(lp) && regtype(lin, c = VAR(lp)) != NOREG &&
	    c < MAXGLOBALS+MAXFREENONTERMS && readslvar(lin, c) &&
	    test_setslvar(lin, c)) {
	    ASSIGN_VAR()
	    }

    p.p_kidub = n;

    /*	Assign numbers for the result registers that are not also inputs */
    for (lp = lin; *lp; lp++) {
	if (ISVAR(lp) && regtype(lin, c = VAR(lp)) != NOREG &&
	    c < MAXGLOBALS+MAXFREENONTERMS &&
	    !readslvar(lin, c) && test_setslvar(lin, c)) {
	    ASSIGN_VAR()
	    }
	}

    p.p_resub = n;

    /*	Assign numbers for all other variables, and copy into rt. */
    n = p.p_varub;
    for (lp = lin, np = p.p_rt; *lp;) {
	if (ISVAR(lp) && (c = VAR(lp)) < MAXGLOBALS+MAXFREENONTERMS) {
	    ASSIGN_VAR()
	    SETVAR(np, map[c]);
	    np += VARLN;
	    lp += VARLN;			/* point past %n	*/
	    }
	else *np++ = *lp++;
	}

    p.p_varub = n;
    *np = 0;

    /*	add extra variables from the assembly string to the map */
    if (assm) {
	strcpy(bf, assm);
	for (lp = bf; *lp;) {
	    if (ISVAR(lp) && (c = VAR(lp)) < MAXGLOBALS+MAXFREENONTERMS) {
		/* assign new local var #	*/
		ASSIGN_VAR()
		SETVAR(lp, map[c]);
		lp += VARLN;	/* point past %n	*/
		}
	    else lp++;
	    }
	p.p_varub = n;
	p.assem = string(bf);
	}

    /*  Invert the map so that p->map[i] contains the old variable number
     *  corresponding to the new variable %i, or NOVAR.
     */
    for (globv = 0; globv < MAXGLOBALS+MAXFREENONTERMS; globv++)
	if (map[globv] != NOVAR) p.map[map[globv]] = globv;

#if trace_cvtpatt
    printf("result rt '%s' assm '%s' Kids %d-%d Results %d-%d Vars %d-%d */\n",
	p.p_rt, p.assem,
	p.p_kidlb, p.p_kidub, p.p_reslb, p.p_resub, p.p_varlb, p.p_varub);
#endif
    return &p;
    }

/* gtstr - get string specified by start and end */
gtstr(start, end, dst)
    register char *start, *end, *dst;
    {
    while (start < end) *dst++ = *start++;
    *dst = '\0';
    }

/* gtds - get type, destination, and source of register transfer */
/* If the rt does not start with either par(move(..)) or move(..),
   this routine returns NULL strings for the destination, source, 
   and type and also returns a NULL pointer. 
   If there is a comma after the move(..) point to the character after
   the comma, otherwise point at the tail right parentheses.
   Is this what we want???
*/
/*  par(move(add(r(%01,4),r(%02,4),int),r(%02,4),l),
    move(code(add(r(%01,4),r(%02,4),int),0,int),cc,b))
    Successive calls return successive submoves of the par, if there is one
*/
char *gtds(rt, dst, src, type)
    char		*rt;
    char		*dst, *src, *type;	/* pointers to result buffers */
    {
    *dst = *src = *type = 0;
    if (!strncmp(rt, "par(", 4)) rt += 4;	/* skip the "par("	*/
    if (strncmp(rt, "move(", 5)) return 0;	/* not a move		*/
    rt += 5;					/* skip over the move	*/
    getfield(&rt, src);				/* get source		*/
    rt++;					/* skip comma		*/
    getfield(&rt, dst);				/* get destination	*/
    rt++;					/* skip comma		*/
    getfield(&rt, type);			/* get type		*/

    /*  handle par(move(),move(),move()) correctly */
    if (rt[0] == ')' && rt[1] == ',')
	return rt + 2;
    else return rt;
    }

 /*  Get the front-end type of the result of this instruction. */
gettypename(rt)
    char              *rt;
    {
    char      src[MAXRTLINE], dst[MAXRTLINE], type[MAXRTLINE];
    gtds(rt, dst, src, type);
#if 0
    printf("/* gettypename(%s) type %s */\n", rt, type);
#endif
    switch (*type) {
	case 'f': return F;
	case 'l': return I;
	case 'd': return D;
	case 'u': return U;
	case 'w': return S;
	case 'b': return C;
	default:  return B;
	}
    }

/* Get a field from a rt.  After we get the field, we update our source
   pointer to point right beyond the field and put a NULL at the end of
   the destination.  Note that the destination needs to be large enough
   to hold the field.  A field is defined by containing balanced parens
   and is delimited by ,'s and/or )'s.  Note that we check for the end of
   string, but do not do anything if we have unbalanced parens at that
   point.  Is this guaranteed at this point???
   Currently, this routine is only called from gtds(right above).
*/
static getfield(psrc, dst)			/* get a field, update	*/
    char **psrc;
    register char *dst;				/* pointers		*/
    {						/* psrc points to src	*/
    register char	*src = *psrc;		/* pointer.  dst points	*/
    register int	parens = 0;		/* to destination.	*/
    register int	c;
    while ((c = *src) && (parens > 0 || c != RPAR && c != ',')) {
	if (c == RPAR) parens--;		/* Copy till we get a	*/
	else if (c == LPAR) parens++;	/* comma or right par	*/
	*dst++ = *src++;			/* and the parens	*/
	}					/* are balanced.	*/
    *dst = 0;
    *psrc = src;
    }

char *isvar(s, result)				/* if s begins %dd    	*/
    register char	**s, *result;		/* then copy to result	*/
    {						/* and return pointer	*/ 
    if (ISVAR(*s)) {
	strncpy(result, *s, VARLN + 4);		/* "%x.str" or "%x.kid" */
	result[VARLN + 4] = 0;                  /* or %x.num hopefully! */
	(*s) += VARLN + 4;
	return result;
	}
    return 0;
    }

/* fmatch - fast matcher no metacharacters */
char		*bpos, *epos;	/* begin & end of match		*/
char *fmatch(lin, pat)
register char *lin;
register char *pat;
    {
    register char *a, *b;

    while (*lin) {
	b = lin++;
	a = pat;
	while (*a++ == *b++)
	    if (*a == '\0') {
		bpos = lin - 1;
		epos = b;
		return bpos;
		}
	}
    return 0;
    }

/* sub - substitute str in lin for string defined by bpos and epos	*/
char *sub(lin, str)
    char *lin, *str;
    {
    char new[MAXREQLEN];
    register char *a, *b = new, *c;

    for (a = lin; a < bpos;) *b++ = *a++;	/* copy prefix		*/
    for (c = str; *b++ = *c++;) ;		/* copy string		*/
    b--;
    for (c = epos; *b++ = *c++;) ;		/* copy suffix		*/
    for (a = lin, b = new; *a++ = *b++;) ;	/* copy back		*/
    return bpos + strlen(str);			/* restart scan here	*/
    }

scan(s, string)
    char		**s;
    register char	*string;
    {
    register char	*t;
    for (t = *s; *string ;) {
	if (*t++ != *string++) return 0;
	}
	*s = t;
	return 1;
    }

/*  Check if the var is determined by requirements of the form		*/
/*  %01.str==stringd(atoi(%02.str)+4+atoi(%03.str)*atoi(%04.str))	*/
/*  %01==%02+4+%03*%04, where the vars on the right are determined by	*/
/*  the input or constant.  Returns a character string of C code to get */
/*  the	value for the var on the left.					*/
/*  When converting these strings to C, numbers are left alone.		*/
/*  Variables are turned into char pointers to the var texts, and must be    */
/*  atoi()'ed explicitly to do arithmetic.				*/
/*  So the example above should read					*/
/*  %01.str==stringd(atoi(%02.str)+4+atoi(%03.str)*atoi(%04.str))	*/
char *bound(reqs, v, r)
    char		*reqs, *v, *r;		/* reqs and name	*/
    {
    int			l = strlen(v) + 2;
    char		*p;

#if 0
    printf("\n\nbound('%s',\n'%s')\n\n", reqs, v);
#endif
    retry:
    sprintf(r, "%s==", v);			/* look for reqs of the	*/
    if (fmatch(reqs, r)) {			/* form var==x;		*/
	p = index(bpos + l, ';');		/* and return x		*/
	if (p == NULL) p = endof(bpos);
	strncpy(r, bpos + l, p - bpos - l);	/* copy x to r		*/
	r[p - bpos - l] = 0;
	if ((p - bpos - l) == (VARLN + 4)	/* %01.str==%02.str is	*/
				&& ISVAR(r)){	/* useless		*/
				reqs = bpos + 1;
				goto retry;
				}
#if 0
	printf("bound returns %s\n\n", r);
#endif
	return r;
	}
#if 0
    printf("bound returns nil\n\n");
#endif
    return 0;
    }

static struct Constraint constraints[MAXCONS];
static int ncons;

static change(old, new, except)		/* change old to new		*/
    char *old, *new;			/* in all cons except one	*/
    {
    char *p;
    int i, result = 0;
    for (i = 0; i < ncons; i++) {
	if (i != except)
	    for (p = constraints[i].text; p = fmatch(p, old); p++) {
		sub(constraints[i].text, new);
		constraints[i] = parsecon(constraints[i].text);
		result++;
		}
	}
    return result;
    }

static dumpconstraint(i, csubi)
    int		i;
    struct Constraint csubi;
    {
    printf("/* constraints[%d] type %c v0 %s v1 %s vbound %d text %s */\n",
	i,
	csubi.ty,
	csubi.v0 ? csubi.v0 : "Null",
	csubi.v1 ? csubi.v1 : "Null",
	csubi.vbound,
	csubi.text);
    }

/*  simplify the constraints vector */
#define trace_simpcon 0
static simpcon()
    {
    int		i, j;
    long		bound;

#if trace_simpcon
    printf("simpcon:\n");
    for (i = 0; i < ncons; i++) {
	dumpconstraint(i, constraints[i]);
	}
#endif

    retry:

    for (i = 0; i < ncons; i++) {
	switch(constraints[i].ty) {

	    case '$':			/* ignore %01.str=="d0" for example */
		for (j = 0; j < ncons; j++)
		    if (j != i) {
			if (!strncmp(constraints[i].v0, constraints[j].v0, VARLN)) {
			    if (constraints[j].ty == ']' || constraints[j].ty == '[')
				return 0;
			    }
			}
		break;

	    case '%':					/* %01==%02 */
		if (!strncmp(constraints[i].v0, constraints[i].v1, VARLN)) {
#if trace_simpcon
		    printf("deleting at line %d\n", __LINE__);
#endif
		    /* %01==%01 */
		    goto deletei;
		    }

		if (change(constraints[i].v1, constraints[i].v0, i))
		    goto retry;
		break;

	    case ']':				/* an upper bound */
		
		if (constraints[i].vbound == LONG_MAX) {
#if trace_simpcon
		    printf("deleting at line %d\n", __LINE__);
#endif
		    goto deletei;
		    }

		for (j = 0; j < ncons; j++)
		    if (j != i) {
			if (constraints[j].ty == ']' && !strncmp(constraints[i].v0, constraints[j].v0, VARLN) &&
			    constraints[i].vbound >= constraints[j].vbound) {
#if trace_simpcon
			    printf("deleting at line %d\n", __LINE__);
#endif
			    goto deletei;
			    }

			if (constraints[j].ty == '[' && !strncmp(constraints[i].v0, constraints[j].v0, VARLN) &&
			    constraints[j].vbound > constraints[i].vbound)
			    return 0;
			}
		break;

	    case '[':				/* a lower bound */

		if (constraints[i].vbound == LONG_MIN) {
#if trace_simpcon
		    printf("deleting at line %d\n", __LINE__);
#endif
		    goto deletei;
		    }

		for (j = 0; j < ncons; j++)
		    if (j != i) {
			if (constraints[j].ty == '[' && !strncmp(constraints[i].v0, constraints[j].v0, VARLN) &&
			    constraints[i].vbound <= constraints[j].vbound) {
#if trace_simpcon
			    printf("deleting at line %d\n", __LINE__);
			    printf("text[%d] %s\n", j, constraints[j].text);
			    printf("text[%d] %s\n", i, constraints[i].text);
#endif
			    deletei:
			    while (i+1 < ncons) {
				constraints[i] = constraints[i+1];
				i++;
				}
			    ncons--;
			    goto retry;
			    }
			}
		break;

	    case '=':

		for (j = 0; j < ncons; j++) {

#if trace_simpcon
		    printf("checking = against inequalities\n");
		    dumpconstraint(i, constraints[i]);
		    dumpconstraint(j, constraints[j]);
		    printf("\n\n");
#endif

		    if (j != i) {
			if (!strncmp(constraints[j].v0, constraints[i].v0, VARLN)) {
			    if (constraints[j].ty == '[' &&
				constraints[j].vbound > constraints[i].vbound ||
				constraints[j].ty == ']' &&
				constraints[j].vbound < constraints[i].vbound ||
			    	constraints[j].ty == '=' &&
				constraints[i].vbound != constraints[j].vbound)
				    return 0;

			    if (constraints[j].ty == '[' ||
				constraints[j].ty == ']') {
#if trace_simpcon
				printf("deleting inequality %d\n", j);
#endif
				while (j+1 < ncons) {
				    constraints[j] = constraints[j+1];
				    j++;
				    }
				ncons--;
				goto retry;
				}
			    }
			}
		    }

	    break;
	    }
	}
    return 1;
    }

/*  add a new constraint to the constraints vector, check for overflow */
static newconstraint(s)
    char *s;
{
    if (ncons == nelts(constraints)) {
	cerror("newconstraint: too many reqs file %s line %d.\n",
	    __FILE__, __LINE__);
    }
    constraints[ncons++] = parsecon(s);
#if 0
    printf("/* constraints[%d] = %s line %d */\n",
	ncons - 1, constraints[ncons - 1].text, __LINE__);
#endif
}

vareq(s, vzero, vone)			/* is this %01.str==%02.str?	*/
    char	*s;
    char	*vzero, *vone;
    {
    return (isvar(&s, vzero) && scan(&s, "==") && isvar(&s, vone));
    }

/*  convert text to a Constraint structure */
struct Constraint parsecon(sp)
    char	*sp;
    {
    struct Constraint result;
    char	*s;

    SAFESTRCPY(result.text, sp);

    sp = sp + REQPREFLEN;				/* skip the ;; or ;: */
    s = sp;

    /* %d.xyz==%d.xyz ? */
    if (ISVAR(sp) &&
	sp[VARLN] == '.' &&
	sp[VARLN+4] == '=' &&
	sp[VARLN+5] == '=' &&
	ISVAR(sp+VARLN+6) &&
	sp[2*VARLN+6] == '.') {
	    SAFESTRNCPY(result.v0, sp, VARLN + 4); /* "%x.str" or "%x.kid" */
	    result.v0[VARLN + 4] = 0;
	    SAFESTRNCPY(result.v1, sp + VARLN + 6, VARLN + 4);
	    result.v1[VARLN + 4] = 0;
	    result.ty = '%';
#if 0
	printf("/* variable equality */\n");
#endif
	    return result;
	    }

    if (isvar(&s, result.v0) && scan(&s, "==")) {
	if (*s == '"') {
	    if (isdigit(s[1]) || s[1] == '-') {
		result.vbound = atoi(s+1);
		result.ty = '=';
#if 0
	printf("/* numeric equality */\n");
#endif
		return result;
		}
	    else {
		result.ty = '$';
#if 0
	printf("/* string equality */\n");
#endif
		return result;
		}
	    }
	else if (isdigit(s[0]) || s[0] == '-') {
	    result.vbound = atoi(s);
	    result.ty = '=';
#if 0
	printf("/* numeric equality */\n");
#endif
	    return result;
	    }
	}

    s = sp;
    if (isvar(&s, result.v0) &&
	scan(&s, "<=") && (*s == '-' || isdigit(*s))) {
	result.vbound = atoi(s);
	result.ty = ']';
#if 0
	printf("/* numeric upper bound */\n");
#endif
	return result;
	}
    s = sp;
    if (isvar(&s, result.v0) &&
	scan(&s, ">=") && (*s == '-' || isdigit(*s))) {
	result.vbound = atoi(s);
	result.ty = '[';
#if 0
	printf("/* numeric lower bound */\n");
#endif
	return result;
	}

    result.ty = '?';
#if 0
    printf("/* unrecognizable */\n");
#endif
    return result;
    }


/*  check if the first set of conditions implies the second.		*/
/*  True if adding the second to the first adds nothing.		*/
implies(req1, req2)
    char		*req1, *req2;
    {
    char		bf1[MAXREQLEN], bf2[MAXREQLEN], *s;
    int			blen;
#if 0
	printf("implies req1 %s req2 %s\n",req1,req2);
#endif
    SAFESTRCPY(bf2, req2);
    SAFESTRCPY(bf1, req1);
    blen = strlen(bf1);
    while (s = lastreq(bf2)) {
	if (!addreq(bf1, s, 0, __FILE__, __LINE__) || strlen(bf1) != blen)
	    return 0;
	*s = 0;
	}
    return 1;
    }

/* add possibly new constraint s to old. */
/* ARGSUSED */
#define trace_addreq 0
char *addreq(old, s, type, callerf, callerl)
    char		*old, *s;	/* old & new constraints */
    char		*callerf;	/* caller file */
    int			callerl;	/* caller line */
    int			type;		/* '[' ']' ? $ % or \0 */
    {
    int			i;
    char		*u;
    char		v0[VARLN+5], v1[VARLN+5];
    char		tmp[MAXREQLEN], new[MAXREQLEN];
    char		*prefix;

#if trace_addreq
    printf("/* addreq '%s'\n\n + '%s' from %s line %d */\n\n\n",
	old, s, callerf, callerl);
#endif

    /*	handle the case where there is no new constraint to add */
    if (!*s) {
#if trace_addreq
	printf("/* => %s line %d */\n", old, __LINE__);
#endif
	return old;
	}

    /*  reqs begin with ;; or ;:  except sometimes we get one with
     *  no leading separator. */
    prefix = ";:";			/* assume a removable constraint */

    if (*s == ';') {
	s++;
	if (*s == ':')
	    prefix = ";:";
	else if (*s == ';')
	    prefix = ";;";
	else
	    cerror("addreq: bad req from file %s line %d\n", callerf, callerl);
	s++;
	}

    /*	handle the case where there is no old constraint to add */
    if (!*old) {
	strcpy(old, prefix);
	strcpy(old + REQPREFLEN, s);

	/* just in case we are trying to add a backwards == to '' */
	if (vareq(s, v0, v1) && VAR(v1) < VAR(v0)) {
	    SETVAR(old+REQPREFLEN, VAR(v1));
	    SETVAR(old+VARLN+8, VAR(v0));
	    }

	if (strlen(old) > MAXREQLEN - 1)
	    cerror("file %s line %d: line too long", __FILE__, __LINE__);
#if trace_addreq
	printf("/* => %s line %d */\n", old, __LINE__);
#endif

	return old;
	}

    /*  handle the case where the new constraint actually contains several
     *  separate constraints separated by semicolons.
     */
    if (u = index(s, ';')) {
	SAFESTRCPY(new, s);
	s = new + (u - s);
	u = addreq(old, s, 0, __FILE__, __LINE__);
	*s = 0;
	if (u == NULL) {
#if trace_addreq
	    printf("/* => NULL line %d */\n", u, __LINE__);
#endif
	    return NULL;
	    }
	u = addreq(u, new, 0, __FILE__, __LINE__);
#if trace_addreq
	printf("/* => %s line %d */\n", u, __LINE__);
#endif
	return u;
	}

    /*  the new constraint, s, is simple and neither is empty */
    strcpy(new, prefix);
    strcpy(new + REQPREFLEN, s);
    s = new + REQPREFLEN;

    if (type != '[' && type  != ']') {

	/*  reverse ;:%02.str==%01.str to get the lower var on the left */
	retry:
	if (vareq(s, v0, v1) && VAR(v1) < VAR(v0)) {
	    SETVAR(new + REQPREFLEN, VAR(v1));
	    SETVAR(new + VARLN + 8, VAR(v0));
	    goto retry;		/* looks like a no-op but */
	    }			/* vareq fixes up v0 and v1 */

	/* is the new req already in the old reqs? */
	if (fmatch(old, new)) {
#if trace_addreq
	    printf("/* => %s line %d */\n", old, __LINE__);
#endif
	    return old;
	    }
	}

#if trace_addreq
    printf("unpacking old '%s' new '%s'...\n", old, new);
#endif
    for (ncons = 0; ncons < MAXCONS; ) {

	s = lastreq(old);
	if (s == NULL) {
	    cerror("addreq: bad old rt format '%s'\n", old);
	    }

	if (strcmp(s, new) < 0) {
	    newconstraint(new);
	    for (;;) {
		s = lastreq(old);
		newconstraint(s);
		*s = 0;
		if (s == old) goto done;
		}
	    }
	else {
	    newconstraint(s);
	    *s = 0;
	    if (s == old) {
		newconstraint(new);
		goto done;
		}
	    }
	}
    cerror("%s %d : Ran out of constraints\n",__FILE__,__LINE__);

    done:
#if trace_addreq
    printf("simplifying %d constraints\n", ncons);
#endif
    if (!simpcon()) {
#if trace_addreq
	printf("/* => 0 line %d */\n", __LINE__);
#endif
	return 0;
	}	/* simplify		*/

    for (i = ncons - 1; i >= 0; i--)
	strcat(old, constraints[i].text);

#if trace_addreq
    printf("/* => %s line %d */\n", old, __LINE__);
#endif
    return old;
    }

/*  add constraints to the requirements list			*/ 
/*  converting them from simpler format to the C-like format	*/
/* ARGSUSED */
#define trace_addcon 0
char *addcon(locv, req, patrec, c, fromfile, fromline, numeric)
    char		*req;		/* output constraints	*/
    char		*c;		/* new additions	*/
    struct patrec	*patrec;
    int			locv;		/* constrained var	*/
    char		*fromfile;
    int			fromline;
    unsign32		numeric;	/* a numeric variable	*/
    {
    unsigned		locv2;
    int			type = 0;
    char		bf[MAXREQLEN], bf0[MAXREQLEN], *s;

#if trace_addcon
    printf("/* addcon %%%d c %s patrec %s req `%s' from %s line %d */\n",
	patrec->map[locv], c, patrec->p_rt, req, fromfile, fromline);
#endif
    if (ISVAR(c) && ((locv2 = VAR(c)) < MAXGLOBALS+MAXFREENONTERMS)
	&& c[VARLN] == 0) {
	s = (regtype(patrec->p_rt, locv) == NOREG) ? (numeric ? ".num" : ".str") : ".kid";
	sprintf(bf, VARFMT, patrec->map[locv]);
	SAFESTRCAT(bf, s);
	SAFESTRCAT(bf, "==");
	sprintf(endof(bf), VARFMT, patrec->map[locv2]);
	SAFESTRCAT(bf, s);
	type = '=';
	}
    else if ((s = rindex(c, '-')) && s != c) {
	sprintf(bf, VARFMT, patrec->map[locv]);
	sprintf(endof(bf), ".num>=%.*s",s - c, c);
	if (!addreq(req, bf, ']', __FILE__, __LINE__)) {
#if trace_addcon
	    printf("=> 0\n", req);
#endif
	    return 0;		/* ranges add 2	*/
	    }
	sprintf(bf, VARFMT, patrec->map[locv]);
	sprintf(endof(bf), ".num<=%s", s+1);
	}
    else  {
	sprintf(bf, VARFMT, patrec->map[locv]);
	if (numeric)
	    sprintf(endof(bf), ".num==%s", c);
	else {
	    quote(c, bf0);
	    sprintf(endof(bf), ".str==%s", bf0);
	    }
	type = '$';
	}
    s = addreq(req, bf, type, __FILE__, __LINE__);
#if trace_addcon
    if (!s) printf("/* addcon returns 0 */\n");
    else printf("/* addcon returns %s */\n", s);
#endif
    return s;
    }

#define trace_bittrans 0
unsign32 bittrans(reqs, locv, p)	/* translate reqs to bit vec	*/
    char	*reqs;			/* by adding all values &	*/
    int		locv;			/* checking for contradictions	*/
    struct patrec *p;
{
    int		regt = regtype(p->p_rt, locv);
					/* register class in regpatts	*/
    int 	globv = p->map[locv];
    char	vec[MAXREQLEN], *s, newreq[MAXREQLEN], bf[20];
    int		i;
    unsign32	mask;			/* mask of # of regs in class	*/
    unsign32	result = 0;
    int		regwidth;		/* width of the register	*/


    if (globv == NOVAR || regt == NOREG)
	return 0;

    mask = (1 << (regpatts[regt].many)) - 1;
    mask <<= regpatts[regt].bitorg;
    regwidth = regpatts[regt].width;

#if trace_bittrans
    printf("/* bittrans reqs '%s' */\n", reqs);
    printf("/* regt %d globv %d bitorg %d */\n",
	regt, globv, regpatts[regt].bitorg);
    printf("/* regpatts[%d].bitorg %d many %d mask %o */\n",
	regt, regpatts[regt].bitorg, regpatts[regt].many, mask);
#endif

    /* if no requirements, then anything is valid */
    if (!reqs) result = (unsign32)-1;
    else {
	sprintf(bf, VARFMT, globv);
	for (i = 0; i < REGBITS; i++) {
	    if ((1 << i) & mask) {
		SAFESTRCPY(newreq, reqs);
		strcpy(vec, ";:");
		sprintf(vec + REQPREFLEN, VARFMT, globv);
		/*
		sprintf(endof(vec), ".str==\"%s\"", regnames[regwidth - 1][i]);
		*/
		sprintf(endof(vec), ".num==%d", i);

#if trace_bittrans
		printf("/* try i=%d, adding constraints: */\n", i);
#endif
		ncons = 0;
		newconstraint(vec);

		while ((s = lastreq(newreq))) {
		    if (fmatch(s + REQPREFLEN, bf))
			newconstraint(s);
		    *s = 0;
		}
		if (simpcon()) {
		   result |= (1 << i);
		}
	    }
	}
    }
#if trace_bittrans
    printf("/* bittrans returns %o */\n", result & mask);
#endif
    return (result & mask);
}


regmove(s)		/* am I a reg->reg copy instruction?	*/
    char	*s;
    {
    char	src[MAXRTLINE], dst[MAXRTLINE], type[MAXRTLINE];
    gtds(s, dst, src, type);
    return (regvarb(src) != NOVAR && regvarb(dst) != NOVAR);
    }

static unsigned varbits(q)		/* bit vector of vars used	*/
    struct patrec	*q;		/* in this chain of patrecs	*/
    {
    unsigned		result = 0, ix, locv;
    for (ix = 0; ix < MAXOPTSIZE; ix++) {
#if 0
	printf("rt[%d] = %s uses ",  ix, q[ix].rt);
#endif
	for (locv = 0; locv < MAXGLOBALS+MAXFREENONTERMS; locv++)
	    if (q[ix].map[locv] != NOVAR) {
		result |= 1 << q[ix].map[locv];
#if 0
		printf("%%%d ", q[ix].map[locv]);
#endif
		}
#if 0
	printf("\n");
#endif
	/*
	register char	*s;
	unsigned v;
	for (s = q[ix].rt; s && *s; s++)
	    if (ISVAR(s) && (v = VAR(s) - FIRSTVAR) < MAXGLOBALS+MAXFREENONTERMS)
		result |= 1 << (q[ix].map[v] - FIRSTVAR);
	*/
	}
    return result;
    }

/* ARGSUSED */
getvar(o, numeric, fromfile, fromline)	/* get an unused global var	*/
    register struct Optrec *o;
    char	*fromfile;
    int		numeric;
    int		fromline;
    {
    register unsigned	v, globv;
    register char *s;

#if USE_NUMBERS == 0
    numeric = 0;			/* numerics are different under lcc */
#endif

#if 0
    printf("getvar from %s line %d reqs %s\n", fromfile, fromline, o->reqs);
#endif
    v = varbits(o->old) | varbits(o->new) | o->o_varsused;

    for (s = o->o_reqs; s && *s; s++)
	if (ISVAR(s) && (globv = VAR(s)) < MAXGLOBALS)
	     v |= (1 << globv);

    for (globv = 0; globv < MAXGLOBALS; globv++) {
	if ((v & 1) == 0) {
#if 0
	    printf("getvar returns %%%d\n", globv);
#endif
	    o->o_varsused |= 1 << globv;
	    if (numeric)
		o->o_numbers |= 1 << globv;
	    else
		o->o_numbers &= ~(1 << globv);	/* this should be redundant */
	    return globv;
	    }
	v >>= 1;
	}
		
#if 0
    printf("getvar returns NOVAR\n");
#endif
    return NOVAR;
    }

/*  Return a pointer to the last requirement in this buffer, or a NULL
 *  if the buffer is bare.
 */
char *lastreq(s)
    char	*s;
    {
    char	*result;

    result = rindex(s, ';');
    if (!result)
	return NULL;
    if (result > s && result[-1] == ';')
	result--;
    return result;
    }

/*  point to the beginning of the next requirement in this list of
 *  requirements, or to the null at the end of the buffer.
 */
char *nextreq(s)
    char	*s;
    {
    char	*result;

    if (*s == ';') {
	s++;
	if (*s == ':' || *s == ';')
	    s++;
	}

    result = index(s, ';');
    if (result)
	return result;
    return s + strlen(s);
    }
