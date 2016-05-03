/* You have this code because you wanted it now rather than correct.
   Bugs abound!  Contact Alan Wendt for a later version or to be
   placed on the chop mailing list.  Parts are missing due to licensing
   constraints.

   Alan Wendt / Computer Science / Colorado State Univ. / Ft Collins CO 80523
   303-491-7323.  wendt@cs.colostate.edu
*/
#include <stdio.h>
#include <ctype.h>
#include "c.h"
#include "hop2.h"
#include "md.h"

static readarun();
static unsign32 numerics();
static dumpline();

static char lin[MAXREQLEN];
char	egs[MAXSIGS][MAXRTLINE];

/*  Read an insn's allocation signature from an opt pattern file */
static readsig(patinfile, eg)
    FILE *patinfile;
    char	*eg;		/* for example */
    {
    struct Sig newsig;
    int locv;

    fscanf(patinfile,"{");
    fscanf(patinfile,"%d,%d,%d,%d,%d,%d,%d,",
	&newsig.reslbd, &newsig.resubd,
	&newsig.kidlbd, &newsig.kidubd,
	&newsig.varlbd, &newsig.varubd,
	&newsig.regtype);
    fscanf(patinfile,"%d,", &newsig.simplers);
    fscanf(patinfile,"%d,", &newsig.numbers);
    fscanf(patinfile,"%d,", &newsig.allocl);
    for (locv = 0; locv < MAXSYMS+MAXKIDS; locv++) {
	fscanf(patinfile,"%d,", &newsig.vec[locv]);
	}
    fscanf(patinfile, "%d,", &newsig.type);
    fscanf(patinfile,"}");
    fgets(lin,MAXREQLEN,patinfile);
    if (strlen(lin) > 1) {		/* newline */
	cerror("extraneous stuff after sig--%s\n",lin);
	}

    return addsig(eg, newsig);
    }

/*  Write an insn's allocation signature to a opt pattern file */
writesig(patoutfile, signumber)
    FILE *patoutfile;
    unsign16 signumber;
    {
    int locv;
    int r;

    fprintf(patoutfile,"{");
    fprintf(patoutfile,"%d,%d,%d,%d,%d,%d,%d,",
	sigs[signumber].reslbd, sigs[signumber].resubd,
	sigs[signumber].kidlbd, sigs[signumber].kidubd,
	sigs[signumber].varlbd, sigs[signumber].varubd,
	sigs[signumber].regtype);
    fprintf(patoutfile,"%d,", sigs[signumber].simplers);
    fprintf(patoutfile,"%d,", sigs[signumber].numbers);
    fprintf(patoutfile,"%d,", sigs[signumber].allocl);
    for (locv = 0; locv < MAXSYMS+MAXKIDS; locv++) {
	r = sigs[signumber].vec[locv];
	if (r == -1) fprintf(patoutfile,"-1,");
	else fprintf(patoutfile,"%d,", r);
	}
    fprintf(patoutfile, "%d,", sigs[signumber].type);
    fprintf(patoutfile,"}");
    fflush(patoutfile);
    }

/*  Read an optimization from an opt pattern file */
struct Optrec *readopt(fp)
    FILE	*fp;
    {
    struct Optrec *o;
    /*  allocate an optimization */
    o = get(struct Optrec);
    if (!o) cerror("%s %d:no memory\n",__FILE__,__LINE__);
    bzero(o, sizeof(struct Optrec));
    o->olen = readarun(fp, o, o->old);
    if (!o->olen)
	return NULL;			/* read in old pattern	*/

    if (strcmp(lin, "=\n"))
	cerror("fp parity line %d `%s'", lineno, lin);

    /* read new pattern and install in table */
    o->nlen = readarun(fp, o, o->new);
    return o;
    }

/*  read one old or new run from fp, return # of patterns read.		*/
/*  Glom together literal lines (starting with -)			*/
static readarun(fp, o, side) 
    FILE *fp; struct Optrec *o;
    struct patrec	*side;
    {
    int c, patct = 0;
    struct patrec	p;
    int			i;
    char		*s, *filename;
    char		reqs[MAXREQLEN];		/* requirements */
    char		assm[MAXRTLINE];
    struct patrec	*patrec;
    double		cost, strtod();

    reqs[0] = 0;

    while (fgets(lin, MAXREQLEN, fp)) {
        lineno++;

	/*  if the opt has "#file foo line 42" at the top, grab this info */
	if (!strncmp(lin, "# file ", 7)) {
	    filename = lin + 7;
	    s = index(filename, ' ');
	    if (s) {
		i = s - filename;		/* length of filename */
		if (i > sizeof(o->o_file) - 1) {
		    i = sizeof(o->o_file) - 1;
		    }
		strncpy(o->o_file, filename, i);
		o->o_file[i] = 0;
		s++;
		if (!strncmp(s, "line ", 5) && isdigit(s[5]))
		    o->o_lineno = atoi(s + 5);
		}
	    continue;
	    }

	if (lin[0] == '#') continue;		/* comment line */
	if (lin[0] == '"') {
	    o->o_numbers = numerics(lin+1);
	    continue;
	    }

	if (lin[0] == ';') {			/* requirements */
	    lin[strlen(lin) - 1] = 0;		/* drop newline	*/
	    SAFESTRCAT(reqs, lin);
#if 0
	    printf("reqs := '%s'\n", reqs);
#endif
	    continue;
	    }

	if (!strcmp(lin, "\n") || !strcmp(lin, "=\n")) break;

	/* process escaped assembler lines (leading minus signs)	*/
	/* stick everything on one line with embedded newlines		*/
        for (;;) {
            c = getc(fp);
            if (c == '-') {
		fgets(lin + strlen(lin), MAXREQLEN - strlen(lin), fp);
		lineno++;
		}
            else {
		ungetc(c, fp);
                break;
                }
            }

        lin[strlen(lin) - 1] = 0;       /* drop last char (newline) */

	/*  remove a trailing comment, consisting of some nonzero	*/
	/*  number of tabs or spaces followed by # followed by anything.*/
	for (i = 0; lin[i]; i++) {
	    if ((lin[i] == '\t' || lin[i] == ' ') && lin[i + 1] == '#') {
		cost = strtod(lin + i + 2, (char **)NULL);
		while (lin[i - 1] == '\t' || lin[i - 1] == ' ') i--;
		lin[i] = 0;
		break;
		}
	    }

	/*  pull off constraints and add them to o->o_reqs */
	while (s = lastreq(reqs)) { 
	    addreq(o->o_reqs, s, 0, __FILE__, __LINE__);
	    *s = 0;
	    }

	fgets(assm, MAXRTLINE, fp);		/* get assembly line	*/
	lineno++;
	assm[strlen(assm) - 1] = 0;		/* zap newline	*/

#if 0
	printf("/* readarun: call cvtpatt cost %f */\n", (double)cost);
#endif
	if (!(patrec = cvtpatt(o, lin, assm, cost >= BOGUS))) {
	     cerror("cchop: cannot convert %s to a pattern.  Too many vars?\n", assm);
	    }

	p = *patrec;
	p.signumber = readsig(fp, assm);
	p.p_rt = string(p.p_rt);
	lineno++;

	patct++;
#if 0
	printf("/* readarun: got canonical rt %s varub %d */\n", p.p_rt, p.p_varub);	
#endif
	if (patct > MAXOPTSIZE) {
	    cerror(
	    "readarun: opt record side length exceeds MAXOPTSIZE at line %d\n",
		lineno);
	    }
        side[patct - 1] = p;
        }
    return patct;
    }

/*  Return a bit vector of the N's in this string of typecodes */
static unsign32 numerics(s)
    char *s;
    {
    register unsign32 onums=0,i=0;

    while(*s) {
	switch(*s++) {
	    case 'S': break;
	    case 'K': break;
	    case 'N': onums |= 1<<i;
		break;
	    case '"':
#if 0
	    printf("/* lineno %d: onums = %d */\n",lineno,onums);
#endif
	    return onums;
	    default : cerror("illegal type %c in opt types. lineno %d\n", *(s-1),lineno);
	    }
#if 0
	printf("/* lineno %d: onums = %d */\n",lineno,onums);
#endif
	i++;
	}
    cerror("no closing \" on opt types. lineno %d\n",lineno);
    }

/* record opt to file	*/
void writeopt(o, patoutfile, comment)
    struct Optrec *o;
    FILE	*patoutfile;
    {
    char		*nexts, *s;
    int			k;

    if (o->o_reqs[0]) {

	for (s = o->o_reqs;; s = nexts) {
	    nexts = nextreq(s);
	    fprintf(patoutfile, "%.*s\n", nexts - s, s);
	    if (!*nexts) break;
	    }
	}

    for (k = 0; k < MAXOPTSIZE; k++) {
	if (o->old[k].p_rt && o->old[k].p_rt[0]) {
	    dumpline(&o->old[k], patoutfile, o->old[k].p_rt,
		    (double)o->old[k].cost, comment);
	    dumpline(&o->old[k], patoutfile, o->old[k].assem, 0.0, comment);
	    writesig(patoutfile,o->old[k].signumber);
	    fprintf(patoutfile,"\n");
	    }
	}

    if (comment) putc('\t', patoutfile);	/* indent if inside comment */
    fprintf(patoutfile, "=\n");

    for (k = 0; k < o->nlen; k++) {
	dumpline(&o->new[k], patoutfile, o->new[k].p_rt,
		(double)o->new[k].cost, comment);
	fflush(patoutfile);
	dumpline(&o->new[k], patoutfile, o->new[k].assem, 0.0, comment);
	fflush(patoutfile);
	writesig(patoutfile,o->new[k].signumber);
	fprintf(patoutfile,"\n");
	}

    if (!comment) putc('\n', patoutfile);	/* leave blank line if not */
						/* in a comment		*/
    fflush(patoutfile);
    }

/*  Output one optimization line, rt or asm, with a commented cost.	*/
/*  If it's in a comment, indent everything one tab stop.		*/
static dumpline(pat, patoutfile, s, cost, comment)
    FILE	*patoutfile;		/* where to send output */
    struct patrec *pat;			/* used to get global var # */
    char	*s;			/* the line		*/
    double	cost;
    {
    if (comment) putc('\t', patoutfile);/* indent if inside a comment	*/
    if(s == NULL)
    {
	fprintf(patoutfile, "NO ASSEM");
    } else {
#if 0
	fprintf(patoutfile, "%s\n", s);
#endif
	for (; *s; s++) {
	    if (ISVAR(s)) {
	        if (VAR(s) < MAXSYMS+MAXKIDS && pat->map[VAR(s)] != NOVAR) {
		    fprintf(patoutfile, VARFMT, pat->map[VAR(s)]);
		    } 
	        else {
		    fprintf(patoutfile, VARFMT, /* VAR(s) */99);
		    }
	        s += VARLN - 1;
		}
	    else if(*s == '\n') {
		putc('\\',patoutfile);
		putc('n',patoutfile);
		}
	    else 
	        putc(*s, patoutfile);
	    }
	}
    if (cost) fprintf(patoutfile, "\t# %g", (double)cost);
    fprintf(patoutfile, "\n");
    }


/* add an allocation signature */
unsign16 addsig(eg, newsig)
    char	*eg;		/* an example of something that has this */
    struct Sig  newsig;		/* the signature itself                  */
    {
    register int		i, locv, type;
    register unsigned r;

#if 0
    printf(
"/* addsig kids %d-%d vars %d-%d results %d-%d nsigs %d eg %s allocl %o numbers %o */\n",
	newsig.kidlbd, newsig.kidubd - 1,
	newsig.varlbd, newsig.varubd - 1,
	newsig.reslbd, newsig.resubd - 1,
	nsigs, eg, newsig.allocl, newsig.numbers);
#endif

    /*  If the signature table is filling up, dump them all out so
     *  someone can figure out why.
     */
    if (nsigs == MAXSIGS) {
	for (type = 0; type < nsigs; type++) {
	    printf("\n\t/* %s */\n", egs[type]);
	    printf("\t");
	    writesig(stdout,type);
	    printf(",\n");
	    }

	cerror("too many allocation signatures!\n");
	}

    for (i = 0; i < nsigs; i++) {
	for (locv = 0; locv < MAXSYMS+MAXKIDS; locv++)
	    if (sigs[i].vec[locv] != newsig.vec[locv])
		goto notme;
	if (sigs[i].reslbd != sigs[i].reslbd ||
	    sigs[i].resubd != sigs[i].resubd ||
	    sigs[i].kidlbd != newsig.kidlbd ||
	    sigs[i].kidubd != newsig.kidubd ||
	    sigs[i].varlbd != newsig.varlbd ||
	    sigs[i].varubd != newsig.varubd ||
	    sigs[i].regtype != newsig.regtype ||
	    sigs[i].allocl != newsig.allocl ||
	    sigs[i].simplers != newsig.simplers ||
	    sigs[i].numbers != newsig.numbers ||
	    sigs[i].type != newsig.type)
	    goto notme;
	return i;
	notme:;
	}

    for (locv = 0; locv < MAXSYMS+MAXKIDS; locv++)
	sigs[nsigs].vec[locv] = newsig.vec[locv];

    sigs[nsigs] = newsig;
    SAFESTRCPY(egs[nsigs], eg);

    return nsigs++;
    }

/*  Install new assembly skeletons.  This only happens in the learning
 *  compiler and the compiler-compiler.  In the learning compiler,
 *  skelptr starts off pointing to the static skelvec area and when the
 *  table needs to grow, it is malloc'ed and copied the first time and
 *  realloc'ed subsequently.
 */
Opcode skinstall(name, newsig)
    char	*name;
    struct Sig newsig;
    {
    Opcode	i;
    int		signod;

    signod = addsig(name, newsig);

#if 0
    for (i = newsig.kidlbd; i < newsig.kidubd; i++) {
	if (newsig.vec[i] == 0) {
	    fprintf(stderr,
	    "/* skinstall WARNING: no allocable regs for kid %%%d in '%s' */\n",
	    i, name);
	    fprintf(stderr,
	    "/* Check consistency of regpatts bit-field values, regnames, and "
	    "%ranges in md file */\n");
	    }
	}

    for (i = newsig.reslbd; i < newsig.resubd; i++) {
	if (newsig.vec[i] == 0) {
	    fprintf(stderr,
	    "/* skinstall WARNING: no allocable regs for result %%%d in '%s' */\n",
	    i, name);
	    fprintf(stderr,
	    "/* Check consistency of regpatts bit-field values, regnames, and "
	    "%ranges in md file */\n");
	    }
	}
#endif

    for (i = 0; i < nskels; i++)
	if (skelptr[i] == name && sigptr[i] == signod)
	    return i;
#if 0
    printf("/* skinstall(%s) in skels[%d] numbers %o signod %d */\n",
	name, nskels, newsig.numbers, signod);
#endif
    if (name != string(name)) {
	fprintf(stderr, "skinstall\n");
	exit(-1);
	}

    growskelvec();
    skelptr[nskels - 1] = name;
    sigptr[nskels - 1] = signod;
    return nskels - 1;
    }

/*  This skeleton should be in skelptr.  Move it to skelptr[n]. */
void skmove(name, n)
    char	*name;
    Opcode	n;
    {
    char	*t;
    int		tsig;
    int		loser;

    Opcode	i;

#if 0
    printf("/* MOVE %s TO %d */\n", name, n);
#endif

    if (name != string(name)) {
	fprintf(stderr, "skmove\n");
	exit(-1);
	}

    while (nskels <= n)
	growskelvec();

    if (!varncmp(name, skelptr[n], strlen(name)))
	return;

    for (loser = 0; loser < nskels; loser++)
	if (!varncmp(skelptr[loser], name, strlen(name))) {
	    t = skelptr[n];
	    skelptr[n] = skelptr[loser];
	    skelptr[loser] = t;

	    tsig = sigptr[n];
	    sigptr[n] = sigptr[loser];
	    sigptr[loser] = tsig;
	    return;
	    }

    printf("/* skmove: WARNING: created skeleton for '%s'. */\n", name);
    printf("/* Code generator will choke on dags containing this opcode. */\n");

    growskelvec();			/* make more room in skelvec */
    skelptr[nskels - 1] = skelptr[n];	/* preserve existing skelptr[n] */
    sigptr[nskels - 1] = sigptr[n];
    skelptr[n] = name;			/* this is new n */
    sigptr[n] = 0;			/* bad signature! */
    }

/*  Grow the skeleton and signature number vectors.
 *  In the learning system, we start out with a static skeleton vector
 *  and we are forced to copy it to an allocated area at the first
 *  growing.
 */
growskelvec()
    {
    if (skelptr == skelvec) {
	if (!(skelptr = (char **)malloc(sizeof(skelptr[0]) * (nskels + 1))))
	    cerror("growskelvec line %d: out of malloc() space", __LINE__);
	memcpy((char *)skelptr, (char *)skelvec, sizeof(skelptr[0]) * nskels);

	if (!(sigptr = (short *)malloc(sizeof(sigptr[0]) * (nskels + 1))))
	    cerror("growskelvec line %d: out of malloc() space", __LINE__);
	memcpy((char *)sigptr, (char *)signature_vector, sizeof(sigptr[0]) * nskels);
	}
    else {
	if (!(skelptr = (char **)realloc((void *)skelptr,
				       sizeof(skelptr[0]) * (nskels + 1))))
	    cerror("growskelvec line %d: out of malloc() space", __LINE__);

	if (!(sigptr = (short *)realloc((void *)sigptr,
				       sizeof(sigptr[0]) * (nskels + 1))))
	    cerror("growskelvec line %d: out of malloc() space", __LINE__);
	skelptr[nskels] = 0;
	sigptr[nskels] = 0;
	}
    nskels++;
    }

/*  Compare two strings ignoring variable number differences		*/
varcmp(s, t)
    char		*s, *t;
    {
    if (!t)
	return !!s;
    if (!s)
	return !!t;

    for (;; s++, t++) {
	if (ISVAR(s) && ISVAR(t)) {
	    s += VARLN - 1;
	    t += VARLN - 1;
	    }
	else if (*s != *t)
	    return 1;
	else if (*s == 0)
	    return 0;
	}
    }

/*  Compare two strings ignoring variable number differences		*/
varncmp(s, t, n)
    char		*s, *t;
    {
    char		*olds = s;
    if (!t)
	return !!s;
    if (!s)
	return !!t;

    for (;; s++, t++) {
	if (ISVAR(s) && ISVAR(t)) {
	    s += VARLN - 1;
	    t += VARLN - 1;
	    }
	else {
	    if (s - olds == n)
		return 0;
	    if (*s != *t)
		return 1;
	    if (*s == 0)
		return 0;
	    }
	}
    }


