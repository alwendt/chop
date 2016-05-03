/* This check the basic relational operators */
/* need to do arrays and float and doubles */
void pointers()
{
	char *i=(char *)1,*j=(char *)0;
	if(i>j && i>=j && i-1 >= j && i-1 == j && i!=j && 
	   j<i && j<=i && j+1 <= i && j+1 == i && j!=i)
	{
		unsigned char *k=(unsigned char *)1,*l=(unsigned char *)0;
		if(k>l && k>=l && k-1 >= l && k-1 == l && k!=l && 
		   l<k && l<=k && l+1 <= k && l+1 == k && l!=k)
		{
			printf("char pointers and unsigned char pointers ok\n");
			return;
		}
	}
	printf("char pointers and unsigned char pointers not ok\n");
	exit(1);
}
void longs()
{
	long i=1,j=0;
	if(i>j && i>=j && i-1 >= j && i-1 == j && i!=j && 
	   j<i && j<=i && j+1 <= i && j+1 == i && j!=i)
	{
		unsigned long k=1,l=0;
		if(k>l && k>=l && k-1 >= l && k-1 == l && k!=l && 
		   l<k && l<=k && l+1 <= k && l+1 == k && l!=k)
		{
			printf("longs and unsigned longs ok\n");
			pointers();
			return;
		}
	}
	printf("longs and unsigned longs not ok\n");
	exit(1);
}
void shorts()
{
	short i=1,j=0;
	if(i>j && i>=j && i-1 >= j && i-1 == j && i!=j && 
	   j<i && j<=i && j+1 <= i && j+1 == i && j!=i)
	{
		unsigned short k=1,l=0;
		if(k>l && k>=l && k-1 >= l && k-1 == l && k!=l && 
		   l<k && l<=k && l+1 <= k && l+1 == k && l!=k)
		{
			printf("shorts and unsigned shorts ok\n");
			longs();
			return;
		}
	}
	printf("shorts and unsigned shorts not ok\n");
	exit(1);
}
void chars()
{
	char i=1,j=0;
	if(i>j && i>=j && i-1 >= j && i-1 == j && i!=j && 
	   j<i && j<=i && j+1 <= i && j+1 == i && j!=i)
	{
		unsigned char k=1,l=0;
		if(k>l && k>=l && k-1 >= l && k-1 == l && k!=l && 
		   l<k && l<=k && l+1 <= k && l+1 == k && l!=k)
		{
			printf("chars and unsigned chars ok\n");
			return;
		}
	}
	printf("chars and unsigned chars not ok\n");
	exit(1);
}
main()
{
	int i=1,j=0;
	if(i>j && i>=j && i-1 >= j && i-1 == j && i!=j && 
	   j<i && j<=i && j+1 <= i && j+1 == i && j!=i)
	{
		unsigned int k=1,l=0;
		if(k>l && k>=l && k-1 >= l && k-1 == l && k!=l && 
		   l<k && l<=k && l+1 <= k && l+1 == k && l!=k)
		{
			printf("ints and unsigned ints ok\n");
			chars();
			exit(0);
		}
	}
	printf("ints and unsigned ints not ok\n");
	exit(1);
}
