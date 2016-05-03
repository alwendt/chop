/*  80286 dependent compiler-compiler code */

/*  The 286 has 8 8-bit registers:
 *  al, cl, dl, bl, ah, ch, dh, and bh.
 *  It has 7 more or less general purpose registers:
 *  ax, dx, cx, bx, bp, sp, si, and di.  bp is used as the frame pointer.
 *  sp is the stack pointer.
 *  The ax/dx pair is used as a 32-bit destination for some instructions (cwd).
 *  sp is the stack pointer.
 *  It has a condition code.
 *
 *  Because bytes of registers have names (eg "al"), the regnames matrix is set
 *  up to allocate at the byte level.
 */

#include <stdio.h>
#include "c.h"
#include "hop2.h"

/*  legal allocable register names	*/
struct Regpatts regpatts[] = {
/*            rt          assem   many  bit volat width  stride  typename */
    { "r(%00,1)",        "%00",      7,   0,    0,    1,      1,      "b"},
    { "r(%00,2)",        "%00",     12,   0,    0,    1,      2,      "w"},
    { "r(%00,4)",        "%00",     12,   0,    0,    1,      2,      "l"},
    { "f(%00,4)",        "$f%00",    4,  25,    0,    1,      1,      "f"},
    { "f(%00,8)",        "$f%00",    4,  25,    0,    1,      1,      "d"},
    { "cc(%00,1)",        "cc",    1,  31,    1,    1,      1,        "b"},
    {"?",		    "?",     0,  32,    0,    1,      1,      "l"},
    };

int NOREG = nelts(regpatts) - 1;

char	regclass[MAX_REGBITS][REGBITS] = 
    {
    "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1\1\1\1\3\4\5",	/* 1 byte */
    "\1\1\1\1\1\1\1\1\1\1\1\1\0\0\0\0\0\0\0\0\0\0\0\0\0\1\1\1\1\3\4\5", /* 2 byte */
    "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1\1\1\1\3\4\5", /* 4 byte */
    "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1\1\1\1\3\4\5", /* 8 byte */
    };

/*  The following will allow allocation of AXDX, DXBX, BXCX, CXSI, etc. */
char	*regnames[MAX_REGBITS][REGBITS] = {
    {
     "al",     "ah",     "dl",     "dh",     "bl",     "bh",     "cl",     "ch",
       0,        0,        0,        0,  "[bp-4]", "[bp-5]", "[bp-6]", "[bp-7]",
 "[bp-8]", "[bp-9]","[bp-10]","[bp-11]","[bp-12]","[bp-13]","[bp-14]","[bp-15]",
"[bp-16]","[bp-17]","[bp-18]","[bp-19]","[bp-20]","[bp-21]","[bp-22]","[bp-23]"
    }
    {
     "ax",     "ax",     "dx",     "dx",     "bx",     "bx",     "cx",     "cx",
     "si",     "si",     "di",     "di", "[bp-4]", "[bp-5]", "[bp-6]", "[bp-7]",
 "[bp-8]", "[bp-9]","[bp-10]","[bp-11]","[bp-12]","[bp-13]","[bp-14]","[bp-15]",
"[bp-16]","[bp-17]","[bp-18]","[bp-19]","[bp-20]","[bp-21]","[bp-22]","[bp-23]"
    }
    {
     "ax",     "ax",     "dx",     "dx",     "bx",     "bx",     "cx",     "cx",
     "si",     "si",     "di",     "di", "[bp-4]", "[bp-5]", "[bp-6]", "[bp-7]",
 "[bp-8]", "[bp-9]","[bp-10]","[bp-11]","[bp-12]","[bp-13]","[bp-14]","[bp-15]",
"[bp-16]","[bp-17]","[bp-18]","[bp-19]","[bp-20]","[bp-21]","[bp-22]","[bp-23]"
    }
    {
     "ax",     "ax",     "dx",     "dx",     "bx",     "bx",     "cx",     "cx",
     "si",     "si",     "di",     "di", "[bp-4]", "[bp-5]", "[bp-6]", "[bp-7]",
 "[bp-8]", "[bp-9]","[bp-10]","[bp-11]","[bp-12]","[bp-13]","[bp-14]","[bp-15]",
"[bp-16]","[bp-17]","[bp-18]","[bp-19]","[bp-20]","[bp-21]","[bp-22]","[bp-23]"
    }
    };

char commentstring[] = "#";

