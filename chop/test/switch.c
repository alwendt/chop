main()
{
	int i=3;

	switch(i++)
	{
		case 0: i++;
		case 1: i++;
		case 2: i++;
		case 3: i++;
		case 5: i++;
		case 7: i++;
	}
	printf("i is %d\n",i);

	switch(i--)
	{
		case 7: i--;
		case 6: i--;
		case 5: i--;
	}
	printf("i is %d\n",i);

	switch(i++)
	{
		case 2: i++;
		case 3: i++;
	}
	printf("i is %d\n",i);

	switch(100*i--)
	{
		case 0: i--;
		case 100: i--;
		case 200: i--;
		case 300: i--;
		case 400: i--;
		case 500: i--;
	}
	printf("i is %d\n",i);

	switch(i++)
	{
		case 0: i++;
		case 1: i++;
		case 2: i++;
		case 3: i++;
		case 4: i++;
		case 10: i++;
		case 11: i++;
		case 12: i++;
		case 13: i++;
		case 14: i++;
		case 110: i++;
		case 111: i++;
		case 112: i++;
		case 113: i++;
		case 114: i++;
	}
	printf("i is %d\n",i);
	exit(0);
}
