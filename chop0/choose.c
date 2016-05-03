/* This function makes a list of subexpresson numbers.
 * If we have subexprs 1,2,3,4 and we want 3 of them, the answer stream
 * returned is: 123, 124, 134, 234
 */
choose(m,n,result,restart)
    int		m;			/* size of set to choose from */
    int		n;			/* # of elements to choose */
    int		result[];		/* vector of n elements	*/
    int		restart;		/* nonzero to restart generator */
    {
    int		i;

    if (restart) {
	if (n > m) return 0;
	for (i = 0; i < n; i++)
	    result[i] = i;
	return 1;
	}

    /*	advance the highest result location that can be advanced */
    for (i = n - 1; i >= 0; i--) {
	if (n - i < m - result[i]) { 
	    result[i]++;
	    for (;i < n - 1; i++)
		result[i + 1] = result[i] + 1;

	    return 1;
	    }
	}

    /*  no location can be advanced */
    return 0;
    }

#if 0
main()
    {
    int		result[100];
    int		m,n;
    int		i;
    int		reset;
    for (;;) {
	scanf("%d %d", &m, &n);
	reset = 1;
	while (choose(m,n,result,reset)) {
	    for (i = 0; i < n; i++) {
		printf("%d ", result[i]);
		}
	    printf("\n");
	    reset = 0;
	    }
	}
    }
#endif
