/*  vax dependent register allocation code */

#include <stdio.h>
#include "c.h"
#include "hop2.h"

	
/*  legal allocable register classes.
 *  1. register class' register transfer name with %00 pattern variable.
 *  2. first bit number in allocation bit vector
 *  3. number of registers in bit vector
 *  4. 1 if volatile (changed by instructions that don't mention it).
 *  5. width in allocation bits
 *  6. stride in allocation bits (2 for even-odd pairs).
 *  7. type name
 *  Currently allocated register bitmasks must fit in unsigned long (32 bits).
 */
struct Regpatts regpatts[] = {
    {"r(%00,4)",               12,  0, 0, 1, 1, "l"},
    {"cc(%00)",                 1, 12, 1, 1, 1, "b"},
    {"r(%00,8)",               12,  0, 0, 2, 1, "d"},
    {"mm(add(%00,fp,l),l,4)",  18, 13, 0, 1, 1, "l"},	/* spill template*/
    { "mm(add(%00,fp,l),l,8)", 18, 13, 0, 2, 1, "d" },	/* 8-byte tmps */
    {"?",		        0, 32, 0, 1, 1, "l"},	/* end of list marker */
    };


/*  Translate from allocation bit number and width-1 to regpatts entry # */
/*	the spill template %00(fp) is the "register of last resort"	*/
char	regclass[MAX_REGBITS][REGBITS] = 
	{
	/* SUPPRESS 442 */
	"\0\0\0\0\0\0\0\0\0\0\0\0\1\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3\3",
	"\2\2\2\2\2\2\2\2\2\2\2\2\1\4\4\4\4\4\4\4\4\4\4\4\4\4\4\4\4\4\4\4"
	};

/*  Get assembly language name from bit number and width-1 */
char	*regnames[MAX_REGBITS][REGBITS] = {
    {
	"r0", "r1", "r2", "r3", "r4", "r5", "r6", "r7", "r8", "r9", "r10", "r11",
	"cc",
	"-8(fp)", "-16(fp)", "-24(fp)", "-32(fp)",
	"-40(fp)", "-48(fp)", "-56(fp)", "-64(fp)",
	"-72(fp)", "-80(fp)", "-88(fp)", "-96(fp)",
	"-100(fp)", "-104(fp)", "-108(fp)", "-112(fp)",
	"-116(fp)", "-120(fp)", "-124(fp)"
    },
    {	/* not all wider operands may be useable due to alignment constraints */
	"r0", "r1", "r2", "r3", "r4", "r5", "r6", "r7", "r8", "r9", "r10", "r11",
	"cc",
	"-8(fp)", "-16(fp)", "-24(fp)", "-32(fp)",
	"-40(fp)", "-48(fp)", "-56(fp)", "-64(fp)",
	"-72(fp)", "-80(fp)", "-88(fp)", "-96(fp)",
	"-100(fp)", "-104(fp)", "-108(fp)", "-112(fp)",
	"-116(fp)", "-120(fp)", "-124(fp)"
    }
    };

int NOREG = nelts(regpatts) - 1;
char commentstring[] = "#";
