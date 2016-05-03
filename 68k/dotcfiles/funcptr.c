/* we need to add some funky ones to this */
char *hello()
{
	return "hello";
}

int *hi()
{
	static int i=7783;
	return &i;
}

main()
{
	char *(*p)();

	p = (char *(*)()) hi;
	printf("%d\n",*(int *)(*p)());
	p = hello;
	printf("%s\n",(*p)());
}
