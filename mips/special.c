/*  mips dependent compiler-compiler code */

/*  The Mips has 25 integer registers $2 to $25 and $30 for general use.
 *  $0 is a constant 0.
 *  $1 is reserved for use by the assembler.
 *  $26 and $27 are used by the OS kernel.
 *  $28 is the "global pointer"
 *  $29 is the stack pointer.
 *  $31 is the return address.
 *  
 *  $4 - $7 hold the first 4 parameters to function calls.
 *  These values are not preserved by the callee.
 *
 *  $8 - $15 are temporary values, not preserved by the callee.
 *  $16 - $23 are preserved by the callee.
 *  $24 - $25 are not preserved by the callee.
 *
 *  It has 16 floating registers $f0-$f30 (even numbers only).
 *  Each register can hold a single or double precision value.
 *  $f0 and $f2 hold function results ($f2 used for complex results).
 *  $f4 - $f10 are not preserved by the callee.
 *  $f12 - $f14 hold first two floating args.  Not preserved by callee.
 *  $f16 - $f18 not preserved by callee.
 *  $f20 - $f30 preserved by callee.
 *
 *  There is no explicit frame pointer, instead the assembly language
 *  programmer can supply a .frame directive which establishes the fp
 *  at a constant offset from the sp:  .frame framereg,framesize,returnreg
 *  This means that the sp cannot change inside of a procedure, which
 *  implies that an argument build area must be used.
 */

#include <stdio.h>
#include "c.h"
#include "hop2.h"

/*  legal allocable register names	*/
struct Regpatts regpatts[] = {
/*            rt          assem   many  bit volat width  stride  typename */
    { "r(%00,4)",        "$%00",    25,   0,    0,    1,      1,      "l"},
    { "f(%00,4)",        "$f%00",    4,  25,    0,    1,      1,      "l"},
    { "f(%00,8)",        "$f%00",    4,  25,    0,    1,      1,      "l"},
    { "lo(%00,4)",        "$lo",     1,  29,    1,    1,      1,      "l"},
    { "hi(%00,4)",        "$hi",     1,  30,    1,    1,      1,      "l"},
    { "fcc(%00,1)",       "$fcc",    1,  31,    1,    1,      1,      "b"},
    {"?",		    "?",     0,  32,    0,    1,      1,      "l"},
    };

int NOREG = nelts(regpatts) - 1;

char	regclass[MAX_REGBITS][REGBITS] = 
    {
    "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1\1\1\1\3\4\5",
    "\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\0\1\1\1\1\3\4\5",
    };

char	*regnames[MAX_REGBITS][REGBITS] = {
    {
    "$2",  "$3",  "$4",  "$5",  "$6",  "$7",  "$8", "$9",
    "$10", "$11", "$12", "$13", "$14", "$15", "$16", "$17",
    "$18", "$19", "$20", "$21", "$22", "$23", "$24", "$25",
    "$30", "$f0", "$f2", "$f4", "$f6", "$lo", "$hi", "$fcc"
    },
    {	/* not all wider operands may be useable due to alignment constraints */
    "$2",  "$3",  "$4",  "$5",  "$6",  "$7",  "$8", "$9",
    "$10", "$11", "$12", "$13", "$14", "$15", "$16", "$17",
    "$18", "$19", "$20", "$21", "$22", "$23", "$24", "$25",
    "$30", "$f0", "$f2", "$f4", "$f6", "$lo", "$hi", "$fcc"
    }
    };

char commentstring[] = "#";

