/* You have this code because you wanted it now rather than correct.
   Bugs abound!  Contact Alan Wendt for a later version or to be
   placed on the chop mailing list.  Parts are missing due to licensing
   constraints.

   Alan Wendt / Computer Science / Colorado State Univ. / Ft Collins CO 80523
   303-491-7323.  wendt@cs.colostate.edu
*/
/* cchop.c turn rules into C */

#include <stdio.h>
#include <ctype.h>
#include "c.h"
#include "ops2.h"
#include "hop2.h"
#include <sys/file.h>
#include "md.h"

static genmoves();

int	cseflg = 0;			/* generate test for cse's	*/
int	lernflg = 0;			/* emit comb calls		*/
int	flat_rule_flag = 0;			/* emit jim eberle code		*/
int	debflg;				/* generate debugging code	*/
int	lineno;				/* unused; placate the linker	*/


char *parfname = "parf";

struct Sig	sigs[MAXSIGS];		/* allocation signatures	*/
int		nsigs;

unsign16	nskels = 0;
char		*skelvec[1];		/* skeleton name vector	*/
char		**skelptr = skelvec;	/* realloc-ed skel ptr	*/
short		signature_vector[1];
short		*sigptr = signature_vector;

static struct Sig     newsig;

main(argc, argv)
    int argc; char **argv;
    {
    FILE *fp;
    int				i;

    skinstall(string("BAD PATTERN"), newsig);	/* null pattern installed 1st */

    getmd("md");			/* suck up machine description */

    for (i = 1; i < argc; i++) {
	if (!strcmp(argv[i], "-l")) lernflg++;
	else if (!strcmp(argv[i], "-c")) cseflg++;
	else if (!strcmp(argv[i], "-d")) debflg++;
	else if (!strncmp(argv[i], "-f", 2)) parfname = argv[i]+2;
	else if (!strncmp(argv[i], "-j", 2)) flat_rule_flag++;
	else if (argv[i][0] != '-') {
	    if ((fp=fopen(argv[i], "r")) == NULL) {
		cerror("cchop: can't open %s\n", argv[i]);
		}
	    readopts(fp);
	    fclose(fp);
	    }
	}

    dumpopts();
    exit(0);
    }



/*  Generate names for intermediate code, plus arities and similar info. */
#define debug_init_ptbl 0
init_ptbl()	/* init intermediate code tables for front end	*/
    {
    struct patrec	rtp, *pp, *asmpp;
    struct Pn		*pn;			/* production ptr */
    struct Toklist	*tok;			/* token in a pn	*/
    struct State	*sp;			/* a parse state	*/
    register int	op, ty, k;
    int			first_opcode_number, newty;
    char		opchar, asmbf[MAXRTLINE], rtbf[MAXRTLINE], *s;
    char		tmpbf[MAXLINE];
    int			v, i;
    unsign32		numbers, lnumbers;

    static struct opcodes {
	char	*name;
	int	opcode;
	int	arity;
	} opcodes[] = {

#define xxop(a,b,c,name,arity,f)
#define yyop(a,b,c,name,arity,f) { name, a, arity },
#include "ops.h"

	};

    /*  Turn e.g. "ASGNI" into "ASGNI %01,%02" so that the machine description can refer
     *  to the kid pointers by number.  Currently only kids get numbered because no
     *  intermediate code takes two constant (symbol table pointer) operands.
     */
    for (i = 0; i < nelts(opcodes); i++) {
	strcpy(tmpbf, opcodes[i].name);
	if (opcodes[i].arity) {
	    strcat(tmpbf, " ");
	    for (k = 1; k <= opcodes[i].arity; k++) { 
		sprintf(endof(tmpbf), "%%%02d", k + MAXSYMS - 1);
		if (k != opcodes[i].arity)
		    strcat(tmpbf, ",");
		}
	    }
	opcodes[i].name = string(tmpbf);
	}

    /*  for each alternative of "inst" */
    for (EACHALT(ntlook("inst", NONTERM), pn)) {

	/* if the alternative is an intermediate code */
	if (pn->cost >=  BOGUS) {

	    /* replace every nonterminal in the asm string with a variable */
	    asmbf[0] = 0;
	    v = MAXSYMS;
	    for (EACHTOK(pn, 0, tok)) {
		if (tok->tokty == TERMINAL) SAFESTRCAT(asmbf, tok->text)
		else sprintf(endof(asmbf), VARFMT, v++);
		}
#if debug_init_ptbl
	    printf("/* canonizing '%s' */\n", asmbf);
#endif

	    /*	Translate assembler to register transfer to get a real rt
	     *  string, because the intermediate code has no register names,
	     *  just pattern vars.  Get one translation for this bit of code.
	     */
	    inittrans();
	    for (sp = parse(asmbf,  0); sp; sp = sp->next)
		if (sp->cost >= BOGUS) goto gotrt;

	    cerror("initptbl: can't translate '%s' to rt", asmbf);

	    gotrt:

	    strcpy(rtbf, sp->trans);

	    /*  I'm a numeric variable if I'm a range and not a register */
	    numbers = 0;
	    for (i = 0; i < MAXGLOBALS+MAXFREENONTERMS; i++) {
		if (sp->constraints[i] && index(sp->constraints[i] + 1, '-')
		&& !getregname(rtbf, i, tmpbf)) {
		    numbers |= 1 << i;
		    }
		}
#if debug_init_ptbl
	    printf("/* rt equivalent is: '%s' */\n", rtbf);
	    printf("/* numbers %o */\n", numbers);
	    printf("/* vars substituted for nonterms: %s, '%s' */\n", asmbf,rtbf);
#endif

	    /*	Call cvtpatt to canonize the rt's variable numbering.  The flag=1
	     *  says to number kid variables in the order defined by the assembly
	     *  language, so that the intermediate code's variables are known.
	     */
	    pp = cvtpatt((struct Optrec *)NULL, rtbf, asmbf, 1);

	    if (!pp) {
		cerror("cchop: unable to cvtpatt '%s'\n", rtbf);
		}

	    /*  Canonicalize the numbers bit vector */
	    lnumbers = 0;
	    for (i = 0; i < MAXGLOBALS+MAXFREENONTERMS; i++) {
		if (pp->map[i] != NOVAR && numbers & (1 << pp->map[i])) {
		    lnumbers |= 1 << i;
#if debug_init_ptbl
		    printf("/* line %d: %%%d is numeric in %s lnumbers %o */\n",
			__LINE__, i, pp->p_rt, lnumbers);
#endif
		    }
		}

	    rtp = *pp;
#if debug_init_ptbl
	    printf("/* vars renumbered canonically: %s '%s' */\n", asmbf, rtp.p_rt);
#endif
	    /* Translate rt back to assembler to get canonical numbering. I do not think that
	     * this stage is necessary, because now the register transfers are numbered to
	     * correspond with intermediate codes, and not the other way around.
	     */
	    inittrans();
	    for (sp = parse(rtp.p_rt,  1); sp; sp = sp->next) {
		if (sp->cost >= BOGUS) {
		    if (!varncmp(sp->trans, asmbf, strlen(asmbf))) {
			pp = cvtpatt((struct Optrec *)NULL, rtp.p_rt, sp->trans, 1);
			strcpy(asmbf, pp->assem);
			goto gotasm;
			}
		    }
		}

	    cerror("initptbl: can't translate '%s' back into assembler '%s'",
		pp->p_rt, asmbf);

	    gotasm:

#if debug_init_ptbl
	    printf("/* canonical '%s' */\n", asmbf);
#endif


	    /*	install the intermediate code skeleton	*/
	    /* get the varct and geneity of the rt */
	    /* store it in the signature table */
	    newsig.reslbd = pp->p_reslb;
	    newsig.resubd = pp->p_resub;
	    newsig.kidlbd = pp->p_kidlb;
	    newsig.kidubd = pp->p_kidub;
	    newsig.varlbd = pp->p_varlb;
	    newsig.varubd = pp->p_varub;
	    newsig.allocl = pn->allocl;
#if 0
	    printf("/* '%s' asmbf '%s' */\n", sp->trans, asmbf);
	    printf("/* results %d-%d kids %d-%d vars %d-%d */\n",
		newsig.reslbd, newsig.resubd - 1,
		newsig.kidlbd, newsig.kidubd - 1,
		newsig.varlbd, newsig.varubd - 1);
#endif
	    newsig.regtype = regtype(pp->p_rt, pp->p_reslb);
	    newsig.numbers = lnumbers;
	    newsig.simplers = regmove(pp->p_rt) ? -1 : 0;
	    newsig.type = gettypename(pp->p_rt);

	    tmpbf[0] = 0; /* clear out for the reqs */
	    for (i = 1; i < sizeof(tmpbf); i++)
		tmpbf[i] = '*';

	    for (i = 0 ; i < nelts(sp->constraints); i++) {
		if (sp->constraints[i]) {
		    addcon(i, tmpbf, pp, sp->constraints[i], __FILE__,
			   __LINE__, lnumbers & (1<<i));
#if debug_init_ptbl
		    printf("init_ptbl: addcon returns '%s'\n", tmpbf);
#endif
		    }
		}

#if debug_init_ptbl
	    printf("/* for %s, tmpbf is %s */\n",pp->assem,tmpbf);
#endif
	    for (i = 0; i < nelts(newsig.vec); i++)
		newsig.vec[i] =  0;

	    for (i = newsig.kidlbd; i < newsig.kidubd; i++)
		newsig.vec[i] = bittrans(tmpbf, i, pp);

	    for (i = newsig.reslbd; i < newsig.resubd; i++)
		newsig.vec[i] = bittrans(tmpbf, i, pp);

	    k = skinstall(string(asmbf), newsig);

#if debug_init_ptbl
	    printf("/* got '%s' signo %d */\n", asmbf, sigptr[k]);
#endif
	    }
	}

    /*  Move all of the installed opcodes to the positions assumed by
     *  the front end.
     */
    for (i = 0; i < nelts(opcodes); i++)
	skmove(opcodes[i].name, opcodes[i].opcode);

    /*  Add empty slots at the end of the skeleton vector so that anything
     *  that gets installed subsequently will be >= MAXOP so that it will
     *  not be interpreted as an intermediate opcode.  cchop installs a few
     *  register-to-register move instructions.
     */
    while (nskels < MAXOP)
	growskelvec();
    }


/*  Dump signatures, intermediate code operator strings, and the maps from the
 *  first char of intermediate code to vectors of intermediate code operators.
 */
dump_ptbl()	/* dump intermediate code tables for front end	*/
    {
    register int	locv, ty, op;
    unsigned		r;
    int			i;

    genmoves();				/* generate reg->reg copies	*/

    dump_alloclasses();

    printf("int nsigs = %d;\n", nsigs);
    printf("struct Sig sigs[%d] = {\n", MAXSIGS);

    for (ty = 0; ty < nsigs; ty++) {
	printf("\n\t/* %d: %s */\n", ty, egs[ty]);
	printf("\t");
	writesig(stdout, ty);
	printf(",\n");
	}
    printf("\t};\n\n");
    }


/*  Build a list of register-to-register moves,  so that when a register
 *  needs to get spilled, we can index the table and get the text of an
 *  instruction to do it.
 */
static genmoves()
    {
    char	bf[MAXRTLINE];
    char	destname[MAXRTLINE], srcname[MAXRTLINE];
    int		fromclass, toclass;	/* reg classes */
    int		fromset, toset;		/* bit masks for legal regs */
    struct	State *sp, *best;
    int		n;

    printf("short moveops[%d] = %c\n", NOREG * NOREG, LCURLY);

    /*	Generate a register transfer string for each different
     *  register-to-register move.  Source is FIRSTKID+1 = %01,
     *  dest FIRSTKID = %00
     */

    for (fromclass = 0; fromclass < NOREG; fromclass++) {
	fromset = (1 << regpatts[fromclass].many) - 1;
	fromset <<= regpatts[fromclass].bitorg;
	for (toclass = 0; toclass < NOREG; toclass++) {
	    toset = (1 << regpatts[toclass].many) - 1;
	    toset <<= regpatts[toclass].bitorg;

	    strcpy(srcname, regpatts[fromclass].rt);
	    for (n = 0; srcname[n]; n++)
		if (!strncmp(srcname + n, "%00", VARLN)) {
		    sprintf(bf, VARFMT, FIRSTKID);
		    strncpy(srcname + n, bf, VARLN);
		    break;
		    }

	    strcpy(destname, regpatts[toclass].rt);
	    for (n = 0; destname[n]; n++)
		if (!strncmp(destname + n, "%00", VARLN)) {
		    sprintf(bf, VARFMT, FIRSTKID + 1);
		    strncpy(destname + n, bf, VARLN);
		    break;
		    }

	    /*
	    sprintf(bf, "move(%s,%s,%s)",
		srcname, destname, regpatts[toclass].typename);
	    */

	    /*  Use a variable for the type, because it doesn't matter what
	     *  type of move is used (e.g. f or l).
	     *  NOT!!
	     */
	    sprintf(bf, "move(%s,%s,", srcname, destname);
	    strcat(bf, regpatts[toclass].typename);
	    /*
	    sprintf(endof(bf), VARFMT, FIRSTKID + 2);
	    */
	    strcat(bf, ")");

	    best = NULL;
	    inittrans();
	    for (sp = parse(bf, 1); sp; sp = sp->next) {

		/*  Make sure that the answer does not constrain 
		 *  FIRSTKID or FIRSTKID+1
		 */
		if (sp->constraints[FIRSTKID] &&
		    isalpha(sp->constraints[FIRSTKID][0]))
		    continue;

		if (sp->constraints[FIRSTKID + 1] &&
		    isalpha(sp->constraints[FIRSTKID + 1][0]))
		    continue;

		if (best == NULL || best->cost > sp->cost)
		    best = sp;
		/*
		for (n = 0; n < MAXGLOBALS+MAXFREENONTERMS; n++)
		    if (sp->constraints[n]) {
			printf(" ");
			printf(VARFMT, n);
			printf("=%s", sp->constraints[n]);
			}
		*/
		}

	    if (best) {
		newsig.varlbd = FIRSTVAR;
		newsig.varubd = FIRSTVAR;
		newsig.reslbd = FIRSTKID;
		newsig.resubd = FIRSTKID + 1;
		newsig.kidlbd = FIRSTKID + 1;
		newsig.kidubd = FIRSTKID + 2;
		newsig.regtype = toclass;
		newsig.simplers = -1;
		newsig.vec[0] = toset;
		newsig.vec[1] = fromset;
		newsig.type = gettypename(bf);
		printf("%d /* %s */, ",
		    skinstall(string(best->trans), newsig), best->trans);
		}
	    else {
		printf("-1, ");
		fprintf(stderr, "moveops: WARNING: no insn for %s\n", bf);
		}
	    }
	printf("\n");
	}
    printf("\t%c;\n\n", RCURLY);
    }

/* VARARGS1 */
cerror( s, a, b, c ) char *s; { /* compiler error: die */
    fprintf( stderr, "cchop error line %d\n", lineno);
    fprintf( stderr, s, a, b, c );
    fprintf( stderr, "\n" );
#ifdef BUFSTDERR
    fflush(stderr);
#endif
    exit(1);
    }

int fatal(name, fmt, n)
    char *name, *fmt;
    {
    fprintf(stderr, fmt, n);
    exit(-1);
    }

