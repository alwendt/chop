/* Copyright (c) 1991 Alan Wendt.  All rights reserved.
 * You have this code because you wanted it now rather than correct.
 * Bugs abound!  Contact Alan Wendt for a later version or to be
 * placed on the chop mailing list.  Parts are missing due to licensing
 * constraints.
 *
 * Alan Wendt / Computer Science / Colorado State Univ. / Ft Collins CO 80523
 * 303-491-7323.  wendt@cs.colostate.edu
 */

/* hop2.h */

#define int16 short
#define int8 short
#define int32 int
#define unsign8 unsigned short
#define unsign16 unsigned short
#define unsign32 unsigned

char *balloc(), *bmalloc(), *buybuf(), *calloc(), *sbrk();
char *malloc();
#define cerror compilererror
#include "special.h"


#define RPAR ')'
#define LPAR '('
#define RCURLY '}'
#define LCURLY '{'

/*	is the string beginning here a variable?	*/
/* #define ISVAR(s) (((s)[0]) == '%' && isdigit((s)[1]) && isdigit((s)[2])) */
#define ISVAR(s) ((*(char *)(s)) == '%' && isdigit((*((char *)(s)+1))) && isdigit((*((char *)(s)+2))))

/*	which variable is it?					*/
/*	returns value between FIRSTVAR and FIRSTVAR+MAXGLOBALS	*/
#define	VAR(s) ((*((char *)(s)+1)-'0')*10+(*((char *)(s)+2)-'0'))

#define IVAR(ins,i) (*(union Var *)&ins->syms[i])
#define IKID(ins,i) (IVAR((ins),(i)).kid)
#define ISYM(ins,i) (IVAR((ins),(i)).sym)
#define INUM(ins,i) (IVAR((ins),(i)).num)
#define ISTR(p)     ((p)->name)

/*  Get value of CNSTx.
 *  The (int) cast is intentional so movq works on x = (unsigned)-1.
 */
#define UVAL(x) ((int)(x)->u.c.v.u)
#define IVAL(x) ((x)->u.c.v.i)
#define PVAL(x) ((int)(x)->u.c.v.p)
#define CVAL(x) ((int)(x)->u.c.v.sc)
#define SVAL(x) ((int)(x)->u.c.v.ss)

#define OKID(opt,i) (opt)->o_kids[i]
#if SABER
#define ONUM(opt,i) (opt)->o_vars[i].num
#else
#define ONUM(opt,i) (((opt)->o_numbers & (1 << i)) ? (opt)->o_vars[i].num : fprintf(stderr, "ONUM error file %s line %d\n", __FILE__, __LINE__))
#endif
#define SETONUM(opt,i,val) { \
	    if (((opt)->o_numbers & (1 << (i))) == 0) { \
		 (opt)->o_vars[i].sym = intconst(val); \
		 /* \
		 fprintf(stderr, "SETONUM file %s line %d\n", __FILE__, __LINE__); \
		 exit(-1); \
		 */ \
		 } \
	    else (opt)->o_vars[i].num = (val); \
	    }

#define OSYM(opt,i) (opt)->o_vars[i].sym
#define OSTR(opt,i) ((opt)->o_vars[i].sym ? (opt)->o_vars[i].sym->x.name : 0)

#define INSCOST(ins) (ins)->x.i_cost
#define INSRT(ins) (ins)->x.rt
#define INSOP(ins) (ins)->op

/*	stuff a variable number into a string		*/
/*	stuffs a value between FIRSTVAR and FIRSTVAR+MAXGLOBALS */
#define	SETVAR(s,v) { (s)[0]='%';(s)[1]=v/10+'0';(s)[2]=v%10+'0'; }

#define VAREQSTR(s)				\
    (ISVAR(s) &&				\
    (s)[VARLN] == '.' &&			\
    (s)[VARLN+1] == 's' &&			\
    (s)[VARLN+2] == 't' &&			\
    (s)[VARLN+3] == 'r' &&			\
    (s)[VARLN+4] == '=' &&			\
    (s)[VARLN+5] == '=' &&			\
    (s)[VARLN+6] == '"')		/* %01.str=="xyz" */
                       
#define VAREQ(s)				\
    (ISVAR(s) &&				\
    (s)[VARLN] == '.' &&			\
    (s)[VARLN+1] == (s)[VARLN+VARLN+7] &&	\
    (s)[VARLN+2] == (s)[VARLN+VARLN+8] &&	\
    (s)[VARLN+3] == (s)[VARLN+VARLN+9] &&	\
    (s)[VARLN+4] == '=' &&			\
    (s)[VARLN+5] == '=' &&			\
    ISVAR(&(s)[VARLN+6]) &&			\
    (s)[VARLN+VARLN+6] == '.')		/* does s point to %01.xyz==%02.xyz? */
					/*                 0123456789012345  */

#define USE_NUMBERS	0		/* don't store numbers directly into .num fields */

#define MAXINPUTLENGTH	9		/* max length of opt input	*/

#define MAXOPTSIZE	9		/* maximum size of an opt	*/
					/* don't do m->n if m or n is >	*/

#define FIRSTVAR 0			/* first variable's value	*/
#define VARLN    3			/* total length of a variable	*/
#define REQPREFLEN 2			/* strlen(";;") == req prefix len */
#define NOVAR	-1			/* not a variable		*/
#define VARFMT "%%%02d"			/* format a var number		*/
#define MAXGLOBALS 26			/* max # of global vars in opt	*/
#define MAXFREENONTERMS 6		/* max # of nonterm's not on	*/
					/* the other side of an ins	*/

#if LEARNING
#define INSSIZE 30000			/* # of ins records		*/
#else
#define INSSIZE 5000
#endif

#define MAXREQLEN ((MAXGLOBALS+MAXFREENONTERMS)*50)
#define MAXRTLINE (MAXOPTSIZE*80)

#define MAXSIGS 600			/* allocation signatures	*/

#define BOGUS 999999			/* used for intermediate codes	*/
#define NONOPTIMIZABLE 2999999		/* used for special IC's that	*/
					/* should not be combined out	*/
					/* must be > BOGUS * 2		*/

/*      DECREASING = 1 to try longer rules before shorter ones          */
#define DECREASING 1

#define FIRSTKID MAXSYMS	/* # of first input var unless result	*/

#define nelts(x) (sizeof(x) / sizeof((x)[0]))
#define endof(s) (index((s), 0))
#define rootin(Opt) ((Opt)->old + (Opt)->olen - 1)

int	getresultype();		/* get this rt's result type */

extern char **skelptr, *skelvec[];
extern short *sigptr, signature_vector[];
extern unsign16 nskels;

extern int alloclassindex();

#define signo(x) sigptr[x]

/*  Get info from the signature table */

/*  Var number of first kid		*/
#define kidlbn(n)		(sigs[signo(n)].kidlbd)
#define kidlb(ins)		(sigs[signo((ins)->op)].kidlbd)

/*  1 + var # of last kid		*/
#define kidubn(n)		(sigs[signo(n)].kidubd)
#define kidub(ins)		(sigs[signo((ins)->op)].kidubd)

/*  var # of first var		*/
#define varlbn(n)		(sigs[signo(n)].varlbd)
#define varlb(ins)		(sigs[signo((ins)->op)].varlbd)

/*  1 + var # of last var		*/
#define varubn(n)		(sigs[signo(n)].varubd)
#define varub(ins)		(sigs[signo((ins)->op)].varubd)

/*  var # of first result		*/
#define reslbn(n)		(sigs[signo(n)].reslbd)
#define reslb(ins)		(sigs[signo((ins)->op)].reslbd)

/*  1 + var # of last res		*/
#define resubn(n)		(sigs[signo(n)].resubd)
#define resub(ins)		(sigs[signo((ins)->op)].resubd)

/*	result register type		*/
#define rtype(ins)		(sigs[signo((ins)->op)].regtype)

/*  bit vector of usable regs for this var in this instruction	*/
#define sig(ins,var)		(sigs[signo((ins)->op)].vec[var])

/*  allocation class of this instruction */
#define alloclass(ins)          (sigs[signo((ins)->op)].allocl)

/* there is code depending on this being a union!!! */
typedef union Var {
   struct node	*kid;		/* child pointer		*/
   char			*str;	/* value string pointer		*/
   int			num;	/* numeric value                */
   struct symbol	*sym;	/* lcc symbol table entry	*/
   } VARTYPE;

/*  These two are using by the learning system and the rule compiler	*/
struct patrec {
    char		kidno;		/* kid # if any			*/
    char		parent;		/* parent pattern #		*/
                                        /* variable mapping '0'..'?'	*/
    signed char		map[MAXGLOBALS+MAXFREENONTERMS];
    unsign16		signumber;	/* signature number */
    double		cost;		/* cost of this instruction	*/
    char		*assem;
    char		*p_rt;
    char		p_varlb, p_varub, p_kidlb, p_kidub, p_reslb, p_resub;
    };

extern struct patrec	*cvtpatt();

/*  In an optimization record, patterns are stored in the order that they
 *  appear in a rule file, i.e. the root is last, at old[olen - 1].
 *  Removable requirements begin with ;:
 *  Non-removable requirements begin with ;;
 *
 *  The routine genopt in rules.c tries to generalize optimizations by
 *  deleting constraints and determining if the rule still works.
 *  Many constraints that come from instruction parsing and cost determination
 *  are removable because they overly specialize the rule to work with,
 *  e.g., frame offsets in a particular range, when the rule would still be
 *  applicable even if the offsets were larger.
 *  Some constraints (those generated by the simplifier) are not removable
 *  because they are necessary for the optimization to be valid.  For example,
 *  a simplifier-imposed constraint might insist that some field is a power
 *  of 2.
 *  Canopt also makes a constraint non-removable when it sees a constraint
 *  like %01.num==%02.num and renumbers %02's on the output side to %01's.
 *  In this case, the constraint must not be removed by genopt because it will
 *  cause us to generate addl2's when we should generate addl3's.
 */
extern struct Optrec {
    double		ncost;		/* output side cost		*/
    double		o_ocost;	/* input side cost		*/
    long		o_optno;	/* optimization sequence #	*/
    int			o_lineno;	/* line # of file where this */
					/* opt was discovered by comb */
    char		o_file[9];	/* file where this opt was found */
    long		o_varsused;	/* bit vector of vars in use   */
    struct patrec	old[MAXOPTSIZE], new[MAXOPTSIZE];
    char		olen, nlen;	/* input & output side lengths */
    union {
       char		*str;		/* value string pointer		*/
       int		num;		/* numeric value                */
       struct symbol	*sym;
       } 		o_vars[MAXGLOBALS];
    struct node	*o_kids[MAXGLOBALS];

    /*  Count number of remaining references to innocent bystanders
     *  within this optimization, so that a global variable number
     *  that should represent a pointer to an innocent bystander does
     *  not get re-used as an intermediate result in a multi-output rule.
     */
    short		o_refct[MAXGLOBALS];	/* remaining refs to kids */

    char		o_reqs[MAXREQLEN];	/* requirements		*/

    char		implied[MAXREQLEN];	/* implied by checking */
						/* assem patterns; need	*/
						/* not be checked	*/
						/* explicitly.		*/
    unsign32		o_numbers;	/* which vars are numbers?	*/
    } *opttbl[];

#define MAXCONSTRAINTLEN 50

struct Constraint {
    char	text[MAXCONSTRAINTLEN];	/* e.g. ";:atoi(%05.str)<=42" */
    short	ty;			/* [ = constant lower bound */
					/* ] == upper */
					/* = = equality to a constant */
					/* % = equality to a variable */
					/* ? = unrecognizeable constraint */
    long	vbound;			/* 42 */
    char	v0[VARLN + 5];		/* "atoi(%05.str)" */
    char	v1[VARLN + 5];		/* 42 */
    };

extern struct Regpatts {
    char	*rt;			/* syntax			*/
    char	many;			/* how many regs of this type	*/
    short	bitorg;			/* first bit # in alloc vec	*/
    char	volat;			/* volatile; don't make cses	*/
    char	width;			/* width in "allocation atoms"	*/
    char	stride;			/* Usually 1 or 2		*/
					/* 1 if r0-r1 and r1-r2 are legal pairs */
					/* 2 if pairs must be even-odd	*/
    char        *typename;              /* "b" "w" "l" or somesuch      */
    } regpatts[];

extern struct Sig {			/* allocation signatures	*/
    int		reslbd;
    int		resubd;
    int		kidlbd;			/* first kid number		*/
    int		kidubd;			/* 1+last kid number		*/
    int		varlbd;
    int		varubd;
    int		regtype;		/* result type			*/
    int		simplers;		/* -1 if a reg->reg move	*/
					/* 0 otherwise			*/
					/* used to kill movl rx,rx	*/
    unsign32	numbers;		/* which vars are numbers?	*/
    int		allocl;			/* allocation class		*/
    unsign32	vec[MAXSYMS+MAXKIDS];	/* legal register # bit masks	*/
    int		type;
    } sigs[];

extern char		*fmatch();	/* search first str for second	*/
extern char		*shorten();
extern char		*inam();	/* C name of kid pointer	*/
extern char		*sub();		/* substitute one str for other	*/
extern char		*strcat(), *strcpy(), *index();
extern char		*gtds();	/* get dest and src of rt	*/
extern int		musteq();	/* two vars must be equal?	*/
extern int		lineno;
extern char		*rindex();
extern char		*addcon();
extern char		abbrkid[];
extern short		moveops[];	/* reg->reg move opcodes	*/
					/* (actually a 2D array)	*/

extern char             commentstring[];
extern char		regclass[MAX_REGBITS][REGBITS];		/* register classes	*/
extern char		*regnames[MAX_REGBITS][REGBITS];	/* register names	*/

extern int		NOREG;		/* code for "not a register"	*/
extern int		doing_onesies;
extern struct node null_insrec;		/* to initialize		*/

extern int		delta[];	/* change in count of reg(%i)	*/


extern char	*addreq();	/* add constraint to an opt rec	*/
extern char	*lastreq();	/* point to last req in a buffer of them */
extern char	*nextreq();	/* point to next req in this buffer */
extern char	*unionreq();	/* get union of constraints	*/
unsign16 addsig();	/* add an allocation signature */
extern Opcode skinstall();	/* install opcode	*/
extern char	*opname();	/* get assembly code string given #	*/
extern char	*id_map;
char		*gtds(), *assem(), *bound();
extern struct Constraint parsecon();	/* text to Constraint struct */

extern char	regct[];		/* registers used by icode op	*/
extern char	arity[];
extern char	*unquote();
extern char	*deback();
extern char	*conback();

extern char otypes[];
extern char patterns[], *patp;

extern char	egs[MAXSIGS][MAXRTLINE];/* examples			*/
extern int	nsigs;			/* # of sigs			*/

extern char		*bpos, *epos;	/* begin & end of match		*/

extern FILE *asmout, *patout;

char *installstr();

void bcopy(),bzero();

extern struct node *nextins;
extern struct node inslist[];
extern struct node *contents[];		/* current register contents */

struct node *elook();			/* look for common sub	*/
extern void opt();
extern int comb();
extern int varcmp();		/* compare 2 strings ignore var #'s */

extern int lernflg;		/* emit learning compiler w comb calls	*/
extern int cseflg;		/* generate tests for cses		*/
extern int debflg;		/* make chop1 debuggable		*/
int getvar();
char	*isvar();


extern char		*terminals[];

extern char		*Remap[];

extern long int strtol(const char *, char **, int);

#define CSE 1
#if CSE
#define CSESIZE 256
extern char             doomed[CSESIZE];	/* will be zapped at dawn */
extern struct node	*exprs[CSESIZE];	/* exprs on file	*/
extern struct node	*elook();		/* look up a cs		*/
extern struct node	**nextexpr;		/* next cse cache slot	*/
#endif

extern void writeopt();
extern struct Optrec *readopt();

extern void exit();
char	*quote();		/* add quotes & escapes to a string	*/
struct node *emitdag();
extern unsign32 bittrans();
struct node **hisp, **lowisp;
double floor();

/* Find the lowest 1-bit in a 32-bit unsigned long */
#define lowbit(x) ("\377\000\001\032\002\027\033\377\003\
\020\030\036\034\013\377\015\004\007\021\377\031\026\037\
\017\035\012\014\006\377\025\016\011\005\024\010\023\022"\
[(((unsigned long)x) & -((unsigned long)x)) % 37])

extern int funclabel;
#define get(ty) (ty *)(calloc(sizeof(ty),1))

extern int rewct[2][MAXOPTSIZE + 1][MAXOPTSIZE + 1];	/* rewrite stats */

#define min(a,b) ((a < b) ? a : b)

#define SAFESTRCAT(dest, src) \
    { \
    if (strlen(src) + strlen(dest) > sizeof(dest) - 1) \
    cerror("file %s line %d: string '%s' too long\n",\
	__FILE__, __LINE__, src); \
    else \
    strcat(dest,src); \
    }

#define SAFESTRCPY(dest, src) \
    { \
    if (strlen(src) > sizeof(dest) - 1) \
    cerror("file %s line %d: string '%s' too long\n",\
	__FILE__, __LINE__, src); \
    else \
    strcpy(dest,src); \
    }

#define SAFESTRNCPY(dest, src, len) \
    { \
    if (len > sizeof(dest) - 1) \
    cerror("file %s line %d: len %d too long\n",\
	__FILE__, __LINE__, len); \
    else \
    strncpy(dest,src,len); \
    }

#if LEARNING
#define getins(x, opcode) { (x) = nextins++; \
			*(x) = null_insrec; \
			INSCOST(x) = BOGUS;\
			(x)->count = 1;\
			INSOP(x) =(opcode); }
#else !LEARNING
#define getins(x, opcode) { (x) = nextins++; \
			(x)->result = NULL;\
			(x)->count = 1;\
			INSOP(x) =(opcode); }
#endif

extern struct node *globr;	/* global instruction tree ptr	 */

/*  If the optimization requires that the use count is less than 10, cchop
 *  will emit a comparison.  But it is pointless to compare the use count
 *  with, for example, 250.  This is the limit.
 */
#define ABSURD_USECT 100


char *rnames();
#define sets(p) ((p)->x.rmask<<(p)->x.reg)

extern char *nums[128];
#define asmoptype(op) (((op)<MAXOP)?((op)&15):(sigs[signo(op)].type))


