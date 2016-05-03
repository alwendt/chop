/* Copyright (c) 1991 Alan Wendt.  All rights reserved.
 * You have this code because you wanted it now rather than correct.
 * Bugs abound!  Contact Alan Wendt for a later version or to be
 * placed on the chop mailing list.  Parts are missing due to licensing
 * constraints.
 *
 * Alan Wendt / Computer Science / Colorado State Univ. / Ft Collins CO 80523
 * 303-491-7323.  wendt@cs.colostate.edu
 */

/* Sort and output a list of assignments to the instruction's vars and kids
 * so that we can do the assignments in-place in the current instruction node.
 */

#include <stdio.h>
#include <ctype.h>
#include "c.h"
#include "hop2.h"

#define	LPAR '('
#define RPAR ')'

#define MAXCOPIES (MAXGLOBALS*2)
#define MAXNAMES 200

#define UNKNOWN 999

static doxfer2(), decuses();

/* holds the result string of code to be output */
char            asgs[MAXREQLEN*(MAXSYMS+MAXKIDS)];

extern char    *rindex();
extern          doxfers();	/* process & emit stashed copies	 */
extern          stashxfer();	/* store a copy				 */

static          clook();	/* find a copy of this value somewhere	 */
static void     darken();	/* perform a copy			 */
static          dumpxfers();	/* debugging				 */
static void	firstparam();
static          paralize();	/* parallelize the whole set of copies	 */
static          safexfer();	/* is this copy safe to do now?		 */
static          sequences();	/* compare two copies by sequence #	 */
static		safecomp();
static          vinstall();	/* install a new name for a value	 */
static		nameinstall();	/* install the text of a new name	*/
static char    *balpar();	/* find the opposing parenthesis	 */
static          expand();
static char	*ismacro();	/* does string resemble IKID(.*,3)?	*/

static short    namesz = 1;	/* number of names		 */

static char    *name[MAXNAMES] = {""};	/* name of this graph vertex	 */
					/* (the original C path)	 */

static isksn(s)			/* is IKID, ISYM, or INUM? */
    char           *s;
    {
    return !strncmp(s, "IKID(", 5) ||
           !strncmp(s, "INUM(", 5) ||
           /* !strncmp(s, "ISTR(", 5) || */
           !strncmp(s, "ISYM(", 5);
    }

/*  Compare two character strings to see if they could be storage aliases */
skcmp(s1, s2)			/* like strcmp but IKID == INUM */
    char           *s1, *s2;
    {
    for (;;) {
	if (!*s1 && !*s2)
	    return 0;
	if (isksn(s1) && isksn(s2)) {
	    s1 += 5;
	    s2 += 5;
	    }
	else {
	    if (*s1 != *s2)
		return *s1 - *s2;
	    s1++;
	    s2++;
	    }
	}
    }

skncmp(s1, s2, n)		/* like strncmp but "ISYM" == "IKID"	 */
    char           *s1, *s2;
    {
    for (;;) {
	if (!*s1 && !*s2)
	    return 0;
	if (n == 0)
	    return 0;
	if (isksn(s1) && isksn(s2)) {
	    s1 += 5;
	    s2 += 5;
	    n -= 5;
	    }
	else {
	    if (*s1 != *s2)
		return *s1 - *s2;
	    s1++;
	    s2++;
	    n--;
	    }
	}
    }

static struct Xfer {
    char            dst[MAXREQLEN];
    char            src[MAXREQLEN];
    short           seq;	/* sequence number		 */
    char            comment[MAXREQLEN];
    short           prio;
}               xfers[MAXCOPIES];

short           nxfers;

/* pathway to follow to get to each node */
char            paths[MAXNAMES][MAXREQLEN];

/* Edges can have two tails, so that binary dependencies can be represented.
 * Most structure element accesses are written in functional form, as in
 * IKID(ins,3) or INSOP(ins).  In these cases, the label is "IKID(%00,3)".
 * If the structure element access is written normally, eg "r->op", the label
 * is %00->op.  Infix binary labels are also possible, e.g. %00+%01.
 */
struct Edge {			/* a graph edge			 */
    short           tails[2], h;/* node numbers of tail & head	 */
    char            label[100];	/* name of the label		 */
};

struct Copy {			/* a pending copy (an edge that	 */
    short           tails[2], h;/* must be darkened)		 */
    char            label[100];
    short           prio;	/* priority			 */
    short           orig;	/* original loc in dash vector	 */
				/* used to index comments	 */
};

/* This program works by backtracking search.  xfroot is the initial state. A
 * dark edge is an assertion that you can reach the node at the head of the
 * edge by taking the node(s) at the tail and applying the label. For
 * example, a dark edge labelled "%00->b" would connect two nodes originally
 * labelled "a" and "a->b".  A dark edge labelled "%00+%01" will have two
 * tails and will connect them with a node originally labelled "a+b".
 * A dashed edge is an assignment that wants to be performed.  When it is
 * performed, we will darken it by moving it from the dash vector to the
 * dark vector.  dark is larger because it completely describes the existing
 * data structure, whereas dash only needs to describe the new assignments
 * that need to be performed.
 */

struct GraphState {		/* a problem state		 */
    short           darksz;
    short           dashsz;
    struct Edge     dark[MAXCOPIES * 3]; /* current edges		 */
    struct Copy     dash[MAXCOPIES];	 /* desired edges		 */
    char           *nextasg;	/* end of asgs vector		 */
    }               xfroot;

/* This routine is called by the user of this package to queue up a transfer
 * that should be accomplished.
 */
stashxfer(dstname, srcname, seq, commentbf, prio)
    char       *dstname, *srcname, *commentbf;
    int		seq;	/* xfers with same seq #'s have parallel semantics */
    int		prio;	/* we do lowest prios first when possible          */
    {
#if 0
    printf("/* stashxfer %s := %s %d */\n", dstname, srcname);
    printf("/* seq %d prio %d comment %s */\n", seq, prio, commentbf);
    fflush(stdout);
#endif
    if (nxfers == nelts(xfers)) {
	cerror("too many xfers stashed\n");
	}
    SAFESTRCPY(xfers[nxfers].src, srcname);
    SAFESTRCPY(xfers[nxfers].dst, dstname);
    xfers[nxfers].seq = seq;
    xfers[nxfers].prio = prio;
    SAFESTRCPY(xfers[nxfers].comment, commentbf);
    nxfers++;
    }

/*  sort the unperformed transfers by priority */
static compdash(p1, p2)
    struct Copy *p1, *p2;
    {
    return p1->prio - p2->prio;
    }

/* This routine goes through all the transfers and collects the names of
 * data elements.  Every different name goes into the name[] array
 * relationship between names goes into the list of dark edges.	 For
 * example, after reading "(a->b)+(c->d)" as a source, the names "a",
 * "a->b", "c", "c->d", and "(a->b)+(c->d)" will be entered into the
 * name[] array, representing vertices in a graph. In addition, there
 * will be an edge labelled "%00->b" from "a" to "a->b", an edge labelled
 * "%00->d" from "c" to "c->d", and an edge labelled "(%00)+(%01)"
 * from "a->b" and "c->d" to "(a->b)+(c->d)". Edges can have two tails,
 * but only one label and one head.  The last edge means that, if you have
 * names x & y for values that are equivalent to the original values
 * of a->b and c->d, you can get a value that is equivalent to the original
 * value of (a->b)+(c->d) by uttering "(x)+(y)".
 */
unpack()
    {
    char           *s, label[MAXRTLINE], dstbf[MAXRTLINE], *t, *lpar, *rpar;
    int             i, j, dstno, srcno;

    for (i = 0; i < nxfers; i++) {

	SAFESTRCPY(dstbf, xfers[i].dst);
#if 0
	printf("/* unpack xfers[%d].dst %s := src %s */\n",
	       i, xfers[i].dst, xfers[i].src);
#endif
	if ((s = rindex(xfers[i].dst, '>')) && s[-1] == '-') {
	    s[-1] = 0;
	    sprintf(label, "%%00->%s", s + 1);
	    }

	/*  Find the xyz in an expression like IKID(xyz,5) */
	else if (lpar = ismacro(xfers[i].dst)) {

	    rpar = balpar(xfers[i].dst, lpar);

	    /* point to the comma or right paren following the last parameter */ 
	    for (t = rpar;; t--)
		if (*t == ',')
		    break;
		else if (*t == LPAR) {
		    t = rpar;
		    break;
		    }

	    /*  Replace the first parameter with a numbered variable */
	    sprintf(label, "%.*s(%%00%s", lpar - xfers[i].dst, xfers[i].dst, t);
	    *t = 0;
	    memmove(xfers[i].dst, lpar + 1, t - lpar + 1);
	    }

	else {
	    SAFESTRCPY(label, xfers[i].dst);
	    xfers[i].dst[0] = 0;
	    }

	dstno = vinstall(&xfroot, xfers[i].dst, xfers[i].seq);
	srcno = vinstall(&xfroot, xfers[i].src, xfers[i].seq);

	/* check for conflicting assignments to the same destination	 */
	for (j = 0; j < xfroot.dashsz; j++) {
	    if (xfroot.dash[j].tails[0] == dstno &&
		!skcmp(xfroot.dash[j].label, label))
		return;
	    }

	/* Add this assignment to the list of assignments to be done	 */
	xfroot.dash[xfroot.dashsz].tails[0] = dstno;
	xfroot.dash[xfroot.dashsz].tails[1] = -1;
	xfroot.dash[xfroot.dashsz].h = srcno;
	xfroot.dash[xfroot.dashsz].orig = xfroot.dashsz;
	xfroot.dash[xfroot.dashsz].prio = xfers[i].prio;


	SAFESTRCPY(xfroot.dash[xfroot.dashsz].label, label);
#if 0
	printf("/* add dashed[%d] from node %d to node %d labelled %s */\n",
		xfroot.dashsz, dstno, srcno, label);	
#endif
	xfroot.dashsz++;
	}

    qsort(xfroot.dash, xfroot.dashsz, sizeof(xfroot.dash[0]), compdash);

    nxfers = 0;
    }


/*  Install a new name for a value.  This procedure installs the text of a
 *  variable name into the name table and gets a unique number.  It then
 *  breaks down the name giving zero, one, or two subordinate component
 *  expressions and a label.  For example, if the name is "(a)+(b)", the
 *  subordinate expressions are "(a)" and "(b)", and the label is
 *  %00+%01.  vinstall then vinstalls "(a)" and "(b)" and creates a
 *  (bipartite) graph edge from those two vertices to the vertex for
 *  "(a)+(b)".  The graph edge signifies that the vertex for "(a)+(b)"
 *  is reachable provided that the subordinate vertices are.
 *  The assignment sequence number is needed for function calls. The
 *  assignments a = foo(), b = a are parallelized to a = foo(), b = foo()
 *  but doxfers must ensure that foo is only called once (the number of
 *  times it originally appeared).  This is done by deleting a
 *  function as a source after assigning from it once.
 *
 * Note:  this function has a mindless  parser to break expressions out
 *        into their components.  Someday we will put a real expression
 *        parser in here, but for now each operand of each operator must
 *        be fully-parenthesized.  The only exception is the -> operator.
 *
 * The parser currently handles:  unary operators written "-(xyz)"
 *              binary operators written "(abc)+(xyz)"
 *              function calls with a single argument.
 *              macro expressions such as IKID(xyz,6)
 *              pointer expressions such as IKID(xyz,6)->count
 *              anything else is treated as a scalar (no tail vertices).
 *
 *  This routine updates the "dark" graph which reflects reachability of
 *  the various values.  When assignments are later performed, the dark
 *  graph is updated to reflect the changes in reachability.
 */
static int vinstall(state, s, seq)
    struct GraphState *state;	/* state to update */
    char           *s;		/* the name of the value */
    int             seq;	/* assignment sequence number	 */
    {
    char            label[MAXRTLINE], left[MAXRTLINE], right[MAXRTLINE];
    char            bf[1000];
    int             i;
    char           *p, *send, *t, *tend;
    char		*lpar, *rpar;
    int			hvert;			/* head vertex # */
    int			tvert1, tvert2;		/* 2 tail vertices */
    int			onames;

#if 0
    printf("vinstall(%s)\n", s);
#endif
    onames = namesz;
    hvert = nameinstall(s);

    if (onames == namesz) {
#if 0
	printf("already in names[%d]\n", hvert);
#endif
	return hvert;
	}

    SAFESTRCPY(bf, s);

    /*  Strip off one one level of operator.  Possibilities are:
     *  function calls, unary operators, -> operators,
     *  IKID(xyz,3) operators 
     */

    /*  check for unary operators */
    if ((bf[0] == '~' || bf[0] == '!' || bf[0] == '-')
	&& bf[1] == LPAR && (p = balpar(bf, bf + 1)) && p[1] == 0) {
	sprintf(label, "%.*s(%%00)", 1, bf);
	sprintf(left, "%.*s", p - bf - 2, bf + 2);
#if 0
	printf("/* vinstall(%s): unary operator '%s' '%s'\n", s, label, left);
#endif
	tvert1 = vinstall(state, left, seq);
	addark(state, hvert, tvert1, -1, label);
	return hvert;
	}

    /*  Check for variable access like IKID(xyz,3) */
    if (lpar = ismacro(s)) {
	firstparam(s, lpar, label, left);
#if 0
	printf("/* vinstall(%s): varaccess label '%s' left '%s'\n",
	    s, label, left);
#endif
	tvert1 = vinstall(state, left, seq);
	addark(state, hvert, tvert1, -1, label);
	return hvert;
	}

    /*  Check for function call */
    if (isalpha(bf[0]) || bf[0] == '_') {
	for (i = 1; bf[i]; i++) {
	    if (!isalpha(bf[i]) && !isdigit(bf[i]) && bf[i] != '_') {
		if (bf[i] != LPAR)
		    break;
		p = balpar(bf, bf + i);
		if (p == 0 || p[1] != 0)
		    break;
		sprintf(label, "%.*s(%%00)::%d", i, bf, seq);
		sprintf(left, "%.*s", p - bf - i - 1, bf + i + 1);
#if 0
	printf("/* vinstall(%s): fn call '%s' '%s'\n", s, label, left);
#endif
		tvert1 = vinstall(state, left, seq);
		addark(state, hvert, tvert1, -1, label);
		return hvert;
		}
	    }
	}

    /* Determine if there is a binary operator separating two parts	 */
    if (s[0] == LPAR) {
	send = balpar(s, s);	/* find closing parenthesis	 */
	tend = s + strlen(s) - 1;

	if (*tend != RPAR) {
	    printf("/* warning: no closing paren for '%s'! */\n", s);
	    return hvert;
	    }

	t = balpar(s, tend);	/* find opening parenthesis	 */

	if (send && t) {
	    if (s == t) {
		sprintf(label, "(%%00)");
		sprintf(left, "%.*s", send - s - 1, s + 1);
		addark(state, hvert, vinstall(state, left, seq), -1, label);
		}
	    else {
		sprintf(label, "%%00%.*s%%01", t - send - 1, send + 1);
		sprintf(left, "%.*s", send - s + 1, s);
		sprintf(right, "%.*s", tend - t + 1, t);
#if 0
	printf("/* vinstall: binop(%s) '%s' '%s' '%s'\n", s, label, left, right);
#endif
		tvert1 = vinstall(state, left, seq);
		tvert2 = vinstall(state, right, seq);
		addark(state, hvert, tvert1, tvert2, label);
		}
	    return hvert;
	    }
	}

    if ((p = rindex(s, '>')) && p[-1] == '-') {	/* ptr exp  */
	p[-1] = 0;
	sprintf(left, "%%00->%s", p + 1);
#if 0
	printf("/* vinstall(%s): ptrexp '%s' '%s'\n", s, label, left);
#endif
	tvert1 = vinstall(state, left, seq);
	addark(state, hvert, tvert1, -1, label);
	return hvert;
	}

#if 0
    printf("/* vinstall(%s): scalar '%s' left '%s'\n", s, s, "");
#endif
    tvert1 = vinstall(state, "", seq);
    addark(state, hvert, tvert1, -1, s);
    return hvert;
    }

/*  s begins a macro call, lpar and rpar surround its arguments.
 *  Replace the first argument with %00 and leave that string in "label".
 *  Leave the first parameter in "left".
 */
static void firstparam(s, lpar, label, left)
    char	*s, *lpar, *label, *left;
    {
    char	*rpar;
    char	*param, *paramend;

    rpar = balpar(s, lpar);

    param = lpar + 1;
    for (paramend = param;; paramend++) {
	if (*paramend == LPAR) {
	    paramend = balpar(s, paramend) + 1;
	    break;
	    }
	else if (*paramend == ',' || paramend == rpar)
	    break;
	}

    /*  Replace the first parameter with a numbered variable */
    sprintf(left, "%.*s", paramend - param, param);
    sprintf(label, "%.*s%%00%s", param - s, s, paramend);
#if 0
    printf("/* firstparam '%s' => left '%s' label '%s' */\n", s, left, label);
#endif
    }

/*  Install this name into the name table and return the index */
static int nameinstall(s)
    char	*s;
    {
    extern char *malloc();
    int		nodenumber;
#if 0
    printf("\n/* nameinstall '%s' */\n", s);
#endif

    /*  Install the name into the name table */
    for (nodenumber = 0; nodenumber < namesz; nodenumber++)
	if (skcmp(name[nodenumber], s) == 0) {
#if 0
	    printf("/* nameinstall: found '%s' at name[%d] */\n",
		s, nodenumber);
#endif
	    return nodenumber;
	    }

    /* install new name */
    if (namesz >= nelts(name)) {
	cerror("nameinstall: too many values\n");
	}
    strcpy(name[nodenumber] = malloc((unsigned) strlen(s) + 1), s);
#if 0
    printf("/* nameinstall: name[%d] := %s */\n", nodenumber, s);
#endif
    namesz++;
    return nodenumber;
    }

/*  If p is an expression like IKID(xyz,5), return the address of the
 *  left parenthesis.
 */
static char *ismacro(p)
    char	*p;			/* input string */
    {
    char	*lpar, *rpar;
    /*  Find the xyz in an expression like IKID(xyz,5) */
    if (!strncmp(p, "IKID(", 5) ||
	!strncmp(p, "ISTR(", 5) ||
	!strncmp(p, "INUM(", 5) ||
	!strncmp(p, "IVAR(", 5) ||
	!strncmp(p, "INSOP(", 6) ||
	!strncmp(p, "ISYM(", 5)) {
	for (lpar = p; *lpar != LPAR; lpar++)
	    continue;
	rpar = balpar(p, lpar);

	/*  Not sure why the following is necessary, but it is ??? */
	if (rpar == NULL)
	    return NULL;

	if (rpar[1] == 0)
	    return lpar;
	}
    return NULL;
    }


/*  Add a dark (two-tailed) edge from t1 & t2 to h with the given label.
 *  Delete any existing dark edge with the same t1, t2, and label.
 *  This represents assigning the value represented by t1, t2, and label
 *  to the node h.  For example after doing x := a+b, the graph would contain
 *  an edge labelled "%01+%02" from the nodes for a and b to the node for x.
 *
 * "Same" means "occupies same storage location" -- IKID, ISYM & INUM are
 * the same.  If two labels are the "same" but not the same string, the label
 * is changed to the same string.  This ensures that unions are correctly
 * handled; we do not store ISYM and retrieve IKID.
 */
addark(state, h, t1, t2, label)
    struct GraphState *state;
    short           h, t1, t2;
    char           *label;
    {
    short           i;
#if 0
    printf("add dark t1 %d t2 %d label %s h %d\n\n", t1, t2, label, h);
#endif
    for (i = 0; i < state->darksz; i++) {
	if (state->dark[i].tails[0] == t1 &&
	    (t2 == -1 || state->dark[i].tails[1] == t2) &&
	    !skcmp(state->dark[i].label, label)) {
	    SAFESTRCPY(state->dark[i].label, label);	/* New Alan 901024 */
	    state->dark[i].h = h;	/* replace current edge	 */
	    return;
	    }
	}

    if (state->darksz == nelts(state->dark)) {
	printf("too many dark edges needed: we have %d\n", nelts(state->dark));
	printf("transfers: \n");
	for (i = 0; i < nxfers; i++) {
	    printf("%s := %s\n", xfers[i].dst, xfers[i].src);
	    }
	cerror("too many dark edges\n");
	}
    state->dark[state->darksz].h = h;
    state->dark[state->darksz].tails[0] = t1;
    state->dark[state->darksz].tails[1] = t2;
    SAFESTRCPY(state->dark[state->darksz].label, label);
    state->darksz++;
    }

/*
 * This routine is called by the user of this package, to cause all queued
 * transfers to be accomplished.
 */
doxfers()
    {				/* do cached transfers legally		 */
    int             i, j;


    /* Remove serialism from the transfer list by performing forward	 */
    /* substitution	 */
    paralize();			/* parallelize all copies	 */

#if 0
    printf("/* after paralize:\n");
    printf("\n */\n\n");
#endif

    unpack();

#if 0
    printf("/* after unpack:\n");
    dumpxfers(&xfroot, 0);
    printf("\n */\n\n");
#endif

    xfroot.nextasg = asgs;	/* no assignments in vector	 */

    for (i = 0; i < xfroot.dashsz; i++)	/* eliminate x = x	 */
	for (j = 0; j < xfroot.darksz; j++)
	    if (xfroot.dash[i].tails[0] == xfroot.dark[j].tails[0] &&
		xfroot.dash[i].h == xfroot.dark[j].h &&
		!skcmp(xfroot.dash[i].label, xfroot.dark[j].label)) {
		xfroot.dash[i] = xfroot.dash[--xfroot.dashsz];
		i--;
		}

    if (!doxfer2(xfroot, 0)) {	/* never happened yet */
	cerror("doxfer: > 1 temp required!!\n");
	}
    xfroot.dashsz = xfroot.darksz = 0;
    namesz = 1;
    asgs[0] = 0;		/* zap output string */
    }

/* convert seq->parallel e.g. turn the sequential pair a := b, c := a
 * into a := b; c := b
 */
static paralize()
    {
    register    u, l, old, new;
    char        bf[MAXREQLEN];
    int		start;

#if 0
    printf("paralize\n");
#endif

    if (nxfers == 0)
	return;			/* avoid infinite loop		 */

    /* sort copies by increasing seq fields */
    qsort(xfers, nxfers, sizeof(xfers[0]), sequences);

#if 0
    printf("after qsort\n");
    for (old = 0; old < nxfers; old++) {
	printf("'%s' := '%s' seq %d\n", xfers[old].dst, xfers[old].src, xfers[old].seq);
	}
#endif

    /* While there is > 1 different sequence number left	 */
    while (xfers[0].seq != xfers[nxfers - 1].seq) {

	/* find first transfer in second batch */
	for (l = 1; l < nxfers && xfers[l].seq == xfers[0].seq; l++)
	    continue;

	for (; l < nxfers; l = u) {

	    /* Merge first batch and second, while there is a next	 */
	    /* get upper limit of second batch */
	    for (u = l + 1; u < nxfers && xfers[u].seq == xfers[l].seq; u++)
		continue;

#if 0
	    printf("batches from %d-%d and %d-%d\n", 0, l - 1, l, u - 1);
#endif


	    /* substitute first assignments into next batch	 */
	    /* Replace old dests by old sources in new sources	 */
	    for (new = l; new < u; new++) {
		for (old = 0; old < l; old++) {
		    int	olddstlen = strlen(xfers[old].dst);
		    for (start = 0; xfers[new].src[start]; start++) {
			if (!skncmp(xfers[old].dst, xfers[new].src + start,
				    olddstlen) &&
			    !isalpha(xfers[new].src[start - 1]) &&
			    !isalpha(xfers[new].src[start + olddstlen])) {
#if 0
			    printf("/* '%s' is a subexpression of '%s'\n",
				xfers[old].dst, xfers[new].src);
			    printf("  replace it with '%s'\n */\n",
				xfers[old].src);
#endif
			    SAFESTRNCPY(bf, xfers[new].src, start);
			    bf[start] = 0;
			    SAFESTRCAT(bf, xfers[old].src);
			    SAFESTRCAT(bf, xfers[new].src + olddstlen + start);
			    SAFESTRCPY(xfers[new].src, bf);
			    goto srcfixed;
			    }
			}
		    }
		srcfixed:
		continue;
		}

	    /* replace old dests by old sources in subexpressions of new dests */
	    for (new = l; new < u; new++) {	/* for each new asg	 */
		for (old = 0; old < l; old++) {
		    int olddstlen = strlen(xfers[old].dst);
		    for (start = 0; xfers[new].dst[start]; start++) {
			if (!skncmp(xfers[old].dst, xfers[new].dst + start,
				(int)olddstlen) &&
			    olddstlen != strlen(xfers[new].dst) &&
			    !isalpha(xfers[new].dst[start - 1]) &&
			    !isalpha(xfers[new].dst[start + olddstlen])) {
#if 0
			    printf("/* '%s' is a proper subexpr of '%s'\n",
				   xfers[old].dst, xfers[new].dst);
			    printf("   change '%s' to ", xfers[new].dst);
#endif
			    SAFESTRNCPY(bf, xfers[new].dst, start);
			    bf[start] = 0;
			    SAFESTRCAT(bf, xfers[old].src);
			    SAFESTRCAT(bf, xfers[new].dst + start + olddstlen);
			    /*
			    SAFESTRCAT(bf, xfers[new].dst + olddstlen);
			    */
			    SAFESTRCPY(xfers[new].dst, bf);
#if 0
			    printf("   '%s' */\n", xfers[new].dst);
#endif
			    goto dstfixed;	/* dst fixed	 */
			    }
			}
		    }
		dstfixed:
		continue;
		}

	    while (l < u)
		xfers[l++].seq = xfers[0].seq;
	    }
	}

#if 0
    printf("/* after paralize */\n");
    for (old = 0; old < nxfers; old++) {
	printf("/* %s := %s */\n", xfers[old].dst, xfers[old].src);
	}
#endif
    }

/* Recursive function to perform one assignment.  This does a depth-first
 * search of alternative assignment orders, trying the most likely ones
 * first.  To run faster, it only recurses when it has a choice of which
 * assignment to try next, otherwise it runs dstructively in the current copy
 * of the state.  It creates a temporary when no further progress can be
 * made, because all the transfers are unsafe.  In that case, it uses
 * minprog to insist that the temporary gets us some forward progress,
 * otherwise it can get into an infinite sequence of temporary creation.
 */
static doxfer2(state, minprog)
    struct GraphState state;	/* The list of transfers to be done */
				/* And the current pointer graph    */
    int             minprog;	/* fail unless you can do this many */
    {
    int             i, progress = 0, nsafe, j;
    int             safelist[100];
    struct GraphState new;

#if 0
    printf("doxfer2(,%d)\n", minprog);
    dumpxfers(&state, 0);
#endif

    qsort(state.dash, state.dashsz, sizeof(state.dash[0]), safecomp);

    while (0 < state.dashsz) {	/* any edges remaining?	 */

	/* Is there a copy we can do safely?				 */
	nsafe = 0;
	for (i = 0; i < state.dashsz; i++)
	    if (safexfer(&state, i))
		safelist[nsafe++] = i;

#if 0
	printf("found %d safe xfers\n", nsafe);
#endif

	if (nsafe == 1) {	/* exactly one safe copy  */
	    reach(&state, paths);	/* no choices possible    */
	    darken(&state, safelist[0]);	/* so do it               */
	    reach(&state, paths);
	    progress++;
	    }
	else if (nsafe > 1) {	/* >1 alternative, try each */
	    for (i = 0; i < nsafe; i++) {
		new = state;
		reach(&new, paths);
		darken(&new, safelist[i]);
		reach(&new, paths);
		if (doxfer2(new, minprog - progress))
		    return 1;
		}
	    return 0;
	    }
	else if (progress < minprog) {
#if 0
	    printf("%d < %d: not progressing\n", progress, minprog);
#endif
	    return 0;		/* no alternatives */
	    }
	else {
#if 0
	    printf("stuck!\n");
	    dumpxfers(&state, 0);
#endif
	    if (state.dashsz < 0 || state.dashsz >= nelts(new.dash)) {
		cerror("doxfers: subscript error\n");
		}
	    for (i = 0; i < state.dashsz; i++) {	/* try temps	 */
		new = state;
		new.dash[new.dashsz].tails[0] = 0;

		for (j = 0; j < new.darksz; j++) {
		    if (new.dark[j].tails[0] == new.dash[i].tails[0] &&
			!skcmp(new.dark[j].label, new.dash[i].label)) {
			new.dash[new.dashsz].h = new.dark[j].h;
			goto found;
			}
		    }
		cerror("%s: %d can't happen\n",__FILE__,__LINE__);

	found:
		SAFESTRCPY(new.dash[new.dashsz].label, "t");
		new.dashsz++;
#if 0
		printf("pointing temp at head[%d] %d\n", i,
		       new.dash[new.dashsz - 1].h);
#endif
		if (doxfer2(new, 2)) {	/* do at least 2 more */
		    return 1;
		    }
		}

	    return 0;		/* fail */
	    }
	}

    printf("%s", asgs);
    return 1;			/* succeed */
    }

/* I'm a safe copy if my destinations value is available elsewhere, or it's
 * not subsequently needed.   If I use a function call that is used
 * elsewhere, I must use it as a source (because qualified functions can
 * only be called once).
 */
static
safexfer(state, i)
    struct GraphState *state;
{
    char            trialpaths[MAXNAMES][MAXREQLEN];
    short           j;
    struct GraphState newstate;

#if 0
    printf("safexfer(%d) => ", i);
#endif

    /* what does this currently point to?	 */
    j = clook(state, state->dash[i].tails[0], state->dash[i].label);

    if (j == -1) {
#if 0
	printf("1\n");
#endif
	return 1;		/* nothing!	 */
    }
    /* darken the edge on a trial basis and see if everything's ok	 */
    newstate = *state;
    newstate.nextasg = 0;
    darken(&newstate, i);
    reach(&newstate, trialpaths);
    for (j = 0; j < newstate.dashsz; j++) {
	if (trialpaths[newstate.dash[j].h][0] == '!') {
#if 0
	    printf("0\n");
#endif
	    return 0;
	}
	if (newstate.dash[j].tails[0] &&
	    trialpaths[newstate.dash[j].tails[0]][0] == '!') {
#if 0
	    printf("0\n");
#endif
	    return 0;
	}
    }
#if 0
    printf("1\n");
#endif
    return 1;
}

/* find the node pointed to by label out of node v in current state */
static int
clook(state, t, lab)
    short           t;
    struct GraphState *state;
    char           *lab;
{
    int             i;

    for (i = 0; i < state->darksz; i++)
	if (state->dark[i].tails[0] == t && !skcmp(state->dark[i].label, lab))
	    return i;

    return -1;
}

/* Figure out which nodes are reachable from the xfroot along current paths */
reach(state, curpaths)		/* reaching computation	 */
    char            curpaths[][MAXREQLEN];
struct GraphState *state;
{
    int             i;
    for (i = 0; i < namesz; i++)/* initially, nothing can be reached */
	strcpy(curpaths[i], "!");
    *curpaths[0] = 0;		/* except the xfroot */
    reach2(state, 0, curpaths);	/* expand paths from xfroot (0) */
}

/* A call to reach2 asserts that we can get the given node's value by
 * uttering the string contained in curpaths[node].  The job of reach2 is to
 * find other reachable nodes that use this node and possibly others and to
 * fill in their curpaths[] entries.
 */
reach2(state, node, curpaths)
    struct GraphState *state;	/* gives list of darkened edges	 */
    char            curpaths[][MAXREQLEN];
int             node;		/* expand paths that start here	 */
{
    int             i, j, k;
    char           *vars[2];
#if 0
    printf("can reach node %d via '%s'\n", node, curpaths[node]);
#endif
    /* Whenever this new path is a new path to the tail of some dark	 */
    /* edge, and we have no path to its head or a worse one, and we	 */
    /* now have paths to all of the tails, make a new path to the head	 */
    /* by adding the paths to the tails to the label on the edge.	 */
    for (i = 0; i < state->darksz; i++) {
	for (j = 0; j < nelts(state->dark[i].tails); j++) {
	    if (state->dark[i].tails[j] == node) {
		if (curpaths[state->dark[i].h][0] == '!' ||
		    strlen(curpaths[state->dark[i].h]) > strlen(curpaths[node]) + 3) {
		    for (k = 0; k < nelts(state->dark[i].tails); k++)
			vars[k] = curpaths[state->dark[i].tails[k]];
		    if (expand(vars, state->dark[i].label,
			       curpaths[state->dark[i].h]))
			reach2(state, state->dark[i].h, curpaths);
		}
	    }
	}
    }
}


/* expand out %00+%01 with supplied values for %00 and %01 This is a smaller
 * version of ptoi.
 */
static
expand(vars, from, to)
    char          **vars, *from, *to;
{
    register char  *p;
    unsigned        v;
    char            bf[MAXREQLEN], *too = bf;

    do {
	if (ISVAR(from) && ((v = VAR(from)), vars[v])) {
	    from += VARLN;
	    if (!skcmp(vars[v], "!"))
		return 0;
	    for (p = vars[v]; *p; p++)
		*too++ = *p;
	}
    } while (*too++ = *from++);

    strcpy(to, bf);
    return 1;
}

/* Perform an assignment, darken its edge and delete any conflicting edge. */
static void
darken(state, e)
    struct GraphState *state;
    int             e;
{
    char           *vars[2];
    char            s[MAXREQLEN], *p, bf[MAXREQLEN], *q;
    struct Copy     c;
    short           j, k;

    c = state->dash[e];
    if (!skcmp(c.label, "")) {
	printf("here\n");
    }
#if 0
    printf("before darken\n");
    printf("asgs %s\n", asgs);
    dumpxfers(state, e);
#endif
    /* forget about a ::nn suffix for output purposes	 */
    SAFESTRCPY(s, paths[c.h]);
    while ((p = rindex(s, ':')) && p[-1] == ':') {
	strtol(p + 1, &q, 10);
	memmove(p - 1, q, (unsigned) strlen(p));
    }

    if (state->nextasg && skcmp(xfers[c.orig].comment, "suppress")) {
	for (k = 0; k < nelts(c.tails); k++)
	    vars[k] = paths[c.tails[k]];
	expand(vars, c.label, bf);
	sprintf(state->nextasg, "\t%-20s = %s;", bf, s);

#if 0
	printf("assuming assign %s\n", state->nextasg);
#endif
	state->nextasg += strlen(state->nextasg);

	if (xfers[c.orig].comment[0]) {
	    sprintf(state->nextasg, "\t/* %s */", xfers[c.orig].comment);
	    state->nextasg += strlen(state->nextasg);
	}
	strcpy(state->nextasg, "\n");
	state->nextasg++;
    }
    addark(state, c.h, c.tails[0], c.tails[1], c.label);

    for (j = e; j < state->dashsz - 1; j++)	/* shuffle the list	 */
	state->dash[j] = state->dash[j + 1];

    state->dashsz--;
}

static int dumpxfers(state, c)		/* debugging			 */
    struct GraphState *state;
    {
    int             i;
    printf("current:\n", c);

    for (i = 0; i < state->darksz; i++)
	printf("%02d: %02d->%-15s %02d\n",
	i, state->dark[i].tails[0], state->dark[i].label, state->dark[i].h);

    printf("\npending:\n");

    for (i = 0; i < state->dashsz; i++)
	printf("%02d: %02d->%-15s %02d\n",
	i, state->dash[i].tails[0], state->dash[i].label, state->dash[i].h);

    printf("\n\n");
    }

static sequences(cpp1, cpp2)		/* sort by increasing seqnos	 */
    struct Xfer    *cpp1, *cpp2;
    {
    return cpp1->seq - cpp2->seq;
    }

static safecomp(p1, p2)			/* sort by increasing priority */
    struct Copy	*p1, *p2;
    {
    return p1->prio - p2->prio;
#if 0
    /* sort the copies in this state by increasing priority */
struct GraphState {		/* a problem state		 */
    short           darksz;
    short           dashsz;
    struct Edge     dark[MAXCOPIES * 3]; /* current edges		 */
    struct Copy     dash[MAXCOPIES];	 /* desired edges		 */
    char           *nextasg;	/* end of asgs vector		 */
    }               xfroot;
    struct Copy {			/* a pending copy (an edge that	 */
	short           tails[2], h;/* must be darkened)		 */
	char            label[100];
	short           prio;	/* priority			 */
	short           orig;	/* original loc in dash vector	 */
				    /* used to index comments	 */
    }
#endif
    }


/* Set use counts.  There are three kinds of instructions:  inputs, outputs,
 * and innocent bystanders which are neither, but simply shuffled around like
 * pawns.
 */
struct Userec {
    char            unam[MAXREQLEN + 1];	/* name of ptr to instruction	 */
    int             additional;	/* adjust count by this much	 */
    int             init;	/* known initial count or UNKNOWN	 */
}               u[2][MAXCOPIES];
				/* the process is destructive	 */
int             nuses;		/* so we have two copies	 */

static
ulook(uname)			/* look up/install name in u	 */
    char           *uname;
{
    int             i;
    if (nuses == nelts(u[0])) {
	cerror("ulook: too many use recs\n");
    }
    SAFESTRCPY(u[0][nuses].unam, uname);
    SAFESTRCPY(u[1][nuses].unam, uname);
    for (i = 0;; i++)
	if (!skcmp(u[1][i].unam, uname))
	    break;
    if (i == nuses) {
	u[0][i].additional = u[1][i].additional = 0;	/* init to no change	 */
	u[0][i].init = u[1][i].init = UNKNOWN;	/* unknown initial val	 */
	nuses++;
    }
    return i;
}

#if 0
static
dumpuses()
{
    int             i;
    printf("\n\n i           name                additional orig\n");
    for (i = 0; i < nuses; i++) {
	printf("%02d %-30s %02d %03d\n",
	       i, u[1][i].unam, u[1][i].additional, u[1][i].init);
    }
    printf("\n\n");
}
#endif

static
compuse(urecpp1, urecpp2)
    struct Userec  *urecpp1, *urecpp2;
{
    return urecpp2->additional - urecpp1->additional;
}

knownuse(insname, init, bank)	/* assert that this instruction	 */
    char           *insname;	/* has a known initial usecount	 */
    int             init, bank;
{
    int             j;

    if (strlen(insname) > MAXREQLEN-1) {
	cerror("knownuse: insname '%s' too long");
    }
#if 0
    printf("knownuse insname %s init %d bank %d\n", insname, init, bank);
#endif
    if (!skcmp(insname, "NULL"))
	return;
    j = ulook(insname);		/* find slot		 */
    u[bank][j].init = init;
}

bumpuse(insname, additional, bank)	/* update use count	 */
    char           *insname;		/* name of instruction	 */
    int             additional;		/* increment or decrement amount */
    int             bank;		/* addressing uount?	 */
{
    int             j;

    if (strlen(insname) > MAXREQLEN-1) {
	cerror("bumpuse: insname '%s' too long");
    }
    if (!skcmp(insname, "NULL"))
	return;
    j = ulook(insname);		/* find slot		 */
    u[bank][j].additional += additional;	/* bump usage		 */
#if 0
    printf("bumpuse %s %d bank %d new %d\n", insname, additional,
	    bank, u[bank][j].additional);
#endif
}

olduse(insname)			/* get initial usecount of this	 */
    char           *insname;	/* instruction, if known	 */
{
    int             i;
    for (i = 0; i < nuses; i++)
	if (!skcmp(u[1][i].unam, insname))
	    return u[1][i].init;
    return UNKNOWN;
}

getuse(insname)			/* get final use count of this	 */
    char           *insname;	/* instruction, if known	 */
{
    int             i;
    for (i = 0; i < nuses; i++) {
	if (!skcmp(u[1][i].unam, insname)) {
	    if (u[1][i].init == UNKNOWN)
		return UNKNOWN;
	    else
		return u[1][i].init + u[1][i].additional;
	}
    }
    return UNKNOWN;
}

dekid(Opt, insname, lev)	/* simulate decrementuse at compile	 */
    char           *insname;	/* time when initial use	 */
    int             lev;	/* counts are known		 */
    struct Optrec  *Opt;
{				/* dec any result regs too	 */
    char            bf[1024];
    int             kid, last, n, inx;

    if(!(n = skinstall(Opt->old[lev].assem, sigs[Opt->old[lev].signumber])))
    {
	cerror("dekid: unable to find skeleton for %s\n",Opt->old[lev].assem);
    }
#if 0
    printf("dekid %s lev %d ", insname, lev);
    printf("skel %s # %d first %d last %d\n",
		   skelptr[n], n, kidlbn(n), kidubn(n));
#endif
    /*  This node is going away so decrement use counts of each of its kids */
    for (kid = kidlbn(n), last = kidubn(n); kid < last; kid++) {

	/*  search for kids among involved instructions */
	for (inx = lev - 1; inx >= 0; inx--) {
	    if (setsvar(&Opt->old[inx]) == Opt->old[lev].map[kid]) {
		sprintf(bf, "IKID(%s,%d)", insname, kid);
		bumpuse(bf, -1, 1);
		if (getuse(bf) == 0)
		    dekid(Opt, bf, inx);
		goto found;
	    }
	}

	/*  it must be an uninvolved instruction */
	sprintf(bf, "IKID(%s,%d)", insname, kid);
	bumpuse(bf, -1, 1);

    found:;
    }
}

/* Decrement use counts for anything used by the xfroot.  Increment	 */
/* use counts for all sources of transfers.				 */
docounts(Opt)
    struct Optrec  *Opt;
{
    int             i;

#if 0
    printf("docounts\n");
    for (i = 0; i < nxfers; i++) {
	printf("%s := %s seq %d prio %d comment %s\n",
	    xfers[i].dst, xfers[i].src, xfers[i].seq,
	    xfers[i].prio, xfers[i].comment);
	}
#endif

    bcopy(u[0], u[1], sizeof(u[0]));	/* make copy of u[0]	 */

    for (i = 0; i < nxfers; i++)	/* count counted asgs	 */
	if (!skcmp(xfers[i].comment, "counted"))
	    bumpuse(xfers[i].src, 1, 1);

    dekid(Opt, "r", (int) Opt->olen - 1);	/* decrement kids	 */
}

/* Output use counts calculated above					 */
outuse(Opt)
    struct Optrec  *Opt;
{
    char           *s;
    int             newuses, i, inct;

    qsort(u[1], nuses, sizeof(u[1][0]), compuse);	/* do incs first */

    for (i = 0; i < nuses; i++) {
	for (inct = Opt->olen - 1; inct >= 0; inct--)
	    if (!skcmp(inam(Opt, inct), u[1][i].unam))
		break;

	s = shorten(u[1][i].unam);
	if (u[1][i].init == UNKNOWN) {	/* unknown initial val	 */
	    if (u[1][i].additional < 0)
		decuses(Opt, inct, u[1][i].unam, -u[1][i].additional);
	    else if (u[1][i].additional == 1)
		printf("\t%s->count++;\n", s);
	    else if (u[1][i].additional)
		printf("\t%s->count += %d;\n", s, u[1][i].additional);
	}
	/* changing to a nonzero value?	 */
	else if (u[1][i].additional &&
		 (newuses = u[1][i].init + u[1][i].additional))
	    printf("\t%s->count\t=\t%d;\n", s, newuses);
    }
    nuses = 0;
}

static involved(nodename, Opt)		/* is this node involved?	 */
    char           *nodename;	/* node pointer name		 */
    struct Optrec  *Opt;	/* optimization			 */
    {
    int             i;
    for (i = 0; i < Opt->olen; i++)
	if (!skcmp(nodename, inam(Opt, i)))
	    return i;
    return -1;
    }

/* Emit code to decrement uses of an involved node and the innocent
 * bystanders.  This code assumes that no innocent bystander will ever be
 * decremented to zero, to completely unwind calls down to the level that
 * hits the bystander but no further.  A node is an innocent bystander if
 * it is a kid of an involved node but is not itself involved.
 */
static decuses(Opt, inct, nodename, decrements)
    int             decrements;	/* amount to change by		 */
    int             inct;	/* counts nodes in input chain	 */
    char           *nodename;	/* name of node			 */
    struct Optrec  *Opt;
{				/* and the innocent bystanders	 */
    int             kid, n, last, m;
    char            newname[MAXREQLEN];

#if 0
    printf("decuses %s inct %d decrements %d\n", shorten(nodename),
	    inct, decrements);
#endif
    if (decrements == 1)
	printf("\t%s->count--;\n", shorten(nodename));
    else
	printf("\t%s->count -= %d;\n", shorten(nodename), decrements);

    if (inct >= 0) {		/* involved?			 */
        if (!(n = skinstall(Opt->old[inct].assem,
			    sigs[Opt->old[inct].signumber])))
        {
	    cerror("decuses: unable to find skeleton for %s\n",
		   Opt->old[inct].assem);
        }
#if 0
	    printf("inct %d skel %s # %d first %d last %d\n",
		   inct, skelptr[n], n, kidlbn(n), kidubn(n));
#endif
        kid = kidlbn(n);
	if (kidlbn(n) != kidubn(n)) {
	    printf("\tif (%s->count == 0) {\n", shorten(nodename));
	    for (last = kidubn(n); kid < last; kid++) {
		sprintf(newname, "IKID(%s,%d)", nodename, kid);
		if ((m = involved(newname, Opt)) >= 0) {
#if 0
		    printf("%s involved too\n", newname);
#endif
		    decuses(Opt, m, newname, 1);
		} else
		    printf("\t    IKID(%s,%d)->count--;\n",
			   shorten(nodename), kid);
	    }
	    printf("\t    }\n");
	}
    }
}

/* Point to the character that balances with the left or right paren that is
 * pointed to by s.
 */
static char *balpar(first, s)
    char           *first;	/* points to first char in string */
    char           *s;		/* pointer to the opposing parenthesis */
    {
    int             level = 0;

    if (*s == LPAR) {
	for (;; s++) {
	    if (*s == LPAR)
		level++;
	    else if (*s == RPAR) {
		level--;
		if (level == 0)
		    return s;
		else if (level < 0)
		    return 0;
		}
	    else if (*s == 0)
		return 0;
	    }
	}
    else if (*s == RPAR) {
	for (;; s--) {
	    if (*s == RPAR)
		level++;
	    else if (*s == LPAR) {
		level--;
		if (level == 0)
		    return s;
		else if (level < 0)
		    return 0;
		}
	    else if (s <= first)
		return 0;
	    }
	}
    return 0;
    }
