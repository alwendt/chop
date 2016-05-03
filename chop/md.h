#define MAXNTS 1009		/* maximum nonterminals */
#define MAXRTS 1500

/*  A state is "complete" when the dot is at the end			*/
struct State {
    int		types;		/* type bits used by semantics		*/
    struct Pn	*pn;		/* production pointer			*/
    struct Toklist *dot;	/* current location in this pn. Points	*/
				/* at next token to scan in the	pn.	*/
				/* If complete, dot == NULL.		*/
    struct State *next;		/* next state in this set of states	*/
    short	init;		/* set # of first state in this seq	*/
				/* the one with the dot at the front	*/
    short	allocl;		/* allocation class */
    char	*look;		/* lookahead token following this rhs	*/
    /* variable constraints		*/
    char	*constraints[MAXGLOBALS+MAXFREENONTERMS];
    union {
	struct State *kid;	/* if we have just scanned a NONTERM    */
				/* this points to the complete state for */
				/* the parse of that nonterminal         */
	char	*var;		/* if we have just scanned a RANGE or    */
				/* VARIABLE, this gives its translation */
	}	vk;
    struct State *left;		/* the state that preceded this one,	*/
				/* which has the dot one token left	*/
    char	*trans;		/* translation of this (complete) state	*/
				/* this field is only applicable if the */
				/* state is complete (dot is at end)    */
    struct State *hashnext;	/* next link on the hash chain		*/
    double	cost;
    char	*adder;		/* names the routine that added this	*/
    } *parse(), *newinst2(), *inst2(), *canonparse();

struct Pn *phi;			/* the root grammar pn	*/
char		*endstring;	/* "$END$"			*/

#define EACHTRANS(p,txt,parser) p = newinst2(((char *)txt), parser); p; p = p->next

extern char *codes[], *sizes[];
char *strcpy(), *subst(), *retrans();
void exit();
extern int maxstate;		/* maximum state reached during rt-parse */

/*  Possible token types that appear on right hand sides */

#define NONTERM	0		/* a grammar variable like Expr	*/
#define	RANGE	1		/* something defined with %range */
#define VARIABLE	2	/* something defined with %term */
#define	TERMINAL	3	/* a literal string of characters */
#define	UNKNOWN	4

/*  Some tokens carry machine datatype information.  For example, the move address
 *  instruction on the Vax is defined as
 *
 *  inst := "mova%t %x,%z", move(x,z,l), deref(l,z)
 *
 *  In this instruction, the types of x and t must match (you shouldn't do a moval
 *  on a byte-indexed array element, because the index register's value will get
 *  multiplied by 4 if you do), and z must be a 32-bit (long) datatype.
 *
 *  To encode this, the code that handles the "deref" designates the token structures
 *  representing x and t as 'input tokens' and the structure representing z as an
 *  'output token'.
 */

#define	TKCLASS_NONE	0	/* this token carries no worthwhile type */
#define TKCLASS_INPUT	1	/* this token carries type of input */
#define TKCLASS_OUTPUT	2	/* this token carries type of output */

/*  A grammar token list.						*/
/*  Productions are mostly token lists, as are first sets.		*/
struct Toklist {
    char	*text;		/* one grammar component		*/
    struct Toklist *next;	/* pointer to next one			*/
    short	tokty;
    short	tkclass;	/* 0 = none, 1 = a token of input type
				 * 2 = a token of output type
				 */
    };


extern struct Pn {		/* a production record		*/
    int		lhn;		/* lhs nonterminal index in nts	*/
    struct Toklist  *rhs[2];	/* assembler and rt		*/
    long	cost;		/* cost of this pn		*/
    unsigned long type_bits;	/* type bits passed to semantic routine */
#if 0
    unsigned long (*semptr)();	/* pointer to semantic routine	*/
#endif
    struct Toklist *symsem;
    int		allocl;		/* allocation class		*/
    char	*range;		/* range ie "0-10"		*/
    struct Pn *next;		/* next pn for this lhs nt	*/
    } *pns[];			/* set of pns for each nt	*/

/*  generate each alternative for a nonterminal given its number	*/
#define EACHALT(ntn,p) p = pns[ntn]; p; p = p->next

/*  generate each token on the left or right side of this production	*/
#define EACHTOK(pn,side,tk) tk = pn->rhs[side]; tk; tk = tk->next

extern struct Toklist defs[];	/* names of ranges, terms, and nonterms	*/
