/*  As the Mips has > 32 registers, simple 32-bit bitmap operations wont work
 *  anymore and we need to implement the register allocator with
 *  function calls and structures containing arrays of bitmaps.
 *  This header is not currently being used.
 */


#define WORDS 1

/* Find the lowest 1-bit in a 32-bit unsigned long */
#define lowbit(x) ("\377\000\001\032\002\027\033\377\003\
\020\030\036\034\013\377\015\004\007\021\377\031\026\037\
\017\035\012\014\006\377\025\016\011\005\024\010\023\022"\
[(((unsigned long)x) & -((unsigned long)x)) % 37])

#if WORDS==1
typedef unsigned long RegSet;
#define NOT(x) ~(x)
#define AND(x,y) ((x)&(y))
#define OR(x,y) ((x)|(y))
#define LOWBIT(x) lowbit(x)
#define TESTBIT(x,y) ((x) & ((unsigned long)1 << (y)))
#define SETBIT(x,y) ((x) |= ((unsigned long)1 << (y)))
#define CLEARBIT(x,y) ((x) &= ~((unsigned long)1 << (y)))
#define BIT(x) ((unsigned long)1 << (x))
#else
typedef struct { unsigned long v[WORDS]; } RegSet;
#define NOT(x) not(x)
#define OR(x,y) or(x,y)
#define and(x,y) and(x,y)
#define LOWBIT(x) lowbit(x)
#define TESTBIT(x,y) testbit(x,y)
#define SETBIT(x,y) setbit(x,y)
#define CLEARBIT(x,y) clearbit(x,y)
#define BIT(x) bit(x)
#endif
