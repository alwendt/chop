#include <stdio.h>

long strtol(str, ptr, base)
    char	*str, **ptr;
    int		base;
    {
    int		sign = 0, next;
    register	char *p = str;
    long	result = 0;

    for (;; p++) {
	if (*p == '-') {
	    sign = 1;
	    p++;
	    break;
	    }
	else if (*p != ' ') break;
	}

    for (;; p++) {
	next = *p;
	if ('0' <= next && next <= '9') {
	    if (next - '0' < base)
		result = result * base - (next - '0');
	    else break;
	    }

	else if ('a' <= next && next <= 'z') {
	    if (base > 10 && next < base - 10 + 'a')
		result = result * base - (next + 10 - 'a');
	    else break;
	    }

	else if ('A' <= next && next <= 'Z') {
	    if (base > 10 && next < base - 10 + 'A')
		result = result * base - (next + 10 - 'A');
	    else break;
	    }

	else break;
	}

    *ptr = p;
    return (sign) ? result : -result;
    }

/*
main(argc, argv)
    char	*argv[];
    {
    int		base;
    char	bf[100];
    char	*p;

    base = (argc == 1) ? 10 : atoi(argv[1]);
    while (gets(bf)) {
	printf("%ld\n", strtol(bf, &p, base));
	printf("'%.*s'\n", p - bf, bf);
	}
    }
*/
