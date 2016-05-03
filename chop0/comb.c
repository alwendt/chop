/* Copyright (c) 1991 Alan Wendt.  All rights reserved.
 * You have this code because you wanted it now rather than correct. Bugs
 * abound!  Contact Alan Wendt for a later version or to be placed on the
 * chop mailing list.
 *
 * Alan Wendt / Computer Science / Colorado State Univ. / Ft Collins CO 80523
 * 303-491-7323.  wendt@cs.colostate.edu
 */

/* comb.c -- Symbolic instruction combiner
 *
 * comb tries to combine instructions in the current dag.  The maximum input dag
 * size is increased by one if comb finds an optimization of maximum input
 * size.
 *
 * When comb has assembled a subdag for trial, it calls initopt.  initopt
 * records information about the subdag.  Then comb calls factor to produce
 * all possible factorizations of the composed instruction. tryopt gets costs
 * for the new instructions.  When it finds an	instruction or pair that is
 * better than the best one encountered	so far, it records this information
 * in the bestopt optimization	record and bestout, a vector of instructions.
 *
 * When comb has made all the trials for a given input-output size, it
 * calls performopt.  If tryopt has found something better than	the original
 * instructions, performopt will perform the edit.
 *
 * comb returns 1 as soon as it makes a change to the program.  It returns 0 if
 * it exhausts all possibilities for improvement.
 *
 * comb tests the subdags of an input dag in lexicographic order so that the
 * rules that are found can be sorted in that order for efficient testing.
 * Within each subdag, nodes are listed in preorder. Between two subdags,
 * "epsilon" sorts to the end so that ab follows abc and longer inputs get
 * tried first.
 *
 * For the dag
 *
 *                   a
 *                  / \
 *                 b   c
 *                  \ /
 *                   d
 *
 * the proper order is:
 *
 *           a b c d d'
 *           a b c d
 *           a b c d'
 *           a b c
 *           a b d
 *           a b
 *           a c d'
 *           a c
 *           a
 *
 * Where d' denotes node d considered as the child of node c rather than as the
 * child of node b.
 *
 * The following rules seem to generate this order:
 *
 * 1.  Begin by pushing the root instruction onto the initially empty list.
 *
 * 2.  Each list entry has a nextkid value, that gives the next kid number of
 *     that instruction to add.  When you push instruction node xyz onto the
 *     list at postion j, set nextkid[j] := 1.
 *
 * 3.  Push the next kid of the lowest list entry that has a next kid, subject
 *     to rule 4.  Bump the nextkid value of that entry.
 *
 * 4.  Never push kid j of entry k if there is already a higher-or-same numbered
 *     kid of that entry in the list.  This maintains the node listing in
 *     preorder.
 *
 * 5.  Pop the last entry of the list if rule 3 cannot extend the list.  When
 *     you pop entry j, check to see if it's the last kid of its parent entry k.
 *     If so, reset the nextkid values for all entries strictly between j and k.
 *     If not, set nextkid[k] to whatever kid j was, plus 1.
 *
 * 6.  Evaluate the list (as a candidate input side for an optimization)
 *     immediately before removing an entry as described in rule 5.
 */

#define FUDGE    0.01		/* cost per instruction count, to encourage shorter outputs */

#include <stdio.h>
#include <ctype.h>
#include "c.h"
#include "hop2.h"
#include "md.h"

struct Optrec   null_optrec;
/* tryopt stores the best opt so far in these two data structures	 */
static struct Optrec bestopt;	/* initial opt record		 */

static struct Optrec oin;	/* initial opt record		 */

static          checkeval();
static          evaluable();
static void     factor();
static unsign16 find();
static double   getcost();
static          getrt();	/* get rt for assembler input	 */
static void     getsubexprs();	/* factor an rt up into pieces	 */
static          goodsubexpr();
static void     incrementuse();
static void     initins();	/* initialize instruction rec	 */
static          initopt();
static int	fillinrt();
static int	newvar();
static int      performopt(), combn();
extern          regmove();	/* am I a reg->reg copy?	 */
static void     recordopt();
static          replace();
static          setvars();
static double   try();		/* try adding an output ins	 */
static char    *typof();

/*  Nonzero if comb is in a special mode in which it generates all possible
 *  1->n code generation rules by cobbling up small dags.
 */
int   doing_onesies = 0;


static int      maxvar;		/* high global var used		 */
static int      bigkid;		/* costliest input not root	 */

/* old[i] contains information about the i'th instruction on the input side
 * of the current optimizations being considered. old entries are numbered
 * from MAXOPTSIZE-oldlen to MAXOPTSIZE-1 with old[MAXOPTSIZE-1] being the
 * root input.
 */
static struct {
    char            rtin[MAXRTLINE];	/* input		 */
    struct node     *insin;	/* input instruction	 */
    double          costin;	/* tweaked cost of old[i].insin. */
    int             parno;	/* parent number of i (> i)	 */
    int             kidno;	/* kid # of i in old[i].parno	 */
    int             depth;	/* depth of node, root = 0	 */
    int             nextkid;	/* next kid to try from this parent */
    }               old[MAXOPTSIZE];

/* new[i] contains information about the i'th instruction on the output side
 * of the current optimizations being considered.  new entries are numbered
 * from 0 to newlen - 1 with new[newlen - 1] being the root output. Entries are
 * added in increasing order.
 */
static struct {
    char            rtout[MAXRTLINE];	/* output reg xfer	 */
    struct node     *insout;	/* output instruction	 */
    double          costout;	/* tweaked costs of output */
    struct node     bestout;	/* best output instruction */
    struct node     out;	/* new output instruction  */
    char            result[MAXRTLINE];	/* result field		 */
    }               new[MAXOPTSIZE];

static char     rttot[MAXRTLINE];	/* total effect		 */
/* max input len to try size of biggest x->1 opt found plus 1		 */
static int      maxoldlen = min(MAXOPTSIZE, 8);
static int      newlen;		/* output optimization length; # of entries in new */
static int      oldlen;		/* input optimization length; # of entries in old */

/* bopts[k] is best known opt that has k slots filled.		 */
static struct Optrec bopts[MAXOPTSIZE + 1];

static int      nsubexprs;	/* how many?      */

/* a list of newlen - 1 indeces into subexprs -- the subexpressions to be
 * chosen for this factoring.
 */
static int      subices[MAXOPTSIZE] = {-1};

static struct Subexpr {
    struct Subexpr *parent;	/* pointer to enclosing subexpr */
    char           *str;	/* where I start in rttot       */
    short           len;	/* length of my string in rttot */
    short           nkids;	/* how many subexprs do I contain */
    short           chosen;	/* am I included in the opt already? */
    }               subexprs[100];

/* ents[i] points to subexpr containing rttot[i] */
static struct Subexpr ents[sizeof(rttot)];

/* define ALTERNATING to simplify the rt and test it for instructionhood
 * alternately; the alternative is to simplify it completely before any
 * testing occurs.
 */

#define ALTERNATING 1

/* define SIMPFIRST = 1 if comb should simplify an effect before factoring it.
 */

#define SIMPFIRST 1

#define SIMPCYCLES 8
static int      simpcycles = 2;

/*  Counts # of opts by input & output size. */
int	rewct[2][MAXOPTSIZE + 1][MAXOPTSIZE + 1];

/* comb(r) r = root pointer of a dag.
 * comb tries optimizations of succesively larger output sizes
 * by repeated calls to combn.  It returns 1 if it succeeds and 0 if no combn
 * call finds an optimization.
 */
comb(r)
    struct node  *r;		/* return 1 if any changes	 */
    {
    for (newlen = 1; newlen < MAXOPTSIZE; newlen++)
	if (combn(r, doing_onesies ? 1 : MAXINPUTLENGTH))
	    return 1;
    return 0;
    }

/* combn(r,maxinput) r = root pointer of a dag
 * Global newlen gives the length of the output side of any opt to be found.
 *
 * combn is mostly a generator for all rooted subdags of the dag rooted at r, of
 * sizes up to MAXOPTSIZE.  Subdags are considered in an order that will give
 * a decision tree of tests when the optimizations found are converted into
 * rules and generated into C code in the production compiler.
 *
 * When combn has generated a candidate subdag, it calls attempt() to try to use
 * the subdag as the input side of an optimization.  If attempt finds an
 * optimization, it will perform it, and combn will then call opt() on each
 * new child, which will result in recursive calls to combn.
 */
#define trace_combn 0
static int combn(r, maxinputlength)
    struct node  *r;		/* return 1 if any changes	 */
    int		maxinputlength;
    {

    /* this routine is recursive, do not make these vars static */

    struct node  *tempins[MAXOPTSIZE], *kid;
    int		    ix;
    int             v, locv, tmpnlen, kidno;
    int             nextkid;			/* next kid # to be added	 */
    int             j;


#if trace_combn
    printf("combn(%d) op %d\n", r, r->op);
#endif

    patp = patterns;				/* reset pattern allocator */

    oldlen = 1;					/* # of entries on old list*/
    old[MAXOPTSIZE - oldlen].insin = r;		/* save root pointer	 */
    old[MAXOPTSIZE - oldlen].depth = 0;		/* the root                   */
    old[MAXOPTSIZE - oldlen].parno = -1;	/* no parent                  */
    old[MAXOPTSIZE - oldlen].kidno = -1;	/* this is not a kid          */
    fillinrt(r);
    old[MAXOPTSIZE - oldlen].nextkid = kidlb(r);

    /* add the next kid of the first list entry that has a next kid */

addnext:
    for (ix = MAXOPTSIZE - 1; ix >= MAXOPTSIZE - oldlen; ix--) {

#if trace_combn
	printf("old[%d] '%s' kidlb %d kidub %d\n",
	    ix, skelptr[old[ix].insin->op],
	    kidlb(old[ix].insin), kidub(old[ix].insin));
#endif

	/* List siblings in increasing order only.			 */
	/* find highest kid of ix that is already listed.		 */
	nextkid = -1;
	for (j = MAXOPTSIZE - oldlen; j < MAXOPTSIZE - 1; j++) {
	    if (old[j].parno == ix && nextkid < old[j].kidno + 1)
		nextkid = old[j].kidno + 1;
	    }

	if (nextkid < old[ix].nextkid)
	    nextkid = old[ix].nextkid;

	if (nextkid < kidub(old[ix].insin)) {
	    old[ix].nextkid++;
	    if (oldlen < maxinputlength) {
		oldlen++;
		old[MAXOPTSIZE - oldlen].insin = IKID(old[ix].insin, nextkid);
		fillinrt(old[MAXOPTSIZE - oldlen].insin);
		old[MAXOPTSIZE - oldlen].kidno = nextkid;
		old[MAXOPTSIZE - oldlen].parno = ix;
		old[MAXOPTSIZE - oldlen].depth = old[ix].depth + 1;
		if (IKID(old[ix].insin, nextkid) == 0) {
		    fprintf(stderr, "chop0 is confused about the instruction '%s' rt '%s': it thinks that %%%02d is a register.\n", INSRT(old[ix].insin), skelptr[old[ix].insin->op], nextkid);
		    fprintf(stderr, "This may have happened because the regpatts entry in special.c has an entry that looks like a memory cell.\n");
		    fprintf(stderr, "On the Vax, we hacked this problem by using \"mm(...)\" instead of \"m(...)\" to refer to a stack temp.\n");

		    exit(-1);
		    }
		old[MAXOPTSIZE - oldlen].nextkid =
		       kidlb(IKID(old[ix].insin, nextkid));
		goto addnext;
		}
	    }
	}

    /* Cannot lengthen list, evaluate as is */
#if trace_combn
    printf("about to attempt %d->%d:\n", oldlen, newlen);
    for (j = MAXOPTSIZE - oldlen; j < MAXOPTSIZE; j++) {
	printf("old[%d] = %s op %d kids %d-%d kidno %d parno %d\n",
	    j, skelptr[old[j].insin->op], old[j].insin->op,
	    kidlb(old[j].insin), kidub(old[j].insin) - 1,
	    old[j].kidno, old[j].parno);
	}
    printf("\n");
#endif
    v = attempt();

    /* filling from 0 up to MO-2	 */
    if (v == 1) {
	/* remember all outputs except for the root.	 */
	tmpnlen = newlen;
	for (ix = 0; ix < tmpnlen; ix++)
	    tempins[ix] = new[ix].insout;

	/* optimize all children of new nodes.		 */
	/* I do not know why this code tests the use count of the new nodes??? */
	for (ix = 0; ix < tmpnlen; ix++) {
	    if (ix == tmpnlen - 1 || tempins[ix]->count) {
		for (locv = kidlb(tempins[ix]); locv < kidub(tempins[ix]); locv++) {
		    kid = IKID(tempins[ix], locv);

		    if (kid && kid->count)
			opt(kid);
		    }
		}
	    }

	return 1;		/* found something		 */
	}

    /* Shorten the list if possible, otherwise give up. */
    if (oldlen == 1) {
	return 0;
	}

    /* implement rule 5 of the dag-enumeration rules */
    if (old[MAXOPTSIZE - oldlen].kidno ==
	   kidub(old[old[MAXOPTSIZE - oldlen].parno].insin) - 1) {
	for (v = MAXOPTSIZE - oldlen + 1;
	       v <= old[MAXOPTSIZE - oldlen].parno - 1; v++)
	    old[v].nextkid = kidlb(old[v].insin);
	}
    else
	old[old[MAXOPTSIZE - oldlen].parno].nextkid = old[MAXOPTSIZE - oldlen].kidno + 1;
    oldlen--;
    goto addnext;
    }

/* Old entries from MAXOPTSIZE - oldlen ix to MAXOPTSIZE - 1 have been filled in with input
 * instructions for candidate optimizations.  attempt() calls initopt to set
 * up a sample optimization record from these inputs.  It then does the
 * symbolic substitution for all of the input rt's to build a total rt for
 * the entire input set of instructions.  Then it calls factor() to break the
 * total rt down in all possible different ways that result in newlen output
 * instructions.  factor() leaves the best breakdown in a structure called
 * "bestopt".  If bestopt gets set up, performopt() is called to actually
 * perform the optimization.
 */
#define trace_attempt 0
attempt()
    {
    char           *b;
    char            dst[MAXRTLINE], src[MAXRTLINE], typ[20];
    int             i;
    int             nrefs[MAXGLOBALS];
    int             reset;
    int		    replacement;
#if SIMPFIRST
    int             k;
#endif

    if (oldlen <= 2 || newlen <= 3) {

	if (!initopt()) {
	    return 0;
	    }

	/* remember input patterns */
	SAFESTRCPY(rttot, old[MAXOPTSIZE - 1].rtin);

	/* Construct output rt by substituting children into the parent
	   This is the key six lines of code in the entire system. */
	for (i = MAXOPTSIZE - 2; i >= MAXOPTSIZE - oldlen; i--) {
	    if (gtds(old[i].rtin, dst, src, typ)) {
		replacement = 0;
		for (b = old[i].rtin; b = gtds(b, dst, src, typ);)
		    replacement |= replace(rttot, dst, src, typ);
		if (!replacement) {
		    fprintf(stderr, "no replacement made for %s into %s\n",
			old[i].rtin, rttot);
		    fprintf(stderr, "Probably the machine description definitions for one of these instructions is wrong.\n");
		    for (i = MAXOPTSIZE - 1; i >= MAXOPTSIZE - oldlen; i--) {
			fprintf(stderr, "old[%d] assem %s rt %s\n",
			    i, skelptr[old[i].insin->op], old[i].rtin);
			}
		    cerror("aborting...\n");
		    }
		}
	    }

	if (!*rttot)
	    cerror("bad rttot");

#if trace_attempt || DEBUG
	printf("%d->%d rttot %s\n", oldlen, newlen, rttot);
#endif

#if SIMPFIRST
	/* Simplify the new output, and add necessary constraints to the
	   input optimization oin. */
	/* SUPPRESS 36 */
	for (k = 0; k < SIMPCYCLES && simp(rttot, &oin); k++) {
#if DEBUG
	    printf("simp-> '%s'\n", rttot);
#endif
	    ;
	    }
#endif

	bopts[0] = oin;

	/* Count # of references to each input variable. */
	for (i = FIRSTVAR; i < MAXGLOBALS; i++)	{
	    bopts[0].o_refct[i] = 0;
	    }

	gtds(rttot, dst, src, typ);	/* uncount the writes */

	/* Count # of reads of each variable. */
	for (b = src; *b; b++)
	    if (ISVAR(b))
		bopts[0].o_refct[VAR(b)]++;

	if (regvarb(dst) == NOVAR)
	    for (b = dst; *b; b++)
		if (ISVAR(b))
		    bopts[0].o_refct[VAR(b)]++;

	getsubexprs(rttot);	/* get all subexpressions */

	for (reset = 1; choose(nsubexprs - 1, newlen - 1, subices + 1, reset); reset = 0) {

	    for (i = 0; i < newlen; i++)
		subexprs[subices[newlen - 1 - i] + 1].chosen = 1;
#if trace_attempt
	    printf("\nattempt: trying:\n");
	    for (i = 0; i < newlen; i++)
		printf("subs[%d] = %*s%.*s\n",
		       subices[newlen - 1 - i] + 1,
		       subexprs[subices[newlen - 1 - i] + 1].str - rttot, "",
		       subexprs[subices[newlen - 1 - i] + 1].len,
		       subexprs[subices[newlen - 1 - i] + 1].str);
	    printf("\n\n");
#endif
	    factor(0, 0.0, __LINE__);

	    for (i = 0; i < newlen; i++)
		subexprs[subices[newlen - 1 - i] + 1].chosen = 0;
	    }

	i = performopt();	/* do your best!	 */
	return i;
	}
    return 0;
    }

/* Add the ix'th output instruction to the optimization being developed in bopts[ix + 1].
 * Inputs:
 *    ix ranges from 0 to newlen - 1.
 *    bopts, a vector of optimization records.  bopts[k] has had k output instructions added.
 *    subices, a vector of subexpression numbers chosen.
 *    subexprs, a vector of possible subexpressions.
 *    costsofar, cost of previous instructions.
 */

#define trace_factor 0
static void factor(ix, costsofar, fromline)
    int             ix;		/* next slot to fill working up to newlen - 1 */
    double          costsofar;	/* cost of previous ix instructions produced. */
    int             fromline;	/* source line of call to factor	     */
    {
    char            dst[MAXRTLINE], src[MAXRTLINE], typ[20];
    char            currstr[MAXRTLINE];	/* hold the new subexpression */
    char            newrt[MAXRTLINE];	/* the new register transfer  */
    struct Subexpr *curr = &subexprs[subices[newlen - 1 - ix] + 1];
    struct Subexpr *kid, *t;
    int             leftlen;
    int             tmpvar;
    int             i;
    double          newcost;
    int             currlen;
    char           *b;

    bopts[ix + 1] = bopts[ix];

#if 0
    printf("factor: bopts[%d] := bopts[%d] reqs %s\n",
	ix+1, ix, bopts[ix+1].o_reqs);
#endif

    sprintf(currstr, "%.*s", curr->len, curr->str);
    currlen = curr->len;

    /* Find previously-handled subexpressions that are children of the
       current expression, and remove them.  If there are multiple
       children, we must remove them from right to left. Why R->L? Because
       when we edit a subexpression on the left, we change the text addresses
       of all the subexpressions to the right of it.
     */

    /* For each previously-handled subexpr in the output */
    for (i = ix - 1; i >= 0; i--) {
	kid = &subexprs[subices[newlen - 1 - i] + 1];

	/* find this kid's closest chosen ancestor (CCA) */
	for (t = kid->parent; t->chosen == 0; t = t->parent) {
	    continue;
	    }

	/* replace the kid in the current subexpression if it is the CCA */
	if (t == curr) {
	    /* replace this subexpression by its result */
	    leftlen = kid->str - curr->str;
	    sprintf(newrt, "%.*s%s%.*s",
		   leftlen, currstr, new[i].result,
		   currlen - leftlen - kid->len,
		   currstr + leftlen + kid->len);
	    SAFESTRCPY(currstr, newrt);
	    }
	}

    /* Count # of reads of each variable. */
    for (b = currstr; *b; b++)
	if (ISVAR(b))
	    bopts[ix + 1].o_refct[VAR(b)]--;

    gtds(currstr, dst, src, typ);

    if (regvarb(dst) == NOVAR)
	for (b = dst; *b; b++)
	    if (ISVAR(b))
		bopts[ix + 1].o_refct[VAR(b)]--;


    tmpvar = getvar(&bopts[ix + 1], 0, __FILE__, __LINE__);
    bopts[ix + 1].o_refct[tmpvar] = 0;

#if trace_factor
    printf("factor %d of %d: subexpression '%s'\n", ix, newlen, currstr);
    printf("remaining reference counts: ");
    for (i = 0; i < MAXGLOBALS; i++) {
	if (bopts[ix + 1].o_refct[i])
	    printf("%2d ", i);
	}
    printf("\n                            ");
    for (i = 0; i < MAXGLOBALS; i++) {
	if (bopts[ix + 1].o_refct[i])
	    printf("%2d ", bopts[ix + 1].o_refct[i]);
	}
    printf("\n\n");
#endif

    /* if this is the root, check it out */
    if (ix == newlen - 1)
	factor1(currstr, costsofar);

    /* else evaluate this expression into each different kind of register */
    else {
	for (i = 0; i < NOREG; i++) {
	    if (regpatts[i].many) {
		SAFESTRCPY(new[ix].result, regpatts[i].rt);
		changevar(new[ix].result, 0, tmpvar);
		sprintf(newrt, "move(%s,%s,%s)", currstr, new[ix].result,
		       typof(curr->str, curr->str + curr->len, rttot));

		/* store new rt */
		SAFESTRCPY(new[ix].rtout, newrt);

		newcost = try(newrt, ix, __LINE__);
#if trace_factor
		printf("try %s cost %f bestopt.ncost %f\n",
		    newrt, newcost, bestopt.ncost);
#endif
		newcost += costsofar;

		/* no point in continuing if parent is bogus or expensive */
		if (newcost < BOGUS && newcost < bestopt.ncost) {
		    factor(ix + 1, newcost, __LINE__);
		    }
		}
	    }
	}
    }


/* Make an optimization record from the instructions recorded in the old
 * vector. Renumber the input patterns to make all numbers unique except for
 * temporary registers. Initialize the global kids and vars vectors, which
 * point to innocent bystanders and strings used by the instructions.
 * Initialize the input side of the optimization rule.  Get input costs.
 */
#define trace_initopt 0
static initopt()
    {
    extern int      lineno;
    struct patrec  *patrec;
    int             i, j;	/* instruction counter			 */
    int             globv, v;
    double          ccost;	/* cost of current instruction		 */
    char           *s, *t;
    int             olddepth;	/* depth of deepest node on input side	 */
    int             locv;

    /* kmap[i][v] is the var # in old[i].insin	corrsponding to global %v
       in rt[i], after the rt's have been globalized */
    signed char		kmap[MAXOPTSIZE][MAXGLOBALS + MAXFREENONTERMS];
    char		bf[MAXRTLINE];

    oin = null_optrec;		/* best opt so far is no opt		 */
    oin.olen = oldlen;
    bestopt = oin;
    bestopt.nlen = 99;
    oin.nlen = newlen;

    for (i = 0; i < MAXOPTSIZE; i++)	/* init kmap	 */
	for (v = 0; v < MAXGLOBALS + MAXFREENONTERMS; v++)
	    kmap[i][v] = NOVAR;

    /* Move var values from inputs into opt record, renumber vars in input
       strings so that all numbers are unique. */
    maxvar = -1;
    olddepth = 0;		/* depth of input side		 */

    /* renumber the parents before their kids	 */
    for (i = MAXOPTSIZE - 1; i >= MAXOPTSIZE - oldlen; i--) {
#if trace_initopt
	printf("initopt: assem %s ", skelptr[old[i].insin->op]);
	if (!INSRT(old[i].insin)) {
	    printf("and the rt is NULL\n");
	    }
	else {
	    printf("and the rt is %s\n", INSRT(old[i].insin));
	    }
#endif
	if (!INSRT(old[i].insin))	/* punt if we do not know what the */
	    return 0;			/* instruction does                */

	/*  punt if this is a marker node that should not be optimized through */
	if (INSCOST(old[i].insin) > BOGUS * 2)
	    return 0;

	if (old[i].depth > olddepth)	/* accumulate input depth          */
	    olddepth = old[i].depth;

	/* copy the input rt's and globalize their variable numbers */
	SAFESTRCPY(old[i].rtin, INSRT(old[i].insin));
#if trace_initopt
	printf("initopt: globalizing old[%d].rtin '%s'\n", i, old[i].rtin);
#endif
	for (s = old[i].rtin; *s; s++)
	    if (ISVAR(s)) {
		globv = newvar(locv = (int)VAR(s), i, kmap);
		if (globv == NOVAR)
		    return 0;

		SETVAR(s, globv);

		oin.o_numbers &= ~(1 << globv);
#if USE_NUMBERS
		if (sigs[signo(old[i].insin->op)].numbers & (1 << locv)) {
		    oin.o_numbers |= (1 << globv);
		    }
#endif
		}

#if trace_initopt
	printf("initopt: result '%s'\n", old[i].rtin);
#endif

	/* The root input instruction has no result register, but all
	   other input instructions must have result registers. */
	if (i != MAXOPTSIZE - 1 && setslvar(old[i].rtin) == NOVAR)
	    cerror("'%s' has no result", INSRT(old[i].insin));
	}

    /* Get global equivalents for each assembly language variable  that
       was not gotten while scanning the register transfers. Then call
       cvtpatt to construct a pattern with all the needed variable
       mappings. */
    for (i = MAXOPTSIZE - 1; i >= MAXOPTSIZE - oldlen; i--) {
	/* SUPPRESS 57 */
	for (s = skelptr[old[i].insin->op], t = bf; *t = *s; s++, t++) {
	    if (ISVAR(s)) {
		globv = newvar(locv = (int)VAR(s), i, kmap);
		if (globv == NOVAR)
		    return 0;
		SETVAR(t, globv);
		oin.o_numbers &= ~(1 << globv);
#if USE_NUMBERS
		if (sigs[signo(old[i].insin->op)].numbers & (1 << locv))
		    oin.o_numbers |= (1 << globv);
#endif
		s += VARLN - 1;
		t += VARLN - 1;
		}
	    }

	/* SUPPRESS 36 */
	if (!(patrec = cvtpatt(&oin, old[i].rtin, bf, INSCOST(old[i].insin) >= BOGUS)))
	    return 0;

	patrec->signumber = signo(old[i].insin->op);
	patrec->cost = INSCOST(old[i].insin);
	oin.old[i] = *patrec;
#if 0
	printf("/* initopt: oin.old[%d]->cost %2f %s */\n",
	    i, patrec->cost, patrec->assem);
#endif
	oin.old[i].p_rt = string(patrec->p_rt);
	}

    /* set up kids and vars pointers in the optimization record.
       oin.kids[x] gets a pointer to the instruction record for the
       innocent bystander instruction that sets global variable %x,    if
       there is one. oin.vars[x] gets a pointer to the string value of
       global %x */

    for (globv = 0; globv < MAXGLOBALS + MAXFREENONTERMS; globv++) {

	/* work from leaves up to root */
	for (i = MAXOPTSIZE - oldlen; i < MAXOPTSIZE; i++) {

	    /* Does this instruction mention global var globv?  If so, get
	       the local variable */
	    if ((v = kmap[i][globv]) != NOVAR) {

		/* is the field within the instruction a kid pointer */
		if (kidlb(old[i].insin) <= v && v < kidub(old[i].insin)) {

		    /* is this kid in the optimization? if so, we do not
		       want to store its address */
		    for (j = MAXOPTSIZE - oldlen; j < i; j++) {
			if (old[j].parno == i && old[j].kidno == v) {
			    goto involved;
			    }
			}

		    OKID(&oin, globv) = IKID(old[i].insin, v);
		    goto next;
		    }

		/* if it's a string pointer, put value in oin.vars[globv] */
		else if (varlb(old[i].insin) <= v && v < varub(old[i].insin)) {
#if USE_NUMBERS
		    Numbers are screwed up currently due to lcc rehost.
		    if (oin.o_numbers & (1 << globv))
		        ONUM(&oin, globv) = INUM(old[i].insin, v);
		    else 
#endif
		        OSYM(&oin, globv) = ISYM(old[i].insin, v);
		    goto next;
		    }
		}
    involved:;
	    }
next:	;
	}

    /* get costs of input side weighted higher, reg->reg moves at the leaf
       costs nothing	copy variable and kid pointers out of the input
       instructions bigkid := index to most expensive non-root instruction
       in input */
    bigkid = MAXOPTSIZE - 2;
    for (i = MAXOPTSIZE - oldlen; i < MAXOPTSIZE; i++) {
#if 0
	if (!getrt(&oin, i))
	    cerror("bogus getrt cost input `%s'", oin.old[i].assem);
#endif
	ccost = oin.old[i].cost;
	/* SUPPRESS 57 */
	oin.old[i].assem = skelptr[old[i].insin->op];
	if (i == MAXOPTSIZE - oldlen && oldlen >= 2 &&
	       regmove(oin.old[i].p_rt) && ccost < BOGUS)
	    ccost = 0;
	old[i].costin = ccost;
	old[i].costin *= 1 + (MAXOPTSIZE - 1 - i) * FUDGE;
	if (i < MAXOPTSIZE - 1 && old[i].costin > old[bigkid].costin)
	    bigkid = i;
	}

    oin.ncost = 0;
    for (i = MAXOPTSIZE - oldlen; i < MAXOPTSIZE; i++) {
	if (i != bigkid)
	    oin.ncost += old[i].costin;
	}

    bestopt.ncost = oin.ncost;
    if (oldlen >= 2)
	bestopt.ncost += old[bigkid].costin / old[bigkid].insin->count;

    /* Don't try x->3 or greater unless the cost of x is currently illegal
       and x is one instruction. */
    if ((bestopt.ncost < BOGUS || 1 < oldlen) && 2 < newlen) {
	/* bad opt */
	fflush(stdout);
	return 0;
	}
    /* good opt */
    fflush(stdout);
    return 1;
    }

/* insert a new subexpression into the containment tree */
install_subexpr(first, len)
    char           *first;
    int             len;
    {
    struct Subexpr *subexpr;	/* the current subexpr installed */
    struct Subexpr *kid;	/* a subexpr that we contain     */
    struct Subexpr *parent;	/* a subexpr that contains us    */
    int             j;
    /* add this subexpression to the linear list */
    subexprs[nsubexprs].str = first;
    subexprs[nsubexprs].len = len;
    subexprs[nsubexprs].nkids = 0;
    subexpr = &subexprs[nsubexprs];
    nsubexprs++;

    /* Insert into the container tree. Occurrences and elements of
       sequences contain pointers to the sequence elements that contain
       them */

    /* for each character in this new subexpression */
    for (j = 0; j < len;) {
	kid = &ents[first + j - rttot];	/* old container for this char */
	for (;;) {
	    parent = kid->parent;	/* point to its container */
	    if (!parent || parent->len > subexpr->len) {

		/* parent will enclose us, we enclose kid */
		kid->parent = subexpr;
		subexpr->parent = parent;

		/* advance instruction counter past the thing that we
		   enclose */
		if (kid == &ents[first + j - rttot])
		    j++;
		else
		    j = (kid->str - rttot) + kid->len;
		break;
		}
	    kid = parent;
	    }
	}
    }


/* This function builds in subexprs[] and subexprlens[] a list of all of the
 * subexpressions of the input register transfer which might could be
 * computed separately from the remainder of the expression. Actually we are
 * limited to the first 100 subexpressions. If this instruction moves some
 * expression into a destination, we must avoid extracting the destination as
 * a subexpression.
 */

#define trace_getsubexpr 0
static void getsubexprs(rt)
    char           *rt;		/* what to factor			 */
    {
    int             len;	/* char length of rttot	 */
    char            src[MAXRTLINE], dst[MAXRTLINE], typ[20];
    char           *first, *end;
    int             i, j;
    char            tmp[MAXRTLINE];
    char            parrt[MAXRTLINE];	/* parent rt		 */
    char            kidrt[MAXRTLINE];	/* kid rt		 */
    char           *ty;
    int             tmpvar;


#if trace_getsubexpr
    printf("getsubexpr(%d)\n", rt);
#endif

    /* initialize the subexpression tree to contain the entire rttot */
    nsubexprs = 1;
    subexprs[0].str = rttot;
    subexprs[0].len = strlen(rttot);
    subexprs[0].parent = NULL;
    subexprs[0].nkids = 0;

    /* If we are only generating one output, it will be subexprs[0] */
    if (newlen == 1)
	return;

    for (i = 0; i < subexprs[0].len; i++)
	ents[i].parent = &subexprs[0];

    gtds(rt, dst, src, typ);	/* get destination if there is one */
    /* else src is truncated           */

    len = strlen(rt);

    /* Try each "balanced" substring of total effect except dst, and try
       each different kind of register for a resultvar.  Balanced
       substrings must start immediately following a comma or LPAR, or at
       the beginning of the string.  They must end immediately before a
       comma or RPAR, or at the end of the string.  They must also be
       parenthesis-balanced and must not contain any commas at level zero
       ( the string "abc,xyz" is not a balanced substring ).  Also it is
       not possible to extract the destination of a register transfer as a
       subexpression.  This code catches the beginning and ending
       conditions and leaves the rest to "goodsubexpr". */

    for (first = rt; *first; first++) {
	if (first == rt || first[-1] == ',' || first[-1] == LPAR) {
	    /* go to next , RPAR or the end of string */
	    for (end = first + 1; end[-1]; end++) {
		if ((*end == ',' || *end == RPAR || *end == 0) &&
		/* balanced parens and != dst string */
		/* note that the dst string could be */
		/* a source somewhere else! */
		       (goodsubexpr(first, end, dst) ||
		/* if we are the same string as the destination but not
		   the destination, we are ok 6 = strlen("move(") +
		   strlen(",")      ) 10 = strlen("par(move(")) +
		   strlen(",")    ) */
			      (dst[0] && !strcmp(first, dst) &&
				     (first != (rt + strlen(src) +
						   (*rt == 'p' ? 10 : 6))))) &&
		/* get type */
		       (ty = typof(first, end, rt)) &&
		/* make sure it is a type */
		       isalpha(ty[0])) {

		    install_subexpr(first, end - first);
		    goto nextsubstart;
		    }
		}
	    }
nextsubstart:;
	if (nsubexprs == nelts(subexprs))
	    break;
	}

    /* count kids */
    for (i = 0; i < nsubexprs; i++)
	if (subexprs[i].parent)
	    subexprs[i].parent->nkids++;

    /* Mark leaves that cannot be evaluated into one of the registers.
       These cannot contribute to a factoring. */
    for (i = 0; i < nsubexprs; i++)
	checkeval(&subexprs[i]);

    /* Delete things that cannot be evaluated, fix parent pointers */
    for (i = 0; i < nsubexprs; i++)
	if (subexprs[i].nkids == -1) {
	    --nsubexprs;
	    for (j = 0; j <= nsubexprs; j++) {
		if (subexprs[j].parent == &subexprs[nsubexprs])
		    subexprs[j].parent = &subexprs[i];
		}
	    subexprs[i] = subexprs[nsubexprs];
	    i--;
	    }
    }

/*
 * check this subexpr to see if it can be evaulated into some register,
 * delete it if it cannot, and check its parent.
 */
static checkeval(subexpr)
    register struct Subexpr *subexpr;
    {
    if (subexpr->nkids != 0)
	return;
    if (!evaluable(subexpr)) {
	subexpr->nkids = -1;
	if (subexpr->parent) {
	    subexpr->parent->nkids--;
	    checkeval(subexpr->parent);
	    }
	}
    }

/* check to see if this subexpression can be evaluated into any register */
#define trace_evaluable 0
static evaluable(subexpr)
    struct Subexpr *subexpr;
    {
    char            bf[MAXRTLINE];
    int             i, n;
    struct State   *p;
    static char 	**resultnames;

    /*	The rt strings for register names in regpatts have %00 variable
     *  names.  This can confuse evaluable if there is another %00 variable
     *  in the expression, because the range constraints on the two %00
     *  can be incompatible.  This first appeared on the MIPS.  So the
     *  first time evaluable is called, it makes a private copy of the
     *  register rt names and replaces the %00 with %26 or some other
     *  large number.
     */
    if (!resultnames) {
	resultnames = (char **)calloc(sizeof(char *), NOREG);
	for (i = 0; i < NOREG; i++) {
	    resultnames[i] = malloc(strlen(regpatts[i].rt) + 1);
	    strcpy(resultnames[i], regpatts[i].rt);
	    for (n = 0; resultnames[i][n]; n++) {
		if (!strncmp(resultnames[i] + n, "%00", VARLN)) {
		    sprintf(bf, VARFMT, MAXGLOBALS + MAXFREENONTERMS - 1);
		    strncpy(resultnames[i] + n, bf, VARLN);
		    break;
		    }
		}
	    }
	}

#if trace_evaluable
    printf("evaluable(%.*s) ", subexpr->len, subexpr->str);
#endif

    for (i = 0; i < NOREG; i++) {
	if (regpatts[i].many) {
	    sprintf(bf, "move(%.*s,%s,%s)",
		subexpr->len, subexpr->str, resultnames[i],
		typof(subexpr->str, subexpr->str + subexpr->len, rttot));

	    for (EACHTRANS(p, bf, parse)) {
		if (p->cost < BOGUS) {
#if trace_evaluable
		    printf("=> 1\n");
#endif
		    return 1;
		    }
		}
	    }
	}
#if trace_evaluable
    printf("=> 0\n");
#endif
    return 0;
    }


/*  Factor rt into one instruction.  This code also calculates the
 *  maximum use count that a subordinate node is allowed to have.
 *  If it has many uses, it is better to let it be evaluated into
 *  a separate register, rather than folding the cost into many
 *  parents.
 *  This code should really insist that *all* subordinate intermediate
 *  nodes have use count == 1, because it is impossible to determine
 *  accurate costs for the subordinate nodes until they have been rewritten
 *  to machine code.  The current set-up is biased in favor of glomming
 *  up common subexpressions into parents, because the subordinate nodes
 *  appear to be very expensive.  This problem is partially fixed by
 *  special-case code (bigkid).  Bigkid works ok for controlling
 *  optimization decisions, but is not adequate when codegen is happening
 *  simultaneously.   In fact, bigkid is kind of hokey even for optimization
 *  decisions, because it only constrains the most expensive kid, but the
 *  alternative would be a large linear expression.
 *  kid1->count * k1 + kid2->count * k2 + ...  <= constant or something,
 *  which was felt to be too complicated.
 */
factor1(newrt, costsofar)
    char           *newrt;
    double          costsofar;
    {
    double          newcost;
    int             maxuses;
    int             i, j, k;
    char            rttmp[MAXRTLINE];

#if 0
    for (i = 0; i <= newlen; i++)
	printf("factor1 bopts[%d].o_reqs %s line %d\n", i, bopts[i].o_reqs, __LINE__);
#endif
    SAFESTRCPY(new[newlen - 1].rtout, newrt);

    newcost = costsofar + try(newrt, newlen - 1, __LINE__);

    if (newcost < BOGUS && newcost < bestopt.ncost) {

#if 0
	/* NEW */
	if (oldlen > 1 && old[bigkid].costin >= BOGUS) {
	    for (j = MAXOPTSIZE - oldlen; j < MAXOPTSIZE - 1; j++) {
		if (old[j].costin >= BOGUS) {
		    if (old[j].insin->count > 1) {
			return;
			}

		    for (k = bopts[newlen].old[j].p_reslb;
			 k < bopts[newlen].old[j].p_resub; k++)
			if (readslvar(bopts[newlen].old[j].p_rt, k))
			    goto dontconstrain2;

		    sprintf(rttmp, VARFMT, setsvar(&bopts[newlen].old[j]));
		    sprintf(endof(rttmp), ".kid->count==1");
		    addreq(bopts[newlen].o_reqs, rttmp, '=', __FILE__, __LINE__);
		    dontconstrain2:;
		    }
		}

	    bestopt = bopts[newlen];
	    bestopt.ncost = newcost;
	    bestopt.olen = oldlen;
	    bestopt.nlen = newlen;

	    for (i = 0; i < newlen; i++) {
		new[i].bestout = new[i].out;
		INSRT(&new[i].bestout) = bestopt.new[i].p_rt;
		}
	    return;
	    }
/* old[i] contains information about the i'th instruction on the input side
 * of the current optimizations being considered. old entries are numbered
 * from MAXOPTSIZE-oldlen to MAXOPTSIZE-1 with old[MAXOPTSIZE-1] being the
 * root input.
 */
	/* NEW */

	else
#endif

	if (newcost < oin.ncost || (newcost == oin.ncost && newlen < oldlen)) {
	    maxuses = ABSURD_USECT;
	    }

	else if (oldlen > 1) {
	    maxuses = floor(old[bigkid].costin / (newcost - oin.ncost));
	    }

	if (oldlen == 1 || old[bigkid].insin->count <= maxuses) {

	    bestopt = bopts[newlen];
	    bestopt.ncost = newcost;
	    bestopt.olen = oldlen;
	    bestopt.nlen = newlen;

	    for (i = 0; i < newlen; i++) {
		new[i].bestout = new[i].out;
		INSRT(&new[i].bestout) = bestopt.new[i].p_rt;
		}

	    /* Assume uses < ABSURD_USECT, which is high enough to make the comparison
	     * almost pointless.
	     */
	    if (maxuses < ABSURD_USECT) {

		/* KLUDGE!!!??? since we don't have a way in the opt */
		/* language to express that we want to constrain the */
		/* count of an instruction which changes one of its */
		/* inputs, we don't put it in here */

		for (i = bestopt.old[bigkid].p_reslb; i < bestopt.old[bigkid].p_resub; i++)
		    if (readslvar(bestopt.old[bigkid].p_rt, i))
			goto dontconstrain;

		sprintf(rttmp, VARFMT, setsvar(&bestopt.old[bigkid]));
		if (maxuses == 1) {
		    sprintf(endof(rttmp), ".kid->count==%d", maxuses);
		    addreq(bestopt.o_reqs, rttmp, '=', __FILE__, __LINE__);
		    }
		else {
		    sprintf(endof(rttmp), ".kid->count<=%d", maxuses);
		    addreq(bestopt.o_reqs, rttmp, '[', __FILE__, __LINE__);
		    }
		dontconstrain:;
		}
	    }
	}
    }

/* Get the type of some subexpression in the rt.  If it's converted, this is
 * the input type of the convert, otherwise type of the	enclosing computation.
 */
static char    *typof(first, end, rt)
    char           *first, *end;	/* delimit the subexpr	 */
    char           *rt;
    {
    char           *obpos, *oepos;	/* must save/restore. 	 */
    int             len, lev = 0;
    char           *p;
    char            tmp[MAXRTLINE];
    static char     result[20];
    len = end - first;

#if 0
    printf("typof(%.*s,%s) ", end - first, first, rt);
#endif
    /* See if s is the subject of "cvt(s,intype,outtype)"	 */
    obpos = bpos;
    oepos = epos;
    for (p = rt; p = fmatch(p, "cvt(" /* ) */ );) {           /* cvt() */
	if (!strncmp(p += 4, first, len) && p[len] == ',') {  /* cvt(s,) */
	    p += len + 1;	/* pt to type */
	    sprintf(result, "%.*s", index(p, ',') - p, p);
	    goto good;
	    }
	}

    /*  See if s is the subject of "call(s,addrtype,argbytes,outtype)" */
    for (p = rt; p = fmatch(p, "call(" /* ) */ );) {           /* cvt() */
	if (!strncmp(p += 5, first, len) && p[len] == ',') {  /* cvt(s,) */
	    p += len + 1;	/* pt to type */
	    sprintf(result, "%.*s", index(p, ',') - p, p);
	    goto good;
	    }
	}

    /* See if s is the subject of "m(s,intype,outtype)"	 */
    for (p = rt; p = fmatch(p, "m(" /* ) */ ); p++) { /* m( )	 */
	if (!strncmp(p + 2, first, len) &&
	       p[len + 2] == ',' && !isalpha(p[-1])) {	/* m(s, */
	    p += len + 3;	/* pt to type */
	    sprintf(result, "%.*s", index(p, ',') - p, p);
	    goto good;
	    }
	}

    /*  If s is "if(something,typecode)", return typecode. */
    if (!strncmp(first, "if(", 3) && end[-1] == ')' && isalpha(end[-2]) && end[-3] == ',') {
	sprintf(result, "%.1s", end - 2);
#if 0
	printf("=> %s\n", result);
#endif
	return result;
	}

    /* Find the boundaries of the computation that s is enclosed in.
     * The type code is in between the last comma and the last rparen
     */
    sprintf(tmp, "%.*s", end - first, first);
    p = fmatch(rt, tmp);
    if (p == 0)
	goto bad;
    for (p = epos;; p++) {
	if (*p == LPAR)
	    lev++;
	else if (*p == RPAR) {
	    lev--;
	    if (lev < 0)
		goto bad;
	    }
	else if (*p == 0) {
    bad:			/* expression not found	 */
	    bpos = obpos;
	    epos = oepos;
#if 0
	    printf("=> NULL\n");
#endif
	    return NULL;
	    }
	else if (*p == ',' && p[2] == RPAR && lev == 0) {
	    sprintf(result, "%.1s", p + 1);
    good:
	    bpos = obpos;
	    epos = oepos;
#if 0
	    printf("=> %s\n", result);
#endif
	    return result;
	    }
	}
    }


/* subexprs and subexprlens contain a list of substrings and lengths from
 * rttot.  subices contains a vector of newlen indeces into subexprs &
 * subexprlens, indicating which subexpressions are to be removed from rttot
 * for this candidate factoring. Fill in bopt from newlen - 1 (the root) down
 * to zero.
 */
evaluate_opt()
    {
    int             i;
    int             k;
    printf("\n\nevaluating the following subexpressions as a factorizing\n");
    printf("subexprs[0] = %.*s\n", subexprs[0].len, subexprs[0].str);
    for (i = 0; i < newlen - 1; i++) {
	k = subices[newlen - 1 - i] + 1;
	printf("subexprs[%d] = %.*s\n", k, subexprs[k].len, subexprs[k].str);
	}
    printf("\n\n");
    }


/* Convert this rt to a pattern and add it to bopt at the indicated position.
 * See if this results in something that is bogus or costs more than the best
 * discovered optimization. Factor makes repeated calls on try to search for better opts.
 */
/* ARGSUSED */
static double try(rt, ix, fromline)
    char           *rt;		/* register transfer	 */
    register int    ix;		/* # of insn slots filled so far */
    int             fromline;
    {
    struct patrec  *patrec;
    int		i;

#if 0
    printf("try(rt='%s',ix=%d,fromline=%d) =>\n", rt, ix, fromline);
#endif

    /* Add next kid instruction to bopt */
    /* SUPPRESS 36 */
    if (!(patrec = cvtpatt(&bopts[ix + 1], rt, NULL, 0))) {
	return BOGUS;
	}
    bopts[ix + 1].new[ix] = *patrec;
    bopts[ix + 1].new[ix].p_rt = string(patrec->p_rt);
    strcpy(bopts[ix + 1].o_reqs, bopts[ix].o_reqs);
#if 0
    for (i = 0; i <= ix + 1; i++)
	printf("try bopts[%d].o_reqs %s line %d\n", i, bopts[i].o_reqs, __LINE__);
#endif

    /* Initialize the next output instruction.	 */
    initins(&new[ix].out, bopts[ix + 1].new[ix].p_rt,
	   ix == newlen - 1 ? old[MAXOPTSIZE - 1].insin->count : 1);

    /* Move variable values from optimization to output instruction */
    setvars(&bopts[ix + 1], &bopts[ix + 1].new[ix], &new[ix].out);

    /* record the cost of the next output instruction	 */
#if 0
    printf("line %d bopts[%d].reqs '%s'\n", __LINE__, ix+1, bopts[ix + 1].o_reqs);
#endif
    new[ix].costout = getcost(&bopts[ix + 1], &new[ix].out.op, ix, __LINE__);
#if 0
    printf("line %d bopts[%d].reqs '%s'\n", __LINE__, ix+1, bopts[ix + 1].o_reqs);
#endif

    INSCOST(&new[ix].out) = new[ix].costout;

    /* Eliminate use of >1 equivalent vars in output	 */
    canopt(ix);

#if ALTERNATING
    simpopt(ix);
#endif

    /* Weight costs slightly by the height of the node.  This causes short
       sequences to be slightly preferred over longer ones, and drives
       sequences toward a canonical form (cheap roots, expensive leaves). */
    new[ix].costout *= (1 + (newlen - 1 - ix) * FUDGE);

#if 0
    printf("cost=%.4f insn=%s\n\n\n",
	new[ix].costout, skelptr[new[ix].out.op]);
#endif

    return new[ix].costout;
    }

static void initins(ins, rt, count)
    char           *rt;
    int             count;
    struct node  *ins;
    {
    bzero(ins, sizeof(*ins));
    INSRT(ins) = rt;
    ins->count = count;
    }

/* Rewrite opt output to use only lower of two	equivalent vars updates the
 * current bopt entry. Also updates the outs vector of instructions.
 */
canopt(ix)
    int             ix;		/* output instruction index	 */
    {
    int             changes = 0;/* flags changes		 */
    char           *s, *t;
    int             to, from;	/* old & new variable #'s	 */
    int             i;
    struct patrec  *patrec;
    int             boptix = ix + 1;	/* index into bopts             */
    char           *rt;
redo:
    for (s = bopts[boptix].o_reqs + REQPREFLEN; *s; s++) {

	/* %01.xyz==%2.xyz */
	if (s[-REQPREFLEN] == ';' && VAREQ(s)) {	/* found var=var */
	    to = VAR(s);
	    from = VAR(s + VARLN + 6);

	    /* move pointers from old vars to new ones */
	    if (OSYM(&bopts[boptix], from)) {
		OSYM(&bopts[boptix], to) = OSYM(&bopts[boptix], from);
		OSYM(&bopts[boptix], from) = NULL;
		}
	    if (OKID(&bopts[boptix], from)) {
		OKID(&bopts[boptix], to) = OKID(&bopts[boptix], from);
		OKID(&bopts[boptix], from) = NULL;
		}
    changeme:
	    for (t = new[ix].rtout; *t; t++) {		/* fix up rt */
		if (ISVAR(t) && VAR(t) == from) {
		    SETVAR(t, to);
		    changes++;
		    s[-1] = ';';	/* make constraint nonremovable */
		    }
		}

	    for (t = new[ix].result; *t; t++) {		/* fix up rt */
		if (ISVAR(t) && VAR(t) == from) {
		    SETVAR(t, to);
		    changes++;
		    s[-1] = ';';	/* make constraint nonremovable */
		    }
		}

	    for (t = s + VARLN + VARLN + 8; *t; t++) {
		/* we have %01.xyz==%03.xyz and it says %02.xyz==%03.xyz,
		   so we make it read %01.xyz==%02.xyz */
		if (t[-REQPREFLEN] == ';' && VAREQ(t) &&
			VAR(t + VARLN + 6) == from) {
		    SETVAR(t + VARLN + 6, VAR(t));
		    SETVAR(t, to);
		    s[-1] = ';';	/* make constraint nonremovable */
		    }
		/* %03.xyz something changed to %01.xyz something */
		if (ISVAR(t) && VAR(t) == from) {
		    SETVAR(t, to);
		    s[-1] = ';';	/* make constraint nonremovable */
		    }
		}
	    }

	/* if we have %i=="xyz" and %j=="xyz" and i<j then change all j's
	   to i's everywhere in this opt. */
	/* %01.str=="xyz"	 */
	else if (s[-REQPREFLEN] == ';' &&
	       VAREQSTR(s) && readslvar(new[ix].rtout, (int) VAR(s))) {
	    for (t = bopts[boptix].o_reqs; *t; t++) {
		if (VAREQSTR(t) && VAR(t) < VAR(s) &&
		       regtype(new[ix].rtout, (int)VAR(s)) ==
		       regtype(new[ix].rtout, (int)VAR(t))) {
		    for (i = VARLN + 7;; i++) {	/* 7 == strlen(".str==%") */
			if (t[i] != s[i + REQPREFLEN])
			    goto nomatch;
			if (t[i] == '"') {
			    from = VAR(s + REQPREFLEN);
			    to = VAR(t);
			    goto changeme;
			    }
			}
		    }
	nomatch:;
		}
	    }
	}

    /* If we changed an output line, repatternize it.   cvtpatt can't
     * fail because we are reducing the number of different vars.
     */
    if (changes) {

	/* SUPPRESS 36 */
	if (!(patrec = cvtpatt(&bopts[boptix], new[ix].rtout, NULL, 0))) {
	    cerror("canopt: can't happen\n");
	    }
	bopts[boptix].new[ix] = *patrec;
	bopts[boptix].new[ix].p_rt = string(patrec->p_rt);

	INSRT(&new[ix].out) = bopts[boptix].new[ix].p_rt;
	setvars(&bopts[boptix], &bopts[boptix].new[ix], &new[ix].out);

	new[ix].costout =
	       getcost(&bopts[boptix], &new[ix].out.op, ix, __LINE__);
	ix--;
	if (ix >= 0)
	    goto redo;
	}
    }

#if ALTERNATING
/*
 * Try repeated simplification of the current instruction on the output side
 * of this optimization.  After each simplification, re-evaluate the cost of
 * the current instruction, and substitute the new simpler version if it's
 * cheaper.  Because the "simplification" rules are bi-directional, give up
 * after a few trials or if we get into a loop.
 */
simpopt(ix)
    register int    ix;
    {
    char            newrtout[MAXRTLINE];
    static char     triedrt[SIMPCYCLES][MAXRTLINE];	/* list of rt's tried	 */
    int             k;		/* # of rt's tried		 */
    int             i;
    struct Optrec   topt;	/* trial opt			 */
    struct node   tout;		/* trial new kid or root	 */
    double          tcost;	/* trial cost 			 */
    struct patrec  *patrec;
    k = 0;

rep:				/* this is here instead of down two
				   instructions, because canopt may have
				   changed stuff on us */

    SAFESTRCPY(newrtout, new[ix].rtout);

    topt = bopts[ix + 1];

    SAFESTRCPY(topt.o_reqs, bopts[ix + 1].o_reqs);

    /* SUPPRESS 36 */
    while (k < SIMPCYCLES && simp(newrtout, &topt)) {
	if (strlen(newrtout) > MAXRTLINE - 1)
	    cerror("file %s line %d: newrtout too long",
		   __FILE__, __LINE__);
	if (strlen(topt.o_reqs) > MAXREQLEN - 1) {
	    printf("topt.reqs = %s\n", topt.o_reqs);
	    cerror("file %s line %d: topt.reqs too long",
		   __FILE__, __LINE__);
	    }
	for (i = 0; i < k; i++) {			/* see if we have */
	    if (!strcmp(newrtout, triedrt[i])) {	/* seen this before */
		return;
		}
	    }

	SAFESTRCPY(triedrt[k], newrtout);

	/* SUPPRESS 36 */
	if (!(patrec = cvtpatt(&topt, newrtout, NULL, 0)))
	    return;

	if (strlen(newrtout) > MAXRTLINE - 1)
	    cerror("file %s line %d: newrtout too long",
		   __FILE__, __LINE__);
	if (strlen(topt.o_reqs) > MAXREQLEN - 1) {
	    printf("topt.reqs = %s\n", topt.o_reqs);
	    cerror("file %s line %d: topt.o_reqs too long",
		   __FILE__, __LINE__);
	    }
	topt.new[ix] = *patrec;
	topt.new[ix].p_rt = string(patrec->p_rt);

	initins(&tout, topt.new[ix].p_rt,
	       ix == newlen - 1 ? old[MAXOPTSIZE - 1].insin->count : 1);
	setvars(&topt, &topt.new[ix], &tout);

	tcost = getcost(&topt, &tout.op, ix, __LINE__);


	/* See if this is better than the current best output */
	if (tcost < new[ix].costout) {
	    /* || tcost == new[ix].costout && strlen(newrtout) <
	       strlen(new[ix].rtout) */
	    bopts[ix + 1] = topt;
	    SAFESTRCPY(new[ix].rtout, newrtout);
	    new[ix].out = tout;
	    new[ix].costout = tcost;

	    /* Eliminate use of >1 equivalent vars in output */
	    canopt(ix);

	    /* bump up the number of simpcycles if we got a simplification
	       farther than we have before */
	    if (k == simpcycles - 1 && simpcycles < SIMPCYCLES) {
		simpcycles++;
		printf("# simpcycles %d\n", simpcycles);
		}
	    goto rep;
	    }
	k++;
	}
    }
#endif


/* Copy pointers to innocent bystanders and update their usecounts. copy
 * variables from opt record into instruction record.
 */

/*
1. Do not change the root's use count, because all references
   to the root are from uninvolved nodes above it.

2. Decrement a node for each time that it is pointed to
   by the root, because the root will be overwritten.

   When any node loses its last use,
   decrement the use count of every node that it points to.
   This step is implemented recursively.

   Initialize use counts of other output nodes to zero,
   because only the root and other new output nodes will point
   to new output nodes.  If they are already-existing cses, leave
   them alone but point to them.

   Overwrite the root, changing it from an input node to an output.

3. Increment a node for each time that it is pointed to
   by the root.  If this is the node's first use, recursively
   increment each node that it points to.
*/

static setvars(Opt, patrec, insout)
    struct patrec  *patrec;
    struct node  *insout;
    struct Optrec  *Opt;
    {
    int             locv, globv;

    if (patrec == NULL) {
	cerror("patrec");
	}
    /* For each local variable (used in this pattern). Set the
       instruction's variable's value  from the global variable that is
       held in the optimization record. */

    /* This could really just loop through the kids and the vars for this
       instruction. */
    for (locv = 0; locv < MAXGLOBALS + MAXFREENONTERMS; locv++) {

	/* used in pattern?    */
	if (NOVAR != (globv = patrec->map[locv])) {
	    if (readslvar(INSRT(insout), locv) &&
		   regtype(INSRT(insout), locv) != NOREG) {
		IKID(insout, locv) = OKID(Opt, globv);
		}
	    else {
		ISYM(insout, locv) = OSYM(Opt, globv);
		}
	    }
	}
    }

/* Get cost of the next output instruction and record it in the next t
 * pattern.  Record any requirements in the optimization record. Stores the
 * assembler language string in the pattern.  Store the assembler language
 * skeleton number at *asmout.
 */
/* ARGSUSED */
static double getcost(Opt, asmout, ix, fromline)
    struct Optrec  *Opt;
    Opcode	    *asmout;
    int             ix;		/* instruction index	 */
    int             fromline;
    {
    unsign16        r;
    struct patrec  *patrec = &Opt->new[ix];
    r = find(Opt, ix);
#if 0
    printf("getcost from %d reqs %s\n", fromline, Opt->o_reqs);
#endif
    if (r == NULL) {
	return BOGUS;
	}
    *asmout = r;

    return patrec->cost;
    }

/* See if this parse's constraints are satisfied by the values of variables
 * contained in this optimization record. We get the pattern just so we can
 * tell which vars are pointers and which strings, and so we can convert
 * local vars in the state to optimization-global variable numbers.
 */
#define trace_concheck 0
static concheck(r, patrec, Opt, ix)
    struct State   *r;		/* Final parse state including all constraints */	
    struct patrec  *patrec;
    struct Optrec  *Opt;
    int             ix;		/* -1 if input rt else newside index */
    {
    char           *t, *s, *endptr;
    long            val;
    int             locv;	/* a local variable		 */
    int             globv, reg;
    unsigned        v;
    int             j;
    char		*p;

#if trace_concheck
    printf("concheck patrec->p_rt '%s' ", patrec->p_rt);
    for (locv = 0; locv < MAXGLOBALS + MAXFREENONTERMS; locv++) {
	if (t = r->constraints[locv]) {
	    printf("%%%d=%s ", locv, t);
	    }
	}
    printf("\n");
#endif
    /*	Check out each variable in the parsed rt */

    for (locv = 0; locv < MAXGLOBALS + MAXFREENONTERMS; locv++) {

	/* Did the parse supply a constraint for this variable? */
	/* SUPPRESS 57 */
	if (t = r->constraints[locv]) {

	    /*  Yes */ 
	    if ((globv = patrec->map[locv]) == NOVAR) {
		/* check to see if we are generating possible new parses */
		if (ix != -1 && patrec != &Opt->new[ix]) {
		    cerror("locv %d has no equivalent global variable!\n", locv);
		    }
		else {
		    continue;
		    }
		}

	    /*  Is the constrained variable a register variable? */
	    reg = regtype(patrec->p_rt, locv);

	    /* will this be %01.str==%02.str ??? */
	    /* Compare %01==%02 for strings & numerics */

	    /*  Is the constraint of the form %xx==%yy? */
	    if (ISVAR(t) && ((v = VAR(t)) < MAXGLOBALS + MAXFREENONTERMS) &&
		t[VARLN] == 0) {

		/*  Yes, if it's not 2 registers, then compare symbol table pointers. */ 
		if (reg == NOREG) {
		    /* SUPPRESS 29 */
		    if (OSYM(Opt, globv) != OSYM(Opt, patrec->map[v])) {
#if trace_concheck
			printf("concheck returns 0 line %d\n", __LINE__);
#endif
			return 0;
			}
		    }


		/* Register == register constraints are of 2 types: Bindings of 2
		 * input registers, and bindings of an input register to an output.
		 * The latter occurs for every 2-address instruction.  This code
		 * checks the former.
		 */

		/* If both registers are inputs, compare 2 kid pointers. */
		if (patrec->p_kidlb <= v && v < patrec->p_kidub &&
		     patrec->p_kidlb <= locv && locv < patrec->p_kidub) {	
		    if (OKID(Opt, globv) == NULL || OKID(Opt, patrec->map[v]) == NULL ||
			   OKID(Opt, globv) != OKID(Opt, patrec->map[v])) {
#if trace_concheck
			printf("concheck returns 0 line %d reslb %d locv %d v %d resub %d\n",
				__LINE__, patrec->p_reslb, locv, v, patrec->p_resub);
#endif
			return 0;
			}
		    }

		else if (ix != -1) {
		    int             globeq;
		    globeq = patrec->map[v];
		    if (globeq == NOVAR)
			cerror("%s %d: should not happen\n",
			    __FILE__, __LINE__);
		    if (Opt->o_refct[globeq] > 0) {
#if 0
			printf("ins sets %%%d which is in use\n", globeq);
#endif
			return 0;
			}
		    globeq = patrec->map[locv];
		    if (globeq == NOVAR)
			cerror("%s %d: should not happen\n",
			    __FILE__, __LINE__);
		    if (Opt->o_refct[globeq] > 0) {
#if 0
			printf("ins sets %%%d which is in use\n", globeq);
#endif
			return 0;
			}
		    }
		}

	    /* Check %01 in a range for regs and nonregs.  Regs are
	       ignored because not allocated yet */
	    else if ((s = rindex(t, '-')) && s != t) {
#if trace_concheck
		printf("check %%%d in range %s\n", locv, t);
#endif
		if (reg == NOREG) {
#if USE_NUMBERS
		    if (Opt->o_numbers & (1 << globv)) {
			/* SUPPRESS 57 */
			val = ONUM(Opt, globv);
			}
		    else
#endif
			if (OSYM(Opt, globv) == NULL) {
#if trace_concheck
			printf("concheck returns 0 line %d\n", __LINE__);
#endif
			return 0;
			}
		    else {
			/* Ensure that the variable is really numeric */
			val = strtol(OSTR(Opt, globv), &p, 10);
			if (*p) {
#if trace_concheck
			    printf("concheck returns 0 line %d\n", __LINE__);
#endif
			    return 0;
			    }
			}
		    if (val < atoi(t) || atoi(s + 1) < val) {
#if trace_concheck
			printf("concheck returns 0 line %d\n", __LINE__);
#endif
			return 0;
			}
		    }
		}

	    /* Check %01 == constant, for nonregs		 */
	    else if (reg == NOREG) {
#if USE_NUMBERS
		if (Opt->o_numbers & (1 << globv)) {
		    val = strtol(t, &endptr, 10);
		    /* SUPPRESS 57 */
		    if (*endptr || val != ONUM(Opt, globv)) {
#if trace_concheck
			printf("concheck returns 0 line %d\n", __LINE__);
#endif
			return 0;
			}
		    }
		else
#endif
		    if (string(t) != OSTR(Opt, globv)) {
#if trace_concheck
			printf("concheck returns 0 line %d\n", __LINE__);
#endif
		    return 0;
		    }
		}
	    }
	}

#if trace_concheck
    printf("concheck returns 1 line %d\n", __LINE__);
#endif
    return 1;
    }


/* find - see if line is a legal instruction; return cheapest instruction, or NULL
 * if illegal.  If two instructions have the same costs, return the more general
 * one (fewer constraints). If neither is more general, return the instruction with
 * the shortest string.
 */
#define trace_find 0
static unsign16 find(Opt, ix)
    struct Optrec  *Opt;
    int             ix;
    {
    int             locv;
    struct State   *result = NULL, *p;
    char            bestreqs[MAXREQLEN], newreqs[MAXREQLEN];
    struct patrec  *patrec = &Opt->new[ix];
    unsign32        v;
    unsign16        r;
    static struct Sig newsig;
    int             i, k, numbers, lnumbers;

#if trace_find
    printf("find rt %s Opt->o_reqs '%s'\n", patrec->p_rt, Opt->o_reqs);
#endif
    bestreqs[0] = 0;
    for (EACHTRANS(p, patrec->p_rt, parse)) {

#if trace_find
	printf("\nfind: test translation '%s' cost %.2f\n", p->trans, (double)p->cost);
	for (locv = 0; locv < MAXGLOBALS + MAXFREENONTERMS; locv++) {
	    if (p->constraints[locv]) {
		printf(VARFMT, locv);
		printf("=%s ", p->constraints[locv]);
		}
	    }
	printf("\n\n");
#endif
	newreqs[0] = 0;

	if ((!result || p->cost <= result->cost) && concheck(p, patrec, Opt, ix)) {
	    for (locv = 0; locv < nelts(p->constraints); locv++) {
		if (p->constraints[locv] && patrec->map[locv] != NOVAR) {
		    addcon(locv, newreqs, patrec, p->constraints[locv],
			   __FILE__, __LINE__,
			   (Opt->o_numbers & (1 << patrec->map[locv])));
		    }
		}

	    /* New.  Ensure that all of the rt's inputs can be */
	    /* allocated to some register.                     */
	    for (locv = patrec->p_kidlb; locv < patrec->p_kidub; locv++) {
		v = bittrans(newreqs, locv, patrec);
		if (v == 0) {
#if trace_find
		    printf("/* find: No reg allocable for %%%02d in %s: not usable */\n",
				locv, p->trans);
		    printf("/* patrec '%s' newreqs '%s' */\n", patrec->p_rt, newreqs);
#endif
		    goto nextrans;
		    }
		}

	    if (result == NULL || p->cost < result->cost ||
		   p->cost == result->cost &&
		   (implies(bestreqs, newreqs) && !implies(newreqs, bestreqs) ||
			  strlen(p->trans) < strlen(result->trans))) {
		result = p;
#if trace_find
		printf("/* got a better trans '%s' */\n", p->trans);
		printf("/* bestreqs := newreqs '%s' */\n", newreqs);
#endif
		SAFESTRCPY(bestreqs, newreqs);
		}
    nextrans:;

	    }
	}

    /* Add the constraints to the optimization record and the patrec */
    if (result) {

	if (*bestreqs) {
#if trace_find
	    printf("/* find: call addred */\n", p->trans);
	    printf("/* `%s' + `%s' */\n", Opt->o_reqs, bestreqs);
#endif
	    addreq(Opt->o_reqs, bestreqs, 0, __FILE__, __LINE__);
	    }

	numbers = Opt->o_numbers;

	/* Canonicalize the numbers bit vector */
	lnumbers = 0;
	for (i = 0; i < MAXGLOBALS + MAXFREENONTERMS; i++) {
	    if (patrec->map[i] != NOVAR && numbers & (1 << patrec->map[i])) {
		lnumbers |= 1 << i;
		}
	    }

	/* get the varct and geneity of the rt */
	/* store it in the signature table */
	newsig.kidlbd = patrec->p_kidlb;
	newsig.kidubd = patrec->p_kidub;
	newsig.regtype = getresultype(patrec->p_rt);
	newsig.varlbd = patrec->p_varlb;
	newsig.varubd = patrec->p_varub;
	newsig.reslbd = patrec->p_reslb;
	newsig.resubd = patrec->p_resub;
	newsig.numbers = lnumbers;
	newsig.simplers = regmove(patrec->p_rt) ? -1 : 0;
	newsig.allocl = result->allocl;
	newsig.type = gettypename(patrec->p_rt);
#if 0
	printf("call bittrans ins '%s'\n", result->trans);
#endif
	for (k = 0; k < nelts(newsig.vec); k++) {
	    newsig.vec[k] = bittrans(Opt->o_reqs, k, patrec);
	    }

	patrec->cost = result->cost;
	/* install it   */
	patrec->signumber = signo(r = skinstall(string(result->trans), newsig));
	patrec->assem = skelptr[r];	/* and string		 */
#if trace_find
	printf("allocl %d\n", newsig.allocl);
#endif

	}
    else
	r = 0;
#if trace_find
    printf("return skelptr[%d] '%s'\n", r, skelptr[r]);
#endif
    return r;
    }


/* This checks quickly to see if the substring from( [first,end) ]might be a
 * good subexpression of a rt.  It makes sure that the substring has balanced
 * parens, no commas outside the outermost parens, and that the substring is
 * not equal to the rt's destination string.
 */

static goodsubexpr(first, end, dst)
    register char  *first, *end;	/* delimit the substring	 */
    char           *dst;		/* rt's destination field	 */
    {
    int             lev = 0;	/* count parens			 */
    if (end - first == strlen(dst) && !strncmp(first, dst, end - first))
	return 0;

    for (; first < end; first++) {
	if (*first == LPAR)
	    lev++;
	else if (*first == ',' && lev == 0)
	    return 0;
	else if (*first == RPAR) {
	    lev--;
	    if (lev < 0)
		return 0;
	    }
	}
    return !lev;
    }


changevar(string, oldglob, newglob)	/* change %old to %new	 */
    char           *string;		/* in place		 */
    int             oldglob, newglob;
    {
    char           *s;
    for (s = string; *s; s++)
	if (ISVAR(s) && VAR(s) == oldglob)
	    SETVAR(s, newglob);
    }

/* Get a new variable number which will sequentially number unique vars in
 * the input  register transfers. Parents are renumbered before their kids.
 * If the old var number is a kid number for some kid of the current node,
 * change old to the common var.
 */
#define trace_newvar 0
static int newvar(oldvar, ix, map)	/* old var # and rt number	 */
    int             oldvar;		/* old variable number		 */
    int             ix;			/* instruction index		 */
    char            map[MAXOPTSIZE][MAXGLOBALS + MAXFREENONTERMS];
    {
    int             result, globv;
    int		    lb, ub;		/* lb & ub for this ins's results */

    lb = reslb(old[ix].insin);
    ub = resub(old[ix].insin);

#if trace_newvar
    printf("newvar(%d,%d) results %d-%d parent %d ",
	oldvar, ix, lb, ub - 1, old[ix].parno);
#endif

    /* this var already determined?	 */
    for (globv = 0; globv < MAXGLOBALS + MAXFREENONTERMS; globv++)
	if (map[ix][globv] == oldvar) {
	    result = globv;
#if trace_newvar
	    printf("already determined %%%d\n", result);
#endif
	    goto done;
	    }

    /* if a kid's result, find parent's kid number in map */
    if (ix != MAXOPTSIZE - 1 && lb <= oldvar && oldvar < ub) {
	for (globv = 0; globv < MAXGLOBALS + MAXFREENONTERMS; globv++) {
	    if (map[old[ix].parno][globv] == old[ix].kidno) {
		result = globv;
#if trace_newvar
		printf("result %%%d is kid[%d] of parent\n", result, old[ix].kidno);
#endif
		goto done;
		}
	    }
	}

    if (maxvar > MAXGLOBALS + MAXFREENONTERMS - 2)
	return NOVAR;

    result = ++maxvar;		/* just get a new var		 */

done:
    map[ix][result] = oldvar;	/* install in map		 */
    return result;
    }

/* replace - replace "dst" by "src" in lin, except for move(x,dst).
 * typ gives the type  of the src.  If that is not the type of the dst in lin,
 * use "cvt(src,typ,dsttype)" instead of just src
 */
#define trace_replace 0
static replace(lin, dst, src, typ)
    char           *lin, *dst, *src, *typ;
    {
    char            result[MAXRTLINE], tmp[MAXRTLINE], dsttype[20],
                   *t;
    char            lindst[MAXRTLINE], linsrc[MAXRTLINE], lintyp[20],
                   *b, *e, *s;
    int             nouts = 0;
    int             dstlen = strlen(dst);
    int             srclen = strlen(src);
    int             sddiff = srclen > dstlen ? srclen - dstlen : 0;
    int             spaceleft = MAXRTLINE - strlen(lin);
    int		    changes = 0;


#if trace_replace
    printf("replace '%s' by '%s' in '%s'\n", dst, src, lin);
#endif
    result[0] = 0;

    /* Since we are replacing strings by strings, hopefully we would always */
    /* be making the string shorter */
    /* Unfortunately, sometimes we make it longer. */
    if (gtds(lin, lindst, linsrc, lintyp)) {

	for (b = lin; e = gtds(b, lindst, linsrc, lintyp);) {

	    for (s = linsrc; fmatch(s, dst);) {
		/* look for dst		 */
		dsttype[0] = 0;

		if (t = typof(bpos, epos, lin))
		    SAFESTRCPY(dsttype, t);
		if (t && isalpha(dsttype[0]) && strcmp(dsttype, typ)) {
		    sprintf(tmp, "cvt(%s,%s,%s)", src, typ, dsttype);
		    if ((spaceleft -= (sddiff + 8)) < 0)
			cerror("%s %d: out of rt space", __FILE__, __LINE__);
		    s = sub(linsrc, tmp);
		    changes = 1;
		    }
		else {
		    if ((spaceleft -= sddiff) < 0)
			cerror("%s %d: out of rt space", __FILE__, __LINE__);
		    s = sub(linsrc, src);	/* replace it with src	 */
		    changes = 1;
		    }
		}

	    /* don't do move(x,dst)	 */
	    if (strcmp(lindst, dst)) {
		for (s = lindst; fmatch(s, dst);) {
		    dsttype[0] = 0;
		    if (t = typof(bpos, epos, lin))
			SAFESTRCPY(dsttype, t);
		    if (t && isalpha(dsttype[0]) && strcmp(dsttype, typ)) {
			sprintf(tmp, "cvt(%s,%s,%s)", src, typ, dsttype);
			if ((spaceleft -= (sddiff + 8)) < 0)
			    cerror("%s %d: out of rt space", __FILE__, __LINE__);
			s = sub(lindst, tmp);
			changes = 1;
			}
		    else {
			if ((spaceleft -= sddiff) < 0)
			    cerror("%s %d: out of rt space", __FILE__, __LINE__);
			s = sub(lindst, src);
			changes = 1;
			}
		    }
		}
	    b = e;
	    if (nouts++)
		SAFESTRCAT(result, ",");
	    sprintf(endof(result), "move(%s,%s,%s)", linsrc, lindst, lintyp);
	    }

	if (nouts > 1) {
	    if ((spaceleft -= 5) < 0)
		cerror("%s %d: out of rt space", __FILE__, __LINE__);
	    cerror("replace: parallel effects!");
	    }

	strcpy(lin, (nouts > 1) ? "par(" : "");
	strcat(lin, result);
	strcat(lin, (nouts > 1) ? ")" : "");
	}
    else {
	for (s = lin; fmatch(s, dst);)	{
	    /* look for dst		 */
	    if ((spaceleft -= sddiff) < 0)
		cerror("%s %d: out of rt space", __FILE__, __LINE__);
	    s = sub(lin, src);	/* change to src	 */
	    changes = 1;
	    }
	}
#if trace_replace
    printf("replace => '%s'\n", lin);
#endif
    return changes;
    }

/* Edit the code dag to reflect the optimization held in bestopt	 */
static performopt()
    {
    int             globv, lresult, ix, j, k, locv;
    struct node  *newkid;
    int             dsttype;
    int             tmpcount;
    char            dst[MAXRTLINE], src[MAXRTLINE], type[20];


    /* Make sure we never use these fields, they are test versions.	 */
    /* We should only use stuff from bestopt to perform the "best opt"	 */
    /* Although we can use stuff from the input side of old		 */
    for (j = 0; j < MAXOPTSIZE; j++) {
	new[j].rtout[0] = 0;
	}

    if (bestopt.nlen == 99)
	return 0;		/* nothing is better	 */

#if 0
    dagdump(old[MAXOPTSIZE-1].insin, 0, 0, -1);
#endif

    rewct[1][bestopt.olen][bestopt.nlen]++;	/* accumulate stats	 */

    recordopt(&bestopt);

    /* Uncount instruction records pointed to by old root. */
    decrementuse(old[MAXOPTSIZE - 1].insin);

    /* Set variables & bump usecounts in the innocent bystanders. Works
       from leaves to the root. */
    for (ix = 0; ix < newlen; ix++) {
	setvars(&bestopt, &bestopt.new[ix], &new[ix].bestout);
	INSRT(&new[ix].bestout) = string(INSRT(&new[ix].bestout));
	INSCOST(&new[ix].bestout) = bestopt.new[ix].cost;
#if 0
	printf("/* performopt: INSCOST(%s) = %f */\n",
		INSRT(&new[ix].bestout),
		INSCOST(&new[ix].bestout));
#endif
	sigptr[new[ix].bestout.op] = bestopt.new[ix].signumber;
	}


    /* Allocate new instructions for the output side.  Make parents point
       to their children, by finding the instruction that reads each kid's
       result. */
    for (ix = 0; ix < newlen - 1; ix++) {

	if (nextins > inslist + (INSSIZE - 100))
	    cerror("out of instruction recs");

	newkid = nextins++;	/* get new instruction	 */
	*newkid = new[ix].bestout;	/* fill it in		 */
	newkid->count = 0;	/* fix cse and x->2, x->3... bug */

	new[ix].insout = newkid;/* wait til now, in case of cse */
	lresult = setslvar(INSRT(newkid));	/* kid's result variable */

	globv = bestopt.new[ix].map[lresult];	/* kid's global result	 */

	/* find kid's parent(s)	 */
	for (j = ix + 1; j < newlen; j++) {
	    for (locv = 0; locv < MAXGLOBALS + MAXFREENONTERMS; locv++) {
		if (bestopt.new[j].map[locv] == globv) {

		    IKID(&new[j].bestout,locv) = newkid;
		    if (locv == 0)		/* I think this is bogus */
			goto gnext;
		    }
		}
	    }
gnext:	;
	}

    /* change the old root to the new root.  This is what actually edits
       the program dag. */

    tmpcount = old[MAXOPTSIZE - 1].insin->count;
    /* make sure we start out at zero count for the root!!! */
    new[newlen - 1].bestout.count = 0;
    new[newlen - 1].bestout.link = old[MAXOPTSIZE - 1].insin->link;
    *old[MAXOPTSIZE - 1].insin = new[newlen - 1].bestout;
    new[newlen - 1].insout = old[MAXOPTSIZE - 1].insin;

    /* increment the uses of the kids of the new instructions */
    /* notice that we will trash the count of the root when we copy */
    /* the count of the old root */

#if DEBUG
    printf("perform %d->%d opt:\n", oldlen, newlen);
    /* SUPPRESS 36 */
    writeopt(&bestopt, stdout, 0);
#endif
    incrementuse(new[newlen - 1].insout);
    new[newlen - 1].insout->count += tmpcount - 1;
#if DEBUG
    printf("after opt:\n");
    dagdump(globr, 0, old[MAXOPTSIZE-1].insin, -1);
    printf("\n\n");
#endif

    if (oldlen == maxoldlen && newlen == 1 && maxoldlen < MAXOPTSIZE)
	maxoldlen++;

    return 1;			/* something changed	 */
    }

/* The root gained another use, if this is the first use of it, increment
 * the use counts of all its kids.
 */
static void incrementuse(ins)
    register struct node	*ins;
    {
    register struct node **kid;
    register struct node **kidl;

    if (ins) {
#if 0
	printf("incrementuse: kidlb(%d) = %d kidub=%d\n",
	    ins, kidlb(ins), kidub(ins));
#endif
	kid = &IKID(ins, 0) + kidlb(ins);
	kidl = &IKID(ins, 0) + kidub(ins);
	if (ins->count++ == 0) {
	    for (;kid < kidl; kid++)
		incrementuse(*kid);
	    }
	}
    }

/*  We decremented the use count of this node to zero.  Decrement the
 *  counts of its kids.
 */
decrementuse(ins)
    register struct node	*ins;
    {
    register struct node	**kid = &IKID(ins, 0) + kidlb(ins);
    register struct node	**kidl = &IKID(ins, 0) + kidub(ins);

    for (;kid < kidl; kid++)
	if (*kid && --(*kid)->count == 0)
	    decrementuse(*kid);
    }

static void recordopt(Opt)	/* record an optimization rule	 */
    struct Optrec  *Opt;	/* to the optpats file		 */
    {
    static FILE    *patout;
    struct patrec  *pat;
    register int    oregs = 0, onums = Opt->o_numbers;
    register int    i, k, l;
    if (patout == NULL) {
	patout = fopen("optpats", "a");
	if (patout == NULL)
	    cerror("can't open pattern file\n");
	}
    fprintf(patout, "# line %d\n", lineno);

    /*  Mark variable numbers used on input and output sides */
    for (i = MAXOPTSIZE - 1; i >= MAXOPTSIZE - oldlen; i--) {
	pat = &Opt->old[i];
	for (k = pat->p_reslb; k < pat->p_resub; k++)
	    oregs |= 1 << pat->map[k];
	for (k = pat->p_kidlb; k < pat->p_kidub; k++)
	    oregs |= 1 << pat->map[k];
	}
    for (i = 0; i < newlen; i++) {
	pat = &Opt->new[i];
	for (k = pat->p_reslb; k < pat->p_kidub; k++)
	    oregs |= 1 << pat->map[k];
	for (k = pat->p_kidlb; k < pat->p_kidub; k++)
	    oregs |= 1 << pat->map[k];
	}
    if (oregs & onums) {
	cerror("bad count oregs %x onums %x\n", oregs, onums);
	}
    fprintf(patout, "\"");
    while (oregs | onums) {
	fprintf(patout, (oregs & 1) ? "K" : (onums & 1) ? "N" : "S");
	oregs >>= 1;
	onums >>= 1;
	}
    fprintf(patout, "\"\n");

    /* SUPPRESS 36 */
    writeopt(Opt, patout, 0);
    }


/* Get cost of an input and record it in its pattern.  Record any
 * requirements in the optimization record.  Return the cheapest instruction.
 * If two instructions have the same costs, return the more general one
 * (fewer constraints). If neither is more general, return the instruction
 * with the shortest string.
 *
 * This is used for intermediate codes, because those instructions do not come
 * into the system with costs and rt equivalents.
 */
static getrt(Opt, ix)
    struct Optrec  *Opt;
    int             ix;		/* instruction index	 */
    {
    struct patrec  *patrec = &Opt->old[ix];
    int             locv;
    struct State   *result = NULL, *p;
    char            bestreqs[MAXRTLINE], newreqs[MAXRTLINE];

    /* SUPPRESS 57 */
    inittrans();
    for (p = parse(skelptr[old[ix].insin->op], 0); p; p = p->next) {
	if (!result && concheck(p, patrec, Opt, -1)) {
	    goto newresult;
	    }
	else if (!result || p->cost < result->cost) {
	    if (concheck(p, patrec, Opt, -1)) {
	newresult:
		result = p;
		bestreqs[0] = 0;
		for (locv = 0; locv < MAXGLOBALS + MAXFREENONTERMS; locv++) {
		    if (result->constraints[locv]) {
			addcon(locv, bestreqs, patrec,
			       result->constraints[locv], __FILE__, __LINE__,
			       Opt->o_numbers & (1 << patrec->map[locv]));
			}
		    }
		}
	    }
	else if (p->cost == result->cost && concheck(p, patrec, Opt, -1)) {
	    newreqs[0] = 0;
	    for (locv = 0; locv < MAXGLOBALS + MAXFREENONTERMS; locv++)
		if (p->constraints[locv])
		    if (regtype(patrec->p_rt, locv) == NOREG ||
			   ISVAR(p->constraints[locv])) {
			addcon(locv, newreqs, patrec, p->constraints[locv],
			       __FILE__, __LINE__,
			       Opt->o_numbers & (1 << patrec->map[locv]));
			}
	    locv = implies(bestreqs, newreqs) - implies(newreqs, bestreqs);
	    if (locv > 0 ||
		   (locv == 0 && strlen(p->trans) < strlen(result->trans))) {
		SAFESTRCPY(bestreqs, newreqs);
		result = p;
		}
	    }
	}

    /* Add the constraints to the optimization record */
    if (result) {
	if (*bestreqs)
	    addreq(Opt->o_reqs, bestreqs, 0, __FILE__, __LINE__);
	}
    if (result) {
	patrec->cost = result->cost;
	return 1;
	}
    else {
	patrec->cost = BOGUS;
	return 0;
	}
    }

/*  Use the intermediate code to fill in the register transfer for
 *  this instruction.  Not sure how this differs from getrt.
 */
static int fillinrt(ip)
    struct node *ip;
    {
    struct State *sp;

    if (!ip)
	return 0;

    if (INSRT(ip))
	return (int)INSRT(ip);

    /*	INSCOST(ip) = BOGUS;	DELETE */

    if (!skelptr[ip->op])
	return 0;

    if (!(sp = canonparse(skelptr[ip->op], 0)))
	return 0;

    INSRT(ip) = string(sp->trans);
    INSCOST(ip) = sp->cost;

    if (INSCOST(ip) < BOGUS && !doing_onesies) {
	fprintf(stderr, "Misplaced rt for assembly %s\n", skelptr[ip->op]);
	exit(-1);
	}

#if 0
    print("fillinrt(%s) => rt %s cost %d\n",
	skelptr[ip->op], INSRT(ip), INSCOST(ip));
#endif
    return (int)INSRT(ip); /* just non-zero */
    }

/*  Infer all possible 1->n code generation rules so that the optimizer
 *  will never fail to optimize an intermediate code, which would cause
 *  intermediate code to appear in the compiler's output instruction stream.
 *
 *  This works by creating minimal dags for each different intermediate code
 *  and calling the regular optimizer on each such.
 *
 *  The number and string fields receive values which are carefully chosen to be
 *  "typical" so that we do not infer special-case rules but instead we infer
 *  the general case.  We admit that the ice is thin here.
 *
 *  In particular, max stack offset on the NS32K is a range between
 *  -1073741824 and 1073741823, hence the number below.
 */
onesies()
    {
    struct node	*r;
    int		i, kidno, sign, onskels = nskels;

    doing_onesies = 1;
    maxoldlen = 1;

    for (i = 1; i < onskels; i++) {

	getins(r, i);
	if (!fillinrt(r))
	    goto next_onesy;

	sign = signo(i);

	for (kidno = sigs[sign].kidlbd; kidno < sigs[sign].kidubd; kidno++) {
	    IKID(r, kidno) = 0;
	    }

	for (; kidno < sigs[sign].varubd; kidno++) {
	    if ((1 << kidno) & (sigs[sign].numbers))
		INUM(r, kidno) = 1073741822;
	    else
		ISYM(r, kidno) = mkstr("bullwinkle j. moose");
	    }
#if 1
	printf("comb sees:\n");
	globr = r;
	tdump(0, r);
#endif
	for (newlen = 1; newlen < MAXOPTSIZE; newlen++) {
	    opt(r);
	    if (r->op != i)
		goto next_onesy;
	    }

	fprintf(stderr,"chop0: Couldn't generate code for %s\n", skelptr[r->op]);
next_onesy:;
	}

    doing_onesies = 0;
    }
