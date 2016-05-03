/* C compiler: configuration parameters for VAX subset code generator */

/* include config */

/* type metrics: size,alignment,constants */
#define CHAR_METRICS     1,1,0
#define SHORT_METRICS    2,2,0
#define INT_METRICS      4,4,0
#define FLOAT_METRICS    4,4,1
#define DOUBLE_METRICS   8,4,1
#define POINTER_METRICS  4,4,0
#define STRUCT_ALIGN     1

#define LEFT_TO_RIGHT	 /* evaluate args left-to-right */
#define LITTLE_ENDIAN	 /* right-to-left bit fields */
#define JUMP_ON_RETURN	1
/* end config */

/* include Env */
typedef struct {
	unsigned rmask;
	int offset;
} Env;
/* end Env */
/* include Xnode */
typedef struct {
	int id;             /* node id number (omit) */
	unsigned visited:1; /* 1 if dag has been linearized */
	int reg;            /* register number */
	unsigned rmask;     /* unshifted register mask */
	unsigned busy;      /* busy regs */
	Node next;          /* next node on emit list */
#if LEARNING || DEBUG
	char *rt;		/* rt pattern string		*/
	double i_cost;		/* instruction cost		*/
#endif
} Xnode;
/* end Xnode */
/* include Xsymbol */
typedef struct {
	char *name;		/* name for back end */
	int offset;		/* frame offset */
} Xsymbol;
/* end Xsymbol */

/* include defaddress */
dclproto(extern void defaddress,(Symbol))
/* end defaddress */
/* include export */
#define export(p) print(".globl %s\n", (p)->x.name)
#define import(p)
/* end export */
/* include progend */
/* end progend */
/* include space */
dclproto(extern void space,(int))
/* end space */

#define stabblock(a,b,c)
#define stabend(a,b,c,d,e)
#define stabfend(a,b)
#define stabinit(a)
#define stabline(a)
#define stabsym(a)
#define stabtype(a)

#ifdef vax
dclproto(extern double atof,(char *))
#define strtod(a,b) atof(a)
#endif
