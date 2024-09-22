# chop



A Retargetable Optimizing Code Generator Generator.  Ph.D. dissertation,
University of Arizona, 1988.

Automatic Generation of Fast Optimizing Code Generators, Proceedings
of the SIGPLAN '88 Conference on Programming Language Design and
Implementation (with C. Fraser).

Fast Code Generation Using Automatically-Generated Decision Trees,
Proceedings of the SIGPLAN '90 Conference on Programming Language Design
and Implementation, SIGPLAN Notices 25, 6 (June 1990), 9-15.

Several recent code generators use dag rewriting rules to accomplish
both code generation and peephole optimization, and they compile these
rules into hard code to generate code quickly. The chop system [S],
for example, runs twice as fast as both pcc and the GNU C compiler gcc
on a Sun 3/50 system and generates comparable code. These figures are
for entire compilers; the code generators themselves run about seven
times faster than comparable code generators.
