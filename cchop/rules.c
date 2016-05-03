/* Copyright (c) 1991 Alan Wendt.  All rights reserved.
 * You have this code because you wanted it now rather than correct.
 * Bugs abound!  Contact Alan Wendt for a later version or to be
 * placed on the chop mailing list.  Parts are missing due to licensing
 * constraints.
 *
 * Alan Wendt / Computer Science / Colorado State Univ. / Ft Collins CO 80523
 * 303-491-7323.  wendt@cs.colostate.edu
 */

/* rules.c -- read optimization rule files */


#define LEARNING 1	/* This module only used in learning system */
#include <ctype.h>
#include <stdio.h>
#include <string.h>
#include "c.h"
#include "hop2.h"
#include "md.h"

static	compop();		/* compare opts for qsort		*/
static	concheck();	/* opt's constraints imply instruction's?	*/
static  char *debackslashn();
static	double find2();		/* find best translation for an rt	*/
static	dumpskels();		/* dump skeleton string table		*/
static	dumpswitch();		/* dump codegen or opt switch + cases	*/
static	emitif();		/* emit rule's if part			*/
static	emitthen();		/* emit rule's then part		*/
static	ilate();		/* look for a var's value in the input	*/
static	initsw();		/* sort rules & init switch		*/
static	inment();		/* count mentions of v on input side	*/
static	install_opt();		/* add this opt to the list of opts	*/
static	kidix(), dumpsigs(), genopt();
static	enum opcode lastop();	/* find last output opcode # in this opt */
static	olate();		/* look for value on output side	*/
static	char *onam();		/* name of cell holding n'th output ins	*/
static	prep_run();		/* prepare one side of a rule		*/
static	redundant();		/* see if a rule is redundant		*/
static	reqlate();		/* translate a requirement		*/
static	setopcodes();		/* set assem fields if needed		*/
static	vlate();		/* translate a variable into C code	*/

/*	The different ways that we can get the value of a var		*/
#define		GETREG		1	/* allocate new reg		*/
#define		GOUTPUT		2	/* prior output reg		*/
#define		GINPUT		3	/* input reg			*/
#define		GFIXED		4	/* determined by reqs		*/

#define STRSIZE 16384

int		kidno;			/* the kid to be switched on	*/

static unsign32 defined[STRSIZE / 32];
static unsign32 optable[STRSIZE / 32];	/* does this op appear on input	*/
					/* side of a rule?		*/

#define bittest(array, bit) (array[bit >> 5] & (1 << (bit & 31)))
#define bitset(array, bit) (array[bit >> 5] |= (1 << (bit & 31)))
#define bitreset(array, bit) (array[bit >> 5] &= ~(1 << (bit & 31)))

#define nil(x) ( (x) ? (x) : "Null" )

#define MAXOPTS 2048
static struct Optrec *Optlist[MAXOPTS];
static int nopts = 0;			/* # of opts in Optlist */

extern char *parfname;			/* template file name		*/
static char commentbf[MAXREQLEN];
char	abbrkid[MAXREQLEN];		/* current kid available in b	*/

extern int flat_rule_flag;
	    
static int	isareg[MAXGLOBALS+MAXFREENONTERMS];/* is %i a register number*/
static int	delta[MAXGLOBALS+MAXFREENONTERMS];/* change to reg usect*/
static int	ifemitted = 0;		/* last opt was conditional	*/

static plineno = 1;

#define TOOLONG \
	cerror("file %s line %d: string too long optpats line %d\n", \
		__FILE__, __LINE__, lineno)

/*  generate a test, emit "if (" if this is the first */
#define gentest() (ifemitted++ ? "\n\t    && " : "\tif (")

int count_asm_on_inputs;

/*  Main routine, called by cchop.  Reads the "yaccpar" file (called
 *  parf) and mostly copies it.  Watches for $x for various x
 */
dumpopts() {
    FILE		*parf;
    int			c, d;
    if (lernflg) printf("#define LEARNING 1\n");
    if (cseflg) printf("#define CSE 1\n");

    if (!(parf = fopen(parfname, "r")))
	cerror("can't open %s", parfname);

    for (;;) {
	c = getc(parf);
	if (c < 0) break;
	if (c == '\n') plineno++;
	if (c != '$') putchar(c);		/* copy the parfile	*/
	else {
	    d = getc(parf);
	    switch (d) {
		case 'V': dumpskels(); break;
		case 'G': dumpsigs(); break;
		case 'O': initsw(); dumpswitch(0, nopts); break;
		case 'P': dump_ptbl(); break;
		default: putchar(c); putchar(d);
		}
	    }
	}
    }

/* readopts - read optimizations into hash table */
readopts(fp)
    FILE *fp;
    {
    struct Optrec	*o;
    long		optno = 0;

    lineno = 0;

    while (!feof(fp)) {
	if (optno % 100 == 0)
		fprintf(stderr, "%d\r", optno);

        if (!(o = readopt(fp)))
	    break;
        o->o_optno = optno++;
        install_opt(o);
        }

    printf("/* %d/%d of opts have some assembly language on input side */\n",
	count_asm_on_inputs, nopts);
    }


/*  Add this opt to the list of all the opts.  */
static install_opt(o)		/* add this opt to the list of opts	*/
    struct Optrec *o;
    {
    int			i;

    bzero((char *)isareg, sizeof(isareg));
    prep_run(o, o->old, o->olen, (double *)NULL); /* do old side */
    prep_run(o, o->new, o->nlen, (double *)NULL); /* do new side */
    genopt(o);				/* try to generalize	*/

    for (i = 0; i < o->olen; i++) {
	if (o->old[i].cost < BOGUS) {
	    count_asm_on_inputs++;
	    break;
	    }
	}

    nopts++;
    if (nopts > nelts(Optlist)) {
	cerror("install_opt: too many optimizations\n");
	}

    Optlist[nopts - 1] = o;		/* stick on opt list		*/

    /*  output costs should never be bogus */
    if (o->ncost  >= BOGUS || o->nlen == 0) {
	writeopt(o, stdout, 1);
	fprintf(stderr, "cost %f nlen %d\n",
		(double)o->ncost, o->nlen);
	cerror("output side has bogus cost or zero length!\n");
	}
    }


/*  This just sets kidno in each pattern, adds up the output cost	*/
/*  of the rule, bitches if the output is not legal assembler.		*/
/*  Looks up each instruction and adds to o->implied all constraints	*/
/*  that are implied due to the input instructions.			*/
#define trace_prep_run 0
static prep_run(o, q, npatts, costvec)
    struct Optrec	*o;
    struct patrec	*q;		/* either o->old or o->new	*/
    char		npatts;
    double		*costvec;	/* return costs here		*/
    {
    double		cost;
    int			locv, v, k, j;
    char		*s;

    if (q == o->new)
	o->ncost = 0;			/* initialize new cost	*/
    else if(q == o->old)
	o->o_ocost = 0;			/* initialize old cost	*/
    else
	cerror("bad q input in prep_run");

    q[npatts - 1].parent = npatts;

    for (k = npatts - 1; k >= 0; k--) {	/* from root down to kids	*/

	/*  find the parent pattern number of pattern[k]		*/
	/*  and find out which kid of the parent pattern[k] is		*/

	if (k != npatts - 1) {
	    v = setsvar(&q[k]);
	    for (j = k + 1; j < npatts; j++) {
		for (locv = 0; locv < MAXGLOBALS+MAXFREENONTERMS; locv++) {
		    if (q[j].map[locv] == v) {
			q[k].kidno = locv;
			q[k].parent = j;

			/*  We use this test vs (locv==0) for when we have
			 *  to do multiple results
			 */
			if (setsvar(&q[j]) == v)
			    goto gotpar;
			}
		    }
		}
	    }
	gotpar:

	cost = find2(o, &q[k], q);
	if (costvec) costvec[k] = cost;

#if 0
	printf("rt '%s' assem '%s' cost %.2f\n", q[k].p_rt, q[k].assem, (double)cost);
#endif
	if (q == o->new) {
	    o->ncost += cost;
	    }
	else
	    o->o_ocost += cost;
	}

    for (k = npatts - 1; k >= 0; k--)	/* from root down to kids	*/
	for (s = q[k].p_rt; *s; s++)
	    if (NOVAR != (locv = regvarb(s)))
		isareg[q[k].map[locv]]++;
    }

/*  find - see if line is a legal instruction				*/
/*  return cost or BOGUS if illegal					*/
/*  There are two versions of this; the other version is in comb.c	*/
#define trace_find2 0
static double find2(Opt, patrec, side)
    struct Optrec	*Opt;
    struct patrec	*patrec, *side;
    {
    register int 	locv;
    double		cost = BOGUS;
    struct State	*p;		/* translation			*/
    struct State	*result = NULL;	/* best translation		*/
    char		bestreqs[MAXREQLEN], newreqs[MAXREQLEN];
    char		*t, *impl[MAXGLOBALS+MAXFREENONTERMS];
    char  *noimpls = "noimpls";
    unsign32		v;
    static struct Sig     newsig;
    int numbers,lnumbers;
    int i,k;


    *bestreqs = 0;
#if trace_find2
    printf("find2 patrec rt '%s' assem '%s' numbers %o\n",
	patrec->p_rt, patrec->assem, Opt->o_numbers);
#endif
    for (EACHTRANS(p, patrec->p_rt, parse)) {

#if trace_find2
      printf("got translation '%s' cost %.2f does%s match\n",
	    p->trans, (double)p->cost,
	    strcmp(p->trans, patrec->assem) ? "n't":"");
#endif
	/* This is strcmp because now EACHTRANS returns a canonical parse */
	if (!strcmp(p->trans, patrec->assem) &&
	    (result == NULL || p->cost <= result->cost) &&
	    concheck(Opt, p, patrec, side)) {
#if trace_find2
	    printf("got past concheck\n");
#endif
	    *newreqs = 0;
	    for (locv = 0; locv < nelts(p->constraints); locv++) {

		/*  assume that constraints on register #'s are satisfied */
		/*  by the alligator registration.			*/
		/* if this is assume that they are satisfied by the
		allocator, why add them here??? change != to == */
		if ((t = p->constraints[locv]) 
#define PRINTCONSTRAINT 0
#if PRINTCONSTRAINT
		   ){ printf("constraint on %d->%d = %s\n",
			locv, patrec->map[locv], t);
			if ( 1 
#endif
			/* if we are generating a new assem */
			/* ignore any constraints on it,    */
			/* because it is an assem and shouldn't */
			/* matter!!!??? (I hope) */
			&& patrec->map[locv] != -1
			) {
		    addcon(locv, newreqs, patrec, t, __FILE__, __LINE__, 
			   (Opt->o_numbers & ( 1 << patrec->map[locv])));
		    }
#if PRINTCONSTRAINT
		}
#endif
		}

	    /*	New.  Ensure that all of the rt's inputs can be	*/
	    /*	allocated to some register.			*/
	    for (locv = patrec->p_kidlb; locv < patrec->p_kidub; locv++) {
		v = bittrans(newreqs, locv, patrec);
		if (v == 0) {
		    printf("/* %s not usable */\n", p->trans);
		    goto nextrans;
		    }
		}

	    if (result == NULL || p->cost < result->cost ||
		p->cost == result->cost &&
		(implies(bestreqs, newreqs) && !implies(newreqs, bestreqs) ||
		strlen(p->trans) < strlen(result->trans))) {
		result = p;
		SAFESTRCPY(bestreqs, newreqs);
		}
	    }
	nextrans:;
	}

    if (result) {
      if (side == Opt->new) {

	numbers = Opt->o_numbers;
        /*  Canonicalize the numbers bit vector */
        lnumbers = 0;
        for (i = 0; i < MAXGLOBALS+MAXFREENONTERMS; i++) {
            if (patrec->map[i] != NOVAR && (numbers & (1 << patrec->map[i]))) {
                lnumbers |= 1 << i;
#if trace_find2
                printf("/* line %d: %%%d is numeric in %s lnumbers %o*/\n",
                    __LINE__, i, patrec->p_rt, lnumbers);
#endif
                }
            }


        /* get the varct and geneity of the rt */
        /* store it in the signature table */
	newsig.varlbd = patrec->p_varlb;
        newsig.varubd = patrec->p_varub;
        newsig.kidlbd = patrec->p_kidlb;
        newsig.kidubd = patrec->p_kidub;
	newsig.reslbd = patrec->p_reslb;
	newsig.resubd = patrec->p_resub;
	newsig.allocl = result->allocl;
        newsig.regtype = getresultype(patrec->p_rt);
        newsig.numbers = lnumbers;
        newsig.simplers = regmove(patrec->p_rt) ? -1 : 0;
	newsig.type = gettypename(patrec->p_rt);
        for (k = 0; k < nelts(newsig.vec); k++) {
            newsig.vec[k] = bittrans(Opt->o_reqs, k, patrec);
	    }

	k = addsig(patrec->assem, newsig);

        if (patrec->signumber != k) {
	    fprintf(stderr,"find2 patrec rt '%s'\nassem '%s'\nreqs '%s'\n",
	    patrec->p_rt, patrec->assem,bestreqs);
	    fprintf(stderr,"find2 came up with the wrong sig!\n");
	    fprintf(stderr,"the 'correct' sig\n");
	    writesig(stderr,patrec->signumber);
	    fprintf(stderr,"\nwhat find2 came up with\n");
	    writesig(stderr,k);
	    cerror("\nfind2 came up with the wrong sig!\n");
	    }
        }
	cost = result->cost;

	/*  Add to implied all constraints common to all translations	*/
	/*  of this assembler string.  Since we know that we are	*/
	/*  looking at this assembler string, such common constraints	*/
	/*  are implied.						*/
	/*  For example, if one translation implies a,b and c and the	*/
	/*  other implies b, c, and d, we know that b and c have to be	*/
	/*  both true if we are looking at the instruction.		*/
	if (side == Opt->old) {
	    for (locv = 0; locv < MAXGLOBALS+MAXFREENONTERMS; locv++)
		impl[locv] = noimpls;
	    for (EACHTRANS(p, patrec->p_rt, parse)) {
		if (!strcmp(p->trans, patrec->assem)) {
		    for (locv = 0; locv < MAXGLOBALS+MAXFREENONTERMS; locv++) {
			if (t = p->constraints[locv]) {
			    if (impl[locv] == noimpls) impl[locv] = t;
			    else if (impl[locv] && strcmp(impl[locv], t))
				 impl[locv] = 0;
			    }
#if trace_find2
			if (impl[locv] != noimpls || t)
			    printf("impl[%d] %s t %s\n", locv, nil(impl[locv]), nil(t));
#endif
			}
		    }
		}

	    for (locv = 0; locv < MAXGLOBALS+MAXFREENONTERMS; locv++) {
		if (impl[locv] && impl[locv] != noimpls) {
		    if (!addcon(locv, Opt->implied, patrec, impl[locv],
			__FILE__, __LINE__,
			Opt->o_numbers & (1 << patrec->map[locv]))) {
			/* actually it can!!! (if MAXREQLEN is too small) */
			printf("/* can't happen %d %s\n", locv, impl[locv]);
			writeopt(Opt, stdout, 1);
			printf("   result->trans %s\n", result->trans);
			printf("   patrec %s\n", patrec->assem);
			cerror("   implied %s */\n", Opt->implied);
			}
		    }
		}
	    }
	}

#if trace_find2
    printf("find2 returns %g reqs %s implied %s\n", cost,bestreqs,Opt->implied);
#endif
    return patrec->cost = cost;
    }


/*  See if the constraints on this opt imply the constraints on this
 *  instruction, by checking if opt's + ins's == opt's.
 */
/*  If we get an unsatisfied range or value constraint on a register	*/
/*  number,  add the constraint to the instruction's "allocation	*/
/*  signature", which is used by the register allocator, but assume	*/
/*  that the constraint will be satisfied by the register allocator. 	*/
/* ??? where does it add the constraint to the allocation signature???  */
#define trace_concheck 0
static concheck(Opt, p, patrec, side)
    register struct patrec	*patrec;    /* current pattern	*/
    register struct patrec	*side;	    /* first pattern on same side */
    register struct State	*p;	    /* instruction recognizer */
    struct Optrec		*Opt;	    /* the opt record	*/
    {
    struct Optrec		*newo;
    register char		*t;
    char			reqs[MAXREQLEN];
    int				olen;
    int				locv;		/* a local variable */

#if trace_concheck
    printf("concheck Opt->o_reqs '%s'\n", Opt->o_reqs);
    for (locv = 0; locv < MAXGLOBALS+MAXFREENONTERMS; locv++)
	if (t = p->constraints[locv])
	    printf("%%%d=%s\n", locv, p->constraints[locv]);
    printf("\n");
#endif

    olen = strlen(Opt->o_reqs);			/* old constraint list len */

    for (locv = 0; locv < MAXGLOBALS+MAXFREENONTERMS; locv++) {
	if (t = p->constraints[locv]) {		/* is this var constrained? */
	    SAFESTRCPY(reqs, Opt->o_reqs);		/* yes */

	    /*	add constraint t to reqs.  Return 0 if inconsistent */
	    if (!addcon(locv, reqs, patrec, t, __FILE__, __LINE__,
		Opt->o_numbers & (1 << patrec->map[locv])))
		    return 0;

	    if (strlen(reqs) != olen) {		/* got an addition?	*/

		/*  is the new constraint %i==%j? */
		if (ISVAR(t)) {
#if trace_concheck
		    printf("concheck returns 0 from line %d\n", __LINE__);
#endif
		    return 0;
		    }

		/*  assume other constraints on registers are satisfied */
		/*  by the alligator.				*/
		else if (regtype(patrec->p_rt, locv) != NOREG) continue;

#if trace_concheck
		printf("concheck returns 0 at line %d because\n", __LINE__);
		printf("olen %d strlen(reqs) %d\n", olen, strlen(reqs));
		printf("strlen(%s) !=\nstrlen(%s)\n",
			reqs, Opt->o_reqs);
#endif
		return 0;
		}
	    }
	}
#if trace_concheck
    printf("concheck returns 1\n");
#endif
    return 1;
    }


/*  sort the rules and emit some defines that tell how big they are	*/
/*  Also set bits for every root instruction that has a case arm	*/
/*  And install all the roots in the hash table all together so that	*/
/*  the cases will be dense and in order.				*/
static initsw()
    {
    int			i,j, k, optno, olen, l, h;
    struct patrec	*p;
    int numbers,lnumbers;

    init_ptbl();		/* set parities for i codes	*/

    /*  sort the optimizations by the character string that makes up    */
    /*  the root instruction of the tree                                */
    qsort(Optlist, nopts, sizeof(Optlist[0]), &compop);

    /*	Set bits to remember which labels are defined		*/
    for (optno = 0; optno < nopts; optno++) {
	olen = Optlist[optno]->olen;		/* old length		*/
	p = Optlist[optno]->old + olen - 1;	/* last (root) pattern	*/
	j = skinstall(p->assem, sigs[p->signumber]);
	bitset(defined, j);
	bitset(optable, j);
	}

    /*	set bits indicating the instructions that appear */
    /*	on the input side of at least one rule.          */
    for (optno = 0; optno < nopts; optno++) {
	/* this goes to olen - 1 because we already set the bit for the */
	/* roots in the first loop!!! */
	for (j = 0; j < Optlist[optno]->olen; j++) {
	    p = Optlist[optno]->old + j;	/*  pattern	*/
	    k = skinstall(p->assem, sigs[p->signumber]);
	    bitset(optable, k);
	    }
	}
    }


/*  dump the codegen or opt switch		*/
static dumpswitch(lb, ub)
    {
    int			dups = 0;
    int			specials = 0;
    struct Optrec	*Opt;
    struct patrec	*p;
    struct patrec	*currpat;
    static struct Sig	newsig;
    int			optno, j, ix, nextroot;
    int			locv;
    int numbers,lnumbers;
    char		*s;


    while (lb < ub) {

	/*  find limit of this group of opts on this root		*/
	Opt = Optlist[lb];
	for (nextroot = lb;
	    nextroot < ub && lastop(Optlist[nextroot]) == lastop(Opt); nextroot++)
	    continue;

	/*  next group is from lb to nextroot - 1			*/
	/*  emit case label and debugging code				*/
	currpat = Opt->old + Opt->olen - 1;
	j = skinstall(currpat->assem, sigs[currpat->signumber]);

	/* need to set up signature (skinstall) */
	if (!j) {
	    cerror("dumpswitch: unable to find sig for %s\n", currpat->assem);
	    }

	if (!flat_rule_flag)
	    printf("\n\tcase %d:\tL%d:\t/* %s */\n", j, j, currpat->assem);
	*abbrkid = 0;

	printf("\tTDUMP(%d)\n", j);
#if 0
	printf("#if DEBUG\n\ttdump(%d, r);\n#endif DEBUG\n", j);
#endif

	/*  emit the opts in the current group of opts		*/
	for (optno = lb; optno < nextroot; optno++) {

	    Opt = Optlist[optno];
	    currpat = Opt->old + Opt->olen - 1;

	    /* do it up here so we know what redundant ones we 	*/
	    /* have eliminated.					*/
	    /*  emit the optimization being considered as a comment */
	    printf("/*\n");
	    if (Opt->o_file[0]) {
		printf("# file %s line %d\n", Opt->o_file, Opt->o_lineno);
		}
	    writeopt(Opt, stdout, 1);
	    printf(" */\n");

	    /*	skip if this one is redundant given the next.		*/
	    /*	Ie more conditions and the same result or more		*/
	    /*	conditions and >= cost.					*/
	    if (optno < nextroot - 1 &&
		/* 1 == 2 or 1 implies 2, but 2 does not imply 1 */
		redundant(Optlist[optno], Optlist[optno + 1])) {
		specials++;
		printf("/*  This opt was redundant(1) in rules.c */\n");
		goto skipopt;
		}
	    /*	skip if this one is redundant given the last one.	*/
	    /*	Ie more conditions and the same result or more		*/
	    /*	conditions and >= cost.					*/
	    if (optno > lb &&
		/* 1 != 2 and 2 does not imply 1 */
		redundant(Optlist[optno], Optlist[optno - 1]) > 1) {
		specials++;
		printf("/*  This opt was redundant(2) in rules.c */\n");
		goto skipopt;
		}

	    /*  install an abbreviation for root's kid			*/
	    if (Opt->olen > 1 && !flat_rule_flag) {
		if (strcmp(inam(Opt,(int) Opt->olen - 2), abbrkid)) {
		    SAFESTRCPY(abbrkid, inam(Opt,(int) Opt->olen - 2));
		    printf("\tb = %s;\n", abbrkid);
		    }
		stashxfer("b", abbrkid, 1, "suppress", 3);
		}

	    bzero((char *) isareg, sizeof(isareg));

	    /*	set up sig, isareg	*/
	    for (ix = 0; ix < Opt->olen + Opt->nlen; ix++) {
		p = (ix < Opt->olen) ?
			&Opt->old[ix] : &Opt->new[ix - Opt->olen];

		j = skinstall(p->assem,sigs[p->signumber]);


		for (s = p->p_rt; *s; s++)
		    if (NOVAR != (locv = regvarb(s)))
			isareg[p->map[locv]]++;
		}

	    emitif(Opt);  			/* if (match) {		*/
	    emitthen(Opt);			/* then do it }		*/
	    skipopt:;
	    }

	if (ifemitted) {
#if 0
	    /*  This assignment is necessary only if cchop generates branches
	     *  to case label L45 without assigning the root opcode 45 first.
	     */
	    /*  If we are ending a case arm that had an if, assign opcodes */
	    if (!flat_rule_flag)
		setopcodes(currpat, "r");
	    doxfers();
#endif

	    if (!flat_rule_flag)
		printf(lernflg ? "\tgoto defalt;\n" : "\treturn;\n");
	    }

	lb = nextroot;
        }


    printf("/* %d/%d duplicate opts eliminated */\n", dups, ub);
    printf("/* %d    special cases of others */\n", specials);
    }

/*  last input opcode in this opt */
static enum opcode lastop(Opt)
    struct Optrec *Opt;
    {
    struct patrec *p = rootin(Opt);
    return skinstall(p->assem, sigs[p->signumber]);
    }

/*  check if opt1 is useless given opt2.  The case if a) the		*/
/*  assembler inputs and outputs are the same, and b) the conditions on	*/
/*  opt2 are implied by those of opt1.					*/
/*  returns TRUE(1) if opt1 is redundant, else FALSE(0)			*/
static redundant(opt1, opt2)
    struct Optrec	*opt1, *opt2;
    {
    int			i;

    /*	printf("redundant '%s' '%s' ", opt1->reqs, opt2->reqs);	*/
    if (opt1 == opt2 || compop(&opt1, &opt2) == 0) {
	/*	printf("=> yes\n");	*/
	return 1;
	}

    /*	Check to see if these two optimizations have the same input	*/
    /*	side.  This may be an error, because if they do not have the    */
    /*  same assembly language output side, they are not the same opt.	*/
    if (opt1->olen == opt2->olen && !strcmp(opt1->o_reqs, opt2->o_reqs)) {
	for (i = 0; i < opt1->olen; i++) {
	    if (strcmp(opt1->old[i].assem, opt2->old[i].assem)) goto ok;
	    if (bcmp(opt1->old[i].map, opt2->old[i].map, MAXGLOBALS+MAXFREENONTERMS)) goto ok;
	    }

	/* they have the same input side.  See if they have the same  */
	/* assem output side.  RT's may vary. */
	for (i = 0; i < opt1->nlen; i++) {
	    if (strcmp(opt1->new[i].assem, opt2->new[i].assem)) goto bad;
	    if (bcmp(opt1->new[i].map, opt2->new[i].map,
		     MAXGLOBALS+MAXFREENONTERMS)) goto bad;
	    }
	/* if the assem is the same and the reqs are the same(checked above) */
	/* then we consider the instructions the same */
	goto ok;


    bad:
	printf(
	"/* error: two opts with the same inputs and different outputs! */\n");
	printf("/*");
	if (opt1->o_file[0]) {
	    printf("# file %s line %d\n", opt1->o_file, opt1->o_lineno);
	    }
	writeopt(opt1, stdout, 1);
	printf(" */\n");
	/* let one be used, but not the other.  These may be */
	/* adds with the parameter's switched!!!??? */
	return 1;
	}

    ok:

    if (opt1->olen != opt2->olen || opt1->nlen != opt2->nlen) goto fail;
    /* why was this taken out??? */
    /*	if (opt1->ncost < opt2->ncost) {	*/
	/* redundant code in redundant()!!! */
	for (i = 0; i < opt1->nlen; i++) {
	    if (strcmp(opt1->new[i].assem, opt2->new[i].assem)) goto fail;
	    if (bcmp(opt1->new[i].map, opt2->new[i].map, MAXGLOBALS+MAXFREENONTERMS)) goto fail;
	    }
	for (i = 0; i < opt1->olen; i++) {
	    if (strcmp(opt1->old[i].assem, opt2->old[i].assem)) goto fail;
	    if (bcmp(opt1->old[i].map, opt2->old[i].map, MAXGLOBALS+MAXFREENONTERMS)) goto fail;
	    }
    /*	}	*/
    if (strlen(opt2->o_reqs) == 0)
	if (strlen(opt1->o_reqs) != 0)
		return 2;	/* 1 implies 2, but 2 does not imply 1 */
	else 
		return 1;	/* 1 == 2 */
    if (implies(opt1->o_reqs, opt2->o_reqs)) {
	/*	printf("=> yes\n");	*/
	/* check to see if they imply each other(equivalant) */
	if (!implies(opt2->o_reqs, opt1->o_reqs))
	{
		return 2;	/* 1 implies 2, but 2 does not imply 1 */
	} else
		return 1; 	/* 1 == 2 */
	}
    fail:
    /*	printf("=> no\n");	*/
    return 0;		/* 1 != 2 and 1 does not imply 2 */
    }

/*  Compare two optimizations for sorting. */
/*  if opt1 comes before opt2 return < 0   */
/*  if equal return 0 */
/*  if opt1 comes after opt2 return > 0   */

static int compop(opt1, opt2)
    struct Optrec	**opt1, **opt2;
    {
    char		*s1, *s2;
    struct patrec	*p1, *p2;
    int			ct1, ct2;	/* # of input rules in each */
    int			result;

    p1 = rootin(*opt1);
    p2 = rootin(*opt2);

    s1 = p1->assem;
    s2 = p2->assem;

    /*	Different spellings of root input opcode */
    if (result = strcmp(s1, s2))
	return result;

    /*	Different root input opcodes with same spelling (different sigs) */
    if (result = lastop(*opt1) - lastop(*opt2))
	return result;

    ct1 = (*opt1)->nlen;		/*  increasing output length	*/
    ct2 = (*opt2)->nlen;

    if (ct1 < ct2 && (*opt1)->ncost <= (*opt2)->ncost) return -1;
    if (ct1 > ct2 && (*opt1)->ncost >= (*opt2)->ncost) return 1;

    ct1 = (*opt1)->olen;		/* input lengths */
    ct2 = (*opt2)->olen;

    for (;;) {			         /* from last instruction to 1st */
        /* the root has the highest parent # */
        /* children of the root, the second highest, etc. */
        result = (ct1 - p1->parent) -
		 (ct2 - p2->parent);    /* closest to the root goes first*/

	if (result) return result;	/* i.e. broad before deep	*/

        result = p1->kidno - p2->kidno;	/* same parent, check kid #'s */
        if (result) return result;	/* lowest kid # first */


        p1--; p2--; ct1--; ct2--;

	if (ct1 <= 0 || ct2 <= 0) {	/* are we falling off the edge?	*/
	    if (ct1 != ct2) {
#if DECREASING
		return ct2 - ct1;	/* sort in decreasing input length */
#else
		return ct1 - ct2;	/* sort in increasing input length */
#endif
		}
	    break;
	    }
        }

    /*  Attempt to sort equal opts together.  This reduces the # of
     *  "statement not reached" complaints on the 68k from 15 to 1.
     */
    p1 = rootin(*opt1);
    p2 = rootin(*opt2);
    for (ct1 = 0; ct1 < (*opt1)->olen; ct1++, p1--, p2--)
	if (result = strcmp(p1->assem, p2->assem))
	    return result;

    /*	Put the more specific ones first.  If opt1 is more specific,	*/
    /*	its constraints will imply those of opt2 but not vice-versa.	*/
    if (result = (				/* if opt1 more spec	*/
	implies((*opt2)->o_reqs, (*opt1)->o_reqs) /* this will == 0	*/
	-
	implies((*opt1)->o_reqs, (*opt2)->o_reqs) /* this will == 1	*/
	)) return result;			/* result < 0		*/

    /*  sort by increasing cost of output side		*/
    if (result = (*opt1)->ncost - (*opt2)->ncost) return result;

    return 0;
    }

/*  emit the test to see if this optimization is applicable     */
static emitif(Opt)
    struct Optrec	*Opt;
    {
    char	transbf[MAXREQLEN];	/* hold req being translated	*/
    char	reqbf[MAXREQLEN];		/* holds the rest of the reqs	*/
    char	tmp[MAXREQLEN], t2[MAXREQLEN];
    char	*nextq, *q, *limq;
    char	implicit[MAXGLOBALS+MAXFREENONTERMS];	/* checked implicitly?	*/
    int		lastix, laglocv, globv, locv, ix;

    ifemitted = 0;

    bzero(implicit, sizeof(implicit));

    /*  check the instruction patterns	*/
    for (ix = Opt->olen - (flat_rule_flag ? 1 : 2); ix >= 0; ix--)
	printf("%sINSOP(%s) ==%d\t/* %s */",
	    gentest(), shorten(inam(Opt, ix)), skinstall(Opt->old[ix].assem,
	     sigs[Opt->old[ix].signumber]),Opt->old[ix].assem);

    /*	For each req, if an ==, remove it and see if we can still	*/
    /*  get the value, if so we generate a test				*/
    /*  Check reqs which are available from the input			*/
    limq = Opt->o_reqs + strlen(Opt->o_reqs);

    for (q = Opt->o_reqs; *q; q = nextq) {

	/*	Get the next req into transbf				*/
	/*	Get the remaining reqs into reqbf			*/
	nextq = nextreq(q);
	strncpy(reqbf, Opt->o_reqs, q - Opt->o_reqs);
	strncpy(reqbf + (q - Opt->o_reqs), nextq, limq - nextq);
	reqbf[q - Opt->o_reqs + limq - nextq] = 0;
	if (nextq-q-1+1 > sizeof(transbf)) {
		TOOLONG;
		}
	sprintf(transbf, "%.*s", nextq - q - REQPREFLEN, q + REQPREFLEN);

#if 0
	printf("\nemitif: reqlating %s reqbf %s\n", transbf,reqbf);
#endif
	if (!reqlate(Opt, reqbf, transbf, tmp)) {
#if 0
		printf("\nemitif: couldn't reqlate!\n");
#endif
		goto dont;
		}

	if (fmatch(Opt->implied, transbf)) {
#if 0
	    printf("\n\t    /* %s implied */", shorten(tmp));
#endif
	    goto dont;
	    }

	printf("%s%s", gentest(), shorten(tmp));

	/*  if this is IKID(r,xyz)->count==1	*/
	if (fmatch(tmp, "->count==1") && !isdigit(*epos)) {
	    *rindex(tmp, '-') = 0;
	    knownuse(tmp, 1, 0);
	    }

	/*  if this is IKID(r,xyz)->count<=1	*/
	else if (fmatch(tmp, "->count<=1") && !isdigit(*epos)) {
	    *rindex(tmp, '-') = 0;
	    knownuse(tmp, 1, 0);
	    }

	dont:;
	}

    /*  Most of the kid pointers are checked implicitly by virtue of	*/
    /*	the tree structure.  However if a var is mentioned in different	*/
    /*  instructions and not checked implicitly, it must be checked	*/
    /*  explicitly.							*/
    /*	set the bits for vars which are checked implictly		*/
    /*  lint incorrectly says that laglocv may be used before set.	*/
    /*  ??? Made it start out at -1 to satisfy lint ??? */
    for (ix = Opt->olen - 2; ix >= 0; ix--)
	implicit[Opt->old[Opt->old[ix].parent].map[Opt->old[ix].kidno]] = 1;

    for (globv = 0; globv < MAXGLOBALS+MAXFREENONTERMS; globv++) {
	sprintf(tmp, VARFMT, globv);
	SAFESTRCAT(tmp, ".str");
	if (inment(Opt, globv) > 1 && !implicit[globv] &&
	    !bound(Opt->o_reqs, tmp, t2)) {
	    lastix = Opt->olen;
	    for (ix = lastix - 1; ix >= 0; ix--) {
		for (locv = 0,laglocv = -1; locv < MAXGLOBALS+MAXFREENONTERMS; locv++) {
		    if (Opt->old[ix].map[locv] == globv) {
			if (lastix != Opt->olen) {

			    sprintf(reqbf, "%s%s(%d,%d)",
				gentest(),
				isareg[globv] ? "IKID" : "IVAR",
				shorten(inam(Opt, lastix)),
				laglocv
				);

			    printf("%s== ", reqbf);
			    sprintf(reqbf, "%s(%d,%d)",
				isareg[globv] ? "IKID" : "IVAR",
				shorten(inam(Opt, ix)),
				locv);

			    printf("%s", reqbf);
			    }
			lastix = ix;
			laglocv = locv;
			}
		    }
		}
	    }
	}

    if (ifemitted) printf(")\n\t%c\n", LCURLY);
    }

/*  We have loaded "b" with a pointer to the first kid of the root	*/
char *shorten(name)
    char	*name;
    {
    static char result[MAXREQLEN];

    if (flat_rule_flag)
	return name;

#if 0
    printf("shorten(%s) abbrkid '%s'\n", name, abbrkid);
#endif
    result[0] = '\0'; /* !isalpha() in case the match is at the beginning*/
    /* + 1 because we index -1 with bpos which may be the start of the string */
    if (strlen(name) > sizeof(result) -2)
	cerror("file %s line %d: string '%s' too long\n",
		__FILE__,__LINE__,name);

    strcpy(result+1,name);
    if (fmatch(result+1, abbrkid) && !isalpha(bpos[-1]))
	sub(result+1, "b");
#if 0
    printf("=>'%s'\n", result + 1);
#endif
    return result+1;
    }

/*  Translate a requirement from current optimization.  String-constant
 *  comparisons use ISTR(ISYM(%xx)).  String-String comparisons generate
 *  ISYM comparisons.
 *  %xx.str="14"  =>  ISTR(ISYM(%xx))==nums[14]
 *  %xx.str="253" =>  ISTR(ISYM(%xx))==stringd(253)
 *  %xx.str="abc" =>  !strcmp(ISTR(ISYM(%xx)),"abc")
 *  %xx           =>  IKID(IKID(IKID(r,3),4),5)
 *
 *  Variables (%xx) are translated into C text (macro calls) that accesses
 *  the variable's value.  
 *  Variables are currently symbols or kids, so %xx.num is translated using
 *  an atoi call.
 */
static reqlate(Opt, reqs, s, d)
    struct Optrec	*Opt;
    char		*reqs;		/* known requirements.		*/
    char		*s;		/* source requirement		*/
    char		*d;		/* translated req dest buffer	*/
    {
    int			len;
    char		bf[MAXREQLEN], v[VARLN+5], src[MAXREQLEN];
    char		*p, *q, *t, *beg, bf2[MAXREQLEN];
    long		value;

#if 0
    printf("\nreqlate '%s' wrt '%s'\n", s, reqs);
#endif

    *d = 0;

    while (*s) {

	p = s;

	if (isvar(&p, v) && scan(&p, "==\"") && !strncmp(v + VARLN, ".str", 4)) {
	    if (!vlate(Opt, reqs, 0, v, bf, 1)) {
		printf("reqlate: cannot translate %s\n", v);
		return 0;
		}
	    value = strtol(p, &t, 10);
	    if (t != p && *t == '\"') {
		if (0 <= value && value <= 127) {
		    sprintf(endof(d), "%s==nums[%d]", bf, value);
		    p = t + 1;
		    }
		else {
		    sprintf(endof(d), "%s==stringd(%d)", bf, value);
		    p = t + 1;
		    }
		}
	    else {
		if (t = index(p, '\"')) {
		    sprintf(endof(d), "!strcmp(%s, %.*s)", bf, t - p + 2, p - 1);
		    p = t + 1;
		    }
		}
	    s = p;
	    }

	else if (scan(&p, "atoi(") &&		/* atoi(%01.str) */
	    isvar(&p, v) &&
	    (q = bound(reqs, v, bf)) &&		/* with %01 bound	*/
	    scan(&p, ".str)")) {

	    if (strlen(d) > MAXREQLEN - 10)
		TOOLONG;

	    if (*q == '"')  {			/* to q quoted string	*/
		sprintf(endof(d), "%d", atoi(q + 1));	/* -> constant	*/
		}

	    else if (scan(&q, "stringd(")) {	/* to atoi(stringd(xyz)) */
		len = 1;			/* (count nesting depth) */
		beg = q;
		for (;;) {
		    if (*q == 0) break;		/* -> xyz		*/
		    if (*q == '(') len++;
		    if (*q == ')') len--;
		    if (len == 0) break;
		    q++;
		    }

		if (len == 0) {

		    if (q - beg > sizeof(bf2))
			TOOLONG;

		    sprintf(bf2, "%.*s", q - beg, beg);	/* recursively	*/
		    if (!reqlate(Opt, reqs, bf2, endof(d))) {
#if 0
			printf("reqlate fails line %d\n", __LINE__);
#endif
			return 0;
			}
		    }
		}

	    else if (!reqlate(Opt, reqs, q, endof(d))) {
#if 0
		printf("reqlate fails line %d\n", __LINE__);
#endif
		return 0;
		}
	    s = p;
	    }

	/*  turn %01.kid into r->var[2].kid or whatever	*/
	else if (isvar(&s, v)) {
	    if (isareg[VAR(v)] && strncmp(&v[VARLN], ".kid", 4)) {
#if 0
		printf("reqlate fails v %s line %d\n", v, __LINE__);
#endif
		return 0;
		}

	    else if (t = bound(reqs, v, bf)) {
	    	if (!reqlate(Opt, reqs, t, endof(d))) {
#if 0
		    printf("reqlate fails line %d\n", __LINE__);
#endif
		    return 0;
		    }
		}
	    else {
		if (!vlate(Opt, reqs, 0, v, src, 0)) {
#if 0
		    printf("reqlate fails line %d\n", __LINE__);
#endif
		    return 0;
		    }

		if (strlen(d) + strlen(src) + 1 > MAXREQLEN)
		    TOOLONG;
			
		strcat(d, src);
		}
	    }

	else {
	    len = strlen(d);
	    d[len] = *s++;
	    d[len+1] = 0;
	    }
	}

    /*  Adjust for the fact that r doesn't have a pointer subfield;	*/
    /*  it is a pointer.						*/
    while (fmatch(d, "r.kid")) sub(d, "r");

#if 0
    printf("reqlate returns %s\n", d);
#endif

    return 1;
    }

#define TRACE_VLATE 0

/*  Translate %n.str or %n.kid into a text string.			*/
static vlate(Opt, reqs, emit, var, src, constant_comparison)
    int			emit;		/* output count	0 = input only	*/
    char		*var;		/* input %x.kid or %x.str	*/
    char		*src;		/* return value string here	*/
    char		*reqs;
    struct Optrec	*Opt;
    int			constant_comparison;	/* if we want a .str value */
    {						/* to compare with a constant */
    int			globv = VAR(var);
    struct patrec	*newpat;
    char		tmp[MAXREQLEN];

#if TRACE_VLATE
    printf("\nvlate var %s emit %d reqs %s\n\n", var, emit, reqs);
#endif

    if (emit > 0)			/* working on output?	*/
	newpat = &Opt->new[emit - 1];

    *src = 0;

    /*  Can we give it a value from a result computed already           */
    /*  This precedes allocation so that we can re-use allocated        */
    /*  regs in multi-line output sides.                                */
    if (olate(Opt, reqs, var, emit, src)) {
#if TRACE_VLATE
	printf("vlate => GOUTPUT '%s' line %d\n", src, __LINE__);
#endif
	return GOUTPUT;
	}

    /*	Can we get value from one of the inputs?	*/
    if (ilate(Opt, reqs, var, src, constant_comparison)) {
#if TRACE_VLATE
	printf("vlate => GINPUT '%s' line %d\n", src, __LINE__);
#endif
	return GINPUT;
	}

    /*  allocable register? We have a value for .str but not .kid	*/
    if (emit > 0 && globv == setsvar(newpat)) {
	int	result = GETREG;

#if TRACE_VLATE
	printf("/* Isn't supposed to happen, probably */\n");
#endif

	if (!strcmp(var+VARLN, ".str")) {
#if TRACE_VLATE
	    printf("/* Can't happen, probably */\n");
#endif
	    if (bound(reqs, var, tmp)) {
		/*  bound register, get its number!	*/
		char		bf[MAXREQLEN];
		unquote(bound(reqs, var, tmp), bf);
#if 0
		sprintf(src, "&Hnodes[%d]", install(bf)->h_number);
#endif
		result = GFIXED;
		}

	    /* This getreg needs to be fixed to more params !!! */
	    else sprintf(src, "getreg(%d)", getresultype(newpat->p_rt));

	    if (!strlen(commentbf)) {
		SAFESTRCPY(commentbf, "GETREG");
		}
#if TRACE_VLATE
	    printf("vlate => %d line %d\n", result, __LINE__);
#endif
	    return result;
	    }
        }

    /*  can we give it a value from the required vector */
    if (bound(reqs, var, tmp)) {
	if (!strlen(commentbf)) {
	    SAFESTRCPY(commentbf, bound(reqs, var, tmp));
	    }
#if TRACE_VLATE
	printf("vlate calls reqlate '%s'\n", commentbf);
#endif
	reqlate(Opt, reqs, bound(reqs,var,tmp), src);
#if TRACE_VLATE
	printf("vlate => GFIXED %s at line %d\n",
		bound(reqs, var, tmp), __LINE__);
#endif
        return GFIXED;
        }

#if TRACE_VLATE
    printf("vlate => 0 at line %d\n", __LINE__);
#endif
    return 0;
    }

static olate(Opt, reqs, var, emit, src)	/* look for a value	*/
    int		emit;			/* in the already-done	*/
    char	*src, *reqs, *var;	/* outputs.		*/
    struct Optrec *Opt;
    {
    int		ix;
    char	tmp[MAXREQLEN];

#if 0
    printf("olate reqs '%s' var '%s' emit %d src '%s'\n",
	reqs, var,  emit, src);
#endif
    if(!strlen(commentbf))
    {
	sprintf(commentbf, VARFMT, VAR(var));
    }
    for (ix = emit - 2; ix >= 0; ix--) {
        if (VAR(var) == setsvar(&Opt->new[ix])) {
            /*  use a constant for value if it's available      */
	    if (bound(reqs, var, tmp))
		reqlate(Opt, reqs, bound(reqs, var, tmp), src);
            else if (!strcmp(var+VARLN, ".str")) sprintf(src, "IVAR(i%d,0)", ix);
	    else if (!strcmp(var+VARLN, ".kid")) sprintf(src, "i%d", ix);
	    else 
		cerror("can't translate %s", var);
#if 0
	    printf("olate var=%s returns 0\n", var);
#endif
            return 1;
            }
        }
#if 0
    printf("olate var=%s returns 0\n", var);
#endif
    return 0;
    }

#define TRACE_ILATE 0

/*  Try to get a value from one of the input records.  Comparisons with
 *  quoted string constants use ISTR(ISYM()) macro calls.  Other string-
 *  to-string comparisons use ISYM macro calls.
 */
static ilate(Opt, reqs, var, src, constant_comparison)
    struct Optrec	*Opt;
    char	*var, *reqs, *src;
    {
    int		i, locv, globv;
    struct patrec *p;
    char	*s;
    strcpy(src,var);

retryequiv:
    if (strlen(src) > VARLN+4) {
	cerror("ilate: strlen(\"%s\") > %d and shouldn't be?!?\n",src,VARLN+4);
	}

#if TRACE_ILATE
    printf("ilate var %s reqs %s\n", src, reqs);
#endif
    for (i = 0; i < Opt->olen; i++) {
        p = &Opt->old[i];
	/*  check input patterns starting at the leaves			*/
	/*  we work up from the leaves so that lines which re-use	*/
	/*  inputs and are collapsed out, don't get pointed to		*/
	/*  ie if r[%01] = r[%01] + %02 loses, references to %01 want 	*/
	/*  to be satisfied by the kid of this instruction.		*/
	for (locv = 0; locv < MAXGLOBALS+MAXFREENONTERMS; locv++ ) {
	    if (p->map[locv] == VAR(src)) {
#if TRACE_ILATE
		printf("ilate has %s locv %d\n", src, locv);
#endif
		s = inam(Opt, i);
		if (!strlen(commentbf)) {
		    SAFESTRCPY(commentbf, src);
		    }

		if (!strcmp(src+VARLN, ".kid") && p->p_kidlb <= locv &&
		    locv < p->p_kidub) {
		    sprintf(src, "IKID(%s,%d)", s, locv);
#if TRACE_ILATE
		    printf("ilate returns %s\n", src);
#endif
		    return 1;
		    }

		else if (!strcmp(src+VARLN, ".str")) {
		    if (locv < p->p_kidlb || p->p_kidub <= locv ||
			test_setslvar(p->p_rt, locv)) {
			sprintf(src,
			    constant_comparison ? "ISTR(ISYM(%s,%d))" : "ISYM(%s,%d)",
			    s, locv);
#if TRACE_ILATE
			printf("ilate returns %s\n", src);
#endif
			return 1;
			}
		    }

		else if (!strcmp(src+VARLN, ".num")) {
		    if (locv < p->p_kidlb || p->p_kidub <= locv ||
			test_setslvar(p->p_rt, locv)) {
			/* NEW */
			int h = skinstall(p->assem, sigs[p->signumber]);
			globv = p->map[locv];
			/* NEW */
			if (h == CNSTU) {
			    sprintf(src, "UVAL(ISYM(%s,%d))", s, locv);
			    }
			else if (h == CNSTI) {
			    sprintf(src, "IVAL(ISYM(%s,%d))", s, locv);
			    }
			else if (h == CNSTC) {
			    sprintf(src, "CVAL(ISYM(%s,%d))", s, locv);
			    }
			else if (h == CNSTP) {
			    sprintf(src, "PVAL(ISYM(%s,%d))", s, locv);
			    }
			else if (h == CNSTS) {
			    sprintf(src, "SVAL(ISYM(%s,%d))", s, locv);
			    }
			else if ((Opt->o_numbers & (1 << globv)) == 0) {
#if TRACE_ILATE
			    printf("ilate: wanting %%%d.num but it is a string\n",
				globv);
#endif
			    sprintf(src, "atoi(ISTR(ISYM(%s,%d)))", s, locv);
			    }
			else {
			    sprintf(src, "INUM(%s,%d)", s, locv);
			    }
#if TRACE_ILATE
			printf("ilate returns %s\n", src);
#endif
			return 1;
			}
		    }
		}
	    }
        }

    while (*reqs) {
	 if (VAREQ(reqs) && VAR(reqs) == VAR(src)) {
#if TRACE_ILATE
	    printf("ilate vareq %d src %s reqs %s\n",VAR(reqs),src,reqs);
#endif
	    sprintf(src,VARFMT,VAR(reqs+VARLN+6));
	    sprintf(src+VARLN,"%4.4s",reqs+VARLN+6+VARLN);
#if TRACE_ILATE
	    printf("ilate retrying with %s\n",src);
#endif
	    goto retryequiv;
	    }
	reqs++;
	}
#if TRACE_ILATE
    printf("ilate fails\n");
#endif
    *src = 0;
    return 0;
    }

static inment(o, globv)			/* count mentions of globv on 	*/
    struct Optrec	*o;		/* the input side of the opt o	*/
    int			globv;
    {
    int			locv, result = 0, ix;

#if 0
    printf("inment(globv=%d => ", globv);
#endif
    for (ix = 0; ix < o->olen; ix++)
	for (locv = 0; locv < MAXGLOBALS+MAXFREENONTERMS; locv++)
	    if (o->old[ix].map[locv] == globv) result++;
#if 0
    printf("%d\n", result);
#endif
    return result;
    }

static emitthen(Opt)	/* emit code to perform the opt		*/
    struct Optrec	*Opt;
    {
    struct patrec	*newpat;
    int			globv, locv, j, t, losers, ix;
    char		*s, src[MAXREQLEN], tmp[VARLN+5], dst[MAXREQLEN];
    int			h, kix, k;
    char		opted[MAXOPTSIZE];

    bzero((char *) delta, sizeof(delta));

    if (NOVAR != (globv = setsvar(&Opt->old[0])))
	delta[globv]--;	/* root loses	*/

    for (ix = 0; ix < Opt->nlen; ix++) {
	newpat = &Opt->new[ix];

	for (locv = 0; locv < MAXGLOBALS+MAXFREENONTERMS; locv++) {
	    if (NOVAR != (globv = newpat->map[locv]) &&
		globv == setsvar(newpat)) {

		/*  is the dst a register                                 */
		/*  determine if we want to push a value on the stack     */
		/*  We do if we ever have to allocate a register          */
		/*  (even if the register is known, ie r[0] = CALL(..))   */
		delta[globv]++;			/* count reg use      */
		}
	    }
        }


    /*	Generate transfers for each output instruction	*/
    /*  Allocate new outputs and assign pattern pointers              */
    /*  make a list of copies                                         */
    for (ix = 0; ix < Opt->nlen; ix++) {
	newpat = &Opt->new[ix];

	/*  Generate transfers for each field of this output instruction */
	/* shouldn't we be going from kidlb to kidub to varub(&root)??? */
	for (locv = 0; locv < MAXGLOBALS+MAXFREENONTERMS; locv++) {

	    if (NOVAR != (globv = newpat->map[locv])) {

#if 0
		printf("generating xfer to set global %%%02d\n", globv);
#endif

		/* can we check to see if it is a string or a num ??? */
		if (Opt->o_numbers & (1<<globv)) {

#if 0
		    printf("a number\n");
#endif
		    sprintf(tmp, VARFMT, globv);
		    SAFESTRCAT(tmp, ".num");

		    t = vlate(Opt, Opt->o_reqs, ix + 1, tmp, src, 0);

		    /*  set var field if not a register */
		    if (!isareg[globv] || t == GFIXED && lernflg) {
			sprintf(dst, "INUM(%s,%d)", onam(Opt, ix), locv);
			stashxfer(dst, src, 20, commentbf, 10);
			commentbf[0] = '\0'; /* Null out the comment buffer */
			}
		    }
		else {
		    sprintf(tmp, VARFMT, globv);
		    SAFESTRCAT(tmp, ".str");

#if 0
		    printf("a string o_reqs '%s'\n", Opt->o_reqs);
#endif
		    t = vlate(Opt, Opt->o_reqs, ix + 1, tmp, src, 0);

		    if (!t) {
			printf("/* emitthen: no translation for %%%d! */\n",
				globv);
			}

		    /*  set var field if not a register */
		    if (!isareg[globv] || t == GFIXED && lernflg) {
			sprintf(dst, "ISYM(%s,%d)", onam(Opt, ix), locv);
			stashxfer(dst, src, 20, commentbf, 10);
			commentbf[0] = '\0'; /* Null out the comment buffer */
			}
		    }

		sprintf(tmp, VARFMT, globv);
		SAFESTRCAT(tmp, ".kid");
		t = vlate(Opt, Opt->o_reqs, ix + 1, tmp, src, 0);

		if (t && isareg[globv] && *src &&
			readslvar(newpat->p_rt, locv)) {
		    sprintf(dst, "IKID(%s,%d)", onam(Opt, ix), locv);

		    /* count uses of instruction setting this register	*/
		    stashxfer(dst, src, 20, "counted", 10);
		    }
		}
	    }
        }

    docounts(Opt);			/* use list to update use cts	*/

    /*  If any inputs are losing all references, try to re-use those input
     *  nodes as output dag nodes.  This can save several assignments on
     *  simple 2->2 opts where the old kid already resembles the new kid.
     */
    losers = 0;				/* # of inputs losing all refs	*/
    for (ix = Opt->olen - 1; ix >= 0; ix--) {
	if (getuse(inam(Opt, ix)) == 0) {
#if 0
	    printf("%s loses all refs\n", inam(Opt, ix));
#endif
	    if (losers < Opt->nlen - 1) {
		stashxfer(onam(Opt, losers), inam(Opt, ix), losers+5, "tmp", 3);
		dekid(Opt, inam(Opt, ix), ix);
		bumpuse(onam(Opt, losers), -olduse(inam(Opt, ix)), 0);
		}
	    losers++;
	    }
	}

    /*  Allocate new instructions and initialize use counts */
    for (ix = losers; ix < Opt->nlen - 1; ix++) {
	char	bf[40];
	bumpuse(onam(Opt, ix), -1, 0);
	sprintf(bf, "i%d", ix);
	printf("\ti%d                   = nextins++;\n", ix);
	sprintf(bf, "i%d->count", ix);
	stashxfer(bf, "1", 30, "", 10);
	}

#if 1
    /*  MOVED FROM HERE */
    if (Opt->nlen) {
	docounts(Opt);			/* re-figure use counts		*/
	outuse(Opt);			/* output use counts		*/
	}
#endif

    printf("\tPERFORM(\"perform %d->%d opt at line %%d\\n\")\n",
	Opt->olen, Opt->nlen);

    for (ix = 0; ix < Opt->nlen; ix++) {
	newpat = &Opt->new[ix];
	s = onam(Opt, ix);

	/*  Always set the opcode.  We avoided setting the opcode by
	    branching to a location that optimized dags rooted at this
	    opcode.  We don't do that anymore, because we are getting
	    big optimizations that usually suck in everything that
	    they can with one inhalation.  The old way was to loop at
	    a given node until it and its descendants were optimized
	    and then to descend into the dag.  Now we hit the node once
	    then descend, then hit the node once more on the way back
	    up.  So, always set the opcode.
	*/
	setopcodes(newpat, s);
	}

    doxfers();				/* do the transfers		*/

#if 0
    if (Opt->nlen) {			/* MOVED TO HERE */
	docounts(Opt);			/* re-figure use counts		*/
	outuse(Opt);			/* output use counts		*/
	}
#endif

    printf("\tAFTER()\n");
#if 0
    printf("#if DEBUG\n");
    printf("printf(\"perform %d->%d opt at line %%d\\n\", __LINE__);\n",
	Opt->olen, Opt->nlen);

    printf("printf(\"after opt:\\n\"); dagdump(globr, 0, r, -1);\n");
    printf("#endif DEBUG\n");
#endif

    /* so we don't get messed up in our checks and whatnot */
    globv = skinstall(Opt->new[Opt->nlen - 1].assem,
			sigs[Opt->new[Opt->nlen - 1].signumber]);
    /* need to set up signature (skinstall) */
    if (!globv) {
	cerror("emitthen2: unable to find sig for %s\n",
	   Opt->new[Opt->nlen - 1].assem);
	}
    /*
    printf("\tINSOP(r) = %d;",globv);
    */

    /*	Optimize all children of new instructions.  Do kids before their
     *  parents!  Avoid making recursive opt calls on kids, if they are
     *  new output nodes (whose opcodes are always known) and there are
     *  no optimizations that could affect them.
     *  The plan is as follows:
     *  Try to optimize node x if we do not know what x's opcode is.
     *  If we do know what the opcode is and it is possibly optimizable,
     *  we will try to optimize it. 
     *  To optimize a node, we will generate a recursive opt call, or a
     *  goto Lxx, or goto retry.
     *  Issue goto L14 for the last opt call, if we know that the opcode is 14.
     *  Goto retry for the last opt, if we do not know the opcode.
     *  We will make recursive calls if we have other opt calls to follow.
     *  We will return if we have no opts to do at all.
     *  It is possible that a new output with multiple uses might screw us
     *  up, for we might do a recursive call to optimize it, and then
     *  (because it is the kid of two nodes) do a goto L14 even though its 
     *  opcode is no longer 14.   To avoid this, we are careful not to 
     *  optimize a node twice.
     */
    bzero(opted, sizeof(opted));

    for (ix = 0; ix < Opt->nlen; ix++) {
	h = skinstall(Opt->new[ix].assem, sigs[Opt->new[ix].signumber]);

	/* need to set up signature (skinstall) */
	if (!h) {
	    cerror("emitthen3: unable to find sig for %s\n",
		   Opt->new[ix].assem);
	    }

	for (locv = kidlbn(h); locv < kidubn(h); locv++) {
	    kix = kidix(Opt, ix, locv);
	    if (kix == -1) {
		printf("\topt(IKID(%s,%d));\n", onam(Opt, ix), locv);
		}
	    else if (!opted[kix]) {
		opted[kix] = 1;
		k = skinstall(Opt->new[kix].assem,
			sigs[Opt->new[kix].signumber]);
		if (!k)
		    cerror("emitthen3: unable to find sig for %s\n",
		       Opt->new[kix].assem);
		if (bittest(defined, k)) {
		    printf("\topt(IKID(%s,%d));\n",
			onam(Opt, ix), locv);
		    }
		}
	    }
	}

    if (flat_rule_flag)
	printf("\tgoto retry;\n");
    else if (bittest(defined, globv)) {
	char	bf[MAXRTLINE];
	printf("\tgoto L%d;\t/* %s */\n",
	    globv, quote(skelptr[globv], bf));
	}
    else {
	printf(lernflg ? "\tgoto defalt;\n" : "\treturn;\n");
	}

    if (ifemitted) printf("\t%c\n", RCURLY);
    }

/*  If kid #kidno of the parent is involved in the optimization, return the
 *  kid's index, else return -1.
 */
static int kidix(Opt, parent, kidno)
    struct Optrec *Opt;
    {
    int		ix;
    for (ix = 0; ix < parent; ix++) {
	if (Opt->new[ix].parent == parent && Opt->new[ix].kidno == kidno)
	    return ix;
	}
    return -1;
    }
  
static char *onam(Opt, ix)	/* name of reg holding n'th output ins	*/
    struct Optrec	*Opt;
    int			ix;
    {
    static char		result[40];
    sprintf(result, (ix == Opt->nlen - 1) ? "r" : "i%d", ix);
    return result;
    }

/*  Emit assignments to rt and assem					*/
/*  Happens if we are generating a learning or debuggable optx.c, or	*/
/*  we are about to jump to the default label and exit the switch-loop.	*/
/*  We try to emit assignments to opcodes early in the sequence so	*/
/*  that trailing bits of sequences will be the same, giving long	*/
/*  branch chains.							*/
static setopcodes(pat, ptrname)
    struct patrec	*pat;
    char		*ptrname;	/* name of insrec pointer	*/
    {
    char		tmp[500];
    char		number[20];
    char		bf[MAXREQLEN];

    quote(pat->assem, bf);			/* for comment	*/
    sprintf(tmp, "INSOP(%s)", ptrname);
    sprintf(number, "%d", skinstall(pat->assem,sigs[pat->signumber]));

    stashxfer(tmp, number, 30, bf, 5);		/* set opcode	*/

    if (lernflg) {
	quote(pat->p_rt, bf);
	sprintf(tmp, "%s->rt", ptrname);
	printf("\t%-20s = %s;\n", tmp, bf);
	/*	stashxfer(tmp, bf, 30, bf, 10);	*/
	}
    }

/*  dump names of all the assembler language opcodes */
static dumpskels()
    {
    int		i;
    char	bf[MAXRTLINE];
    for (i = 0; i < nskels; i++)
	if (skelptr[i] == 0)
	    printf("\t/* %d */\t0,\n", i);
	else
	    printf("\t/* %d */\t%s,\n", i, debackslashn(quote(skelptr[i], bf)));
    }

/*  dump signature numbers for all assembler language opcodes */
static dumpsigs()
    {
    int		i;
    char	bf[MAXRTLINE];
    for (i = 0; i < nskels ; i++) {
	printf("\t%d,\t/* %s */\n", sigptr[i],
		(skelptr[i]) ?
		debackslashn(quote(skelptr[i], bf)) :
		"NULL");
	}
    }

static char *debackslashn(s)		/* delete backslashes followed	*/
    char *s;				/* by n's or tabs(cr's)		*/
    {
    char	*t, *d;
    static char result[512];

    for (d = result;; s++) {
	if (*s == '\\' && (*(s+1) == 'n' || *(s+1) == 't'))
	    s++;
	if (!(*d++ = *s)) break;		/* else just copy input */
	}
    return result;
    }

#define TRACE_GENOPT 0

/*  Generalize a rule by trying to delete constraints and seeing if the
 *  rule still says to do the same thing.  The new rule will then be more
 *  applicable than the old rule, and will require fewer compile-time
 *  tests.
 */
static genopt(oldo)
    struct Optrec *oldo;
    {
    struct Optrec nouse;		/* opt with no use count constraint */
    struct Optrec newo;			/* new opt with improvements */
    int		i, oldmax = ABSURD_USECT, newmax;
    double	costin[MAXOPTSIZE], costout[MAXOPTSIZE];
    int		newbig;
    char	*q, *nextq, *limq, reqbf[MAXREQLEN], ousereq[MAXREQLEN];
    int		removed = 0;
    char	tmpq[MAXREQLEN];

    struct Constraint constraint;

    nouse = *oldo;

    /*	record the current use count constraint	if any and delete it	*/
    *ousereq = 0;
    if (fmatch(nouse.o_reqs, "kid->count<=")) {
#if TRACE_GENOPT
	printf("/* isolating use count constraint before '%s' */\n",
		nouse.o_reqs);
#endif
	oldmax = atoi(epos);
	while (*bpos != ';')			/* skip back to ;: */
	    bpos--;
	if (bpos[-1] == ';')
	    bpos--;
	while (isdigit(*epos)) epos++;
	strncpy(ousereq, bpos, epos - bpos + 1);
	ousereq[epos - bpos] = 0;
	sub(nouse.o_reqs, "");
#if TRACE_GENOPT
	printf("/* after '%s' '%s' */\n", nouse.o_reqs, ousereq);
#endif
	}

    retry:

    SAFESTRCPY(reqbf, nouse.o_reqs);	/* remember old constraints	*/
    newo = nouse;			/* copy usecountless opt	*/
    limq = reqbf + strlen(reqbf);

    /*	Try to remove each req in turn from reqbf, stick the resulting	*/
    /*	reduced req into newo.						*/

    for (q = reqbf; *q == ';'; q = nextq) {
	nextq = index(q + 2, ';');
	if (nextq == NULL) nextq = limq;
	SAFESTRNCPY(newo.o_reqs, reqbf, q - reqbf);

	if (q[1] == ';')		/* ;; begins nonremovable reqs */
	    goto fail;			/* ;: reqs are removable */

	strncpy(newo.o_reqs + (q - reqbf), nextq, limq - nextq);
	newo.o_reqs[q - reqbf + limq - nextq] = 0;

	SAFESTRNCPY(tmpq, q, nextq - q);
	constraint = parsecon(tmpq);

	/* Do not remove constraints on registers, because this will mess
	 * up the allocation signature.  They are never checked anyway.
	 */
	if (isareg[VAR(constraint.v0)]) {
	    goto fail; /* don't even try and remove it!!! */
	    }

#if TRACE_GENOPT
	printf("trying to remove '%.*s'\n", nextq-q, q);
#endif
	if (constraint.ty == '?') {		/* that we don't	*/
#if TRACE_GENOPT
	    printf("/* lay off '%s' */\n", q);	/* understand		*/
#endif
	    goto fail;
	    }
#if TRACE_GENOPT
	printf("/* next reduced reqs '%s' */\n", newo.o_reqs);
	printf("genopt calling prep_run for old side\n");
#endif

	prep_run(&newo, newo.old, newo.olen, costin);
#if TRACE_GENOPT
	printf("genopt calling prep_run for new side\n");
#endif
	prep_run(&newo, newo.new, newo.nlen, costout);

#if TRACE_GENOPT
	printf("/* old costs %g->%g */\n", oldo->o_ocost, oldo->ncost);
	printf("/* new costs %g->%g */\n", newo.o_ocost, newo.ncost);
#endif
	if (oldo->ncost < BOGUS && newo.ncost >= BOGUS ||
	    oldo->o_ocost < BOGUS && newo.o_ocost >= BOGUS) {
#if TRACE_GENOPT
	    printf("cannot delete this req\n");
#endif
	    continue;
	    }

	newbig = -1;
	for (i = 0; i < newo.olen; i++) {
	    if (i < newo.olen - 1 &&
		(newbig == -1 || costin[i] > costin[newbig])) newbig = i;
	    }
#if TRACE_GENOPT
	printf("/* big input kid %d cost %g */\n", newbig, costin[newbig]);
#endif

	if (newbig == -1 || newo.ncost <= newo.o_ocost - costin[newbig])
	    newmax = ABSURD_USECT;
	else if (newo.olen > 1) {
	    newmax = floor((double)costin[newbig] /
			    ((double)newo.ncost - newo.o_ocost + costin[newbig]));
	    if (newmax <= 1) newmax = 2;
	    newmax--;
	    }

#if TRACE_GENOPT
	printf("/* newmax %d oldmax %d */\n", newmax, oldmax);
#endif
	if (newmax != oldmax && newmax < ABSURD_USECT) goto fail;

	for (i = 0; i < oldo->olen; i++)
	    if (strcmp(oldo->old[i].assem, newo.old[i].assem)) {
#if TRACE_GENOPT
		printf("/* input sides don't match */\n");
#endif
		goto fail;
		}

	for (i = 0; i < oldo->nlen; i++) {
#if TRACE_GENOPT
	    printf("oldo->new[%d].assem %s\n", i, oldo->new[i].assem);
	    printf("newo.new[%d].assem %s\n", i, newo.new[i].assem);
#endif
	    if (strcmp(oldo->new[i].assem, newo.new[i].assem)) {
#if TRACE_GENOPT
		printf("/* output sides don't match */\n");
#endif
		goto fail;
		}
	    }

	/*  Found a removable constraint	*/
	remove:
	nouse = newo;			/* remember removed version	*/
#if TRACE_GENOPT
	printf("/* this one is removable */\n");
#endif
	removed++;			/* and  that we got one		*/
	goto retry;			/* start over			*/
	fail: ;
	}

    if (removed) {
	SAFESTRCPY(newo.o_reqs, reqbf);
#if TRACE_GENOPT
	printf("/*");
	if (oldo->o_file[0]) {
	    printf("# file %s line %d\n", oldo->o_file, oldo->o_lineno);
	    }
	writeopt(oldo, stdout, 1);
	printf(" => '%s'\n", newo.o_reqs);
	printf(" */\n\n");
	fflush(stdout);
#endif
	if (*ousereq)
	    addreq(nouse.o_reqs, ousereq, '[', __FILE__, __LINE__);
	*oldo = nouse;
	}
#if TRACE_GENOPT
    else printf("genopt does nothing\n");
#endif
    }

/*  isolate the requirement from the list and return buffers for both	*/
isoreq(req, reqlist, reqout, rest)
    char	*req;			/* remove me (ptr is past ;)	*/
    char	*reqlist;		/* from this list */
    char	*reqout;		/* copy me into this buffer	*/
    char	*rest;			/* rest of the list goes here	*/
    {
    char	*s;
    int		reqlen, prefixlen;

    s = index(req, ';');			/* point to end of req	*/
    if (s == NULL) s = req + strlen(req);
    reqlen = s - req;				/* len not counting ;	*/
    prefixlen = req - 1 - reqlist;		/* length of stuff in front */

    strncpy(rest, reqlist, prefixlen);
    strcpy(rest + prefixlen, reqlist + prefixlen + reqlen + 1);
    sprintf(reqout, "%.*s", reqlen, req);
    }


#define TRACE_INAM 0

/*  construct name of kid chain at level n (root = level olen - 1)
 *  IKID(IKID(IKID(r,1),2),3)
 */
char *inam(Opt, level)
    struct Optrec	*Opt;
    int			level;
    {
    static char		result[200];	/* Must be static */
    char		tmp[200];	/* Must be auto */

#if TRACE_INAM
    printf("inam(Opt,%d)\n", level);
    printf("Opt->olen %d\n", Opt->olen);
#endif
    if (level == Opt->olen - 1) {
#if TRACE_INAM
	printf("inam returns 'r'\n");
#endif
	return "r";
	}

    sprintf(tmp, "IKID(%s,%d)", inam(Opt, Opt->old[level].parent), Opt->old[level].kidno);
    SAFESTRCPY(result, tmp);
#if TRACE_INAM
    printf("inam returns '%s'\n", result);
#endif
    return result;
    }

#if 0
CURRENTLY NOT USED

/* If you get a codegen	*/
/*  rule that could be better if some other constraint were satisfied,	*/
/*  the additional constraint is added to a copy of the rule and the	*/
/*  constrained version is pushed on the unsat stack.  We loop till	*/
/*  we empty the stack.							*/

static	addunsat();		/* add new opt with unsat'd constraints	*/
#define NUNSAT 500
static struct Optrec *unsat[NUNSAT];
static int nunsat;
    /*  If we are checking the output side of a codegen rule and */
    /*  we still have room in the unsat table, construct a new */
    /*  codegen rule that checks the unsatisfied constraint */
    else if (codegen && side == Opt->new && nunsat < NUNSAT) {
	newo = get(struct Optrec);
	if (!newo) cerror("%s %d : no memory",__FILE__,__LINE__);
	*newo = *Opt;
	SAFESTRCPY(newo->reqs, reqs); 
	addunsat(newo);
	}
for (;;) {
    if (nunsat == 0) break;		/* any unsatisfied reqs?	*/
    o = unsat[--nunsat];		/* yes, add it too		*/
    }
static addunsat(unsatopt)		/* Add unsatisfied opt to the list */
    struct Optrec	*unsatopt;	/* of all unsatisfied opts.  Check */
    {					/* for duplicates.  The unsat list */
    int			i, j;		/* is a list of opts that we would */
    struct Optrec	*oldopt;	/* do if their conditions were met */
    for (i = 0; i < nunsat; i++) {
	oldopt = unsat[i];

	/*  Check lengths of input & output sides */
	if (oldopt->olen != unsatopt->olen ||
	    oldopt->nlen != unsatopt->nlen ||
	    strcmp(oldopt->reqs, unsatopt->reqs)) continue;

	/*  Check input sides */
	for (j = 0; j < unsatopt->olen; j++) {
	    if (strcmp(oldopt->old[j].p_rt, unsatopt->old[j].p_rt))
		goto nexto;
	    if (bcmp(oldopt->old[j].map, unsatopt->old[j].map, MAXGLOBALS+MAXFREENONTERMS))
		goto nexto;
	    }

	/*  check output sides */
	for (j = 0; j < unsatopt->nlen; j++) {
	    if (strcmp(oldopt->new[j].p_rt, unsatopt->new[j].p_rt))
		goto nexto;
	    if (bcmp(oldopt->new[j].map, unsatopt->new[j].map, MAXGLOBALS+MAXFREENONTERMS))
		goto nexto;
	    }

	free(unsatopt);			/* zap this duplicate	*/
	return;
nexto:;
	}
    unsat[nunsat++] = unsatopt;
    }
    int				codegen;	/* is this a codegen rule? */
    codegen = rootin(Opt)->cost == BOGUS && Opt->olen == 1;
#endif
