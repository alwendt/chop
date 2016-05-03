/* This is to test the different addition types with constants and with */
/* variables of that type (we use the same variable for ease */
main()
{
	unsigned char c = 25;
	unsigned short s = 932;
	unsigned int i = -10245678;
	unsigned long l = 28253623;
	static char a[] = {1,2,3,4,5,6,7};
	char *p= a+5;
	char C= 123;
	short S=117;
	int I= 45234232;
	long L= 2344;
	static int A[] = { 8,9,10,11,12, 1, 2, 3, 4, 5, 6 };
	int *P= A+1;

	c %= 7;
	c %= c % 8;
	s %= 15535;
	s %= s % 24;
	i %= 468;
	i %= i % 245;
	l %= 83;
	l %= l % 246;
	a[2] %= a[4];
	p[1] %= p[-1] % 3;
	C %= 18;
	C %= C % 2;
	S %= 7;
	S %= S % 4;
	I %= 932;
	I %= I % 63;
	L %= 44;
	L %= L % 23;
	A[1] %= A[0];
	P[-1] %= P[3];
	printf("%d %d %d %d   %d %d\n%d %d %d %d   %d    %d %d\n",
		 c, s, i, l,a[3],*p,  C, S, I, L,A[0], A[1],*P);
}
