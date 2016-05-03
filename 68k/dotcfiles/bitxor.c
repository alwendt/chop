/* This is to test the different bitwise xor types with constants and with */
/* variables of that type (we use the same variable for ease */
main()
{
	unsigned char c = 25;
	unsigned short s = 932;
	unsigned int i = -10245678;
	unsigned long l = 2823;
	static char a[] = {1,2,3,4,5,6,7};
	char *p= a+5;
	char C= 128;
	short S=117;
	int I=232;
	long L= 2344;
	static int A[] = { 8,9,10,11,12};
	int *P= A+3;

	c ^= 5;
	c ^= c ^ -4254;
	s ^= 15535;
	s ^= s ^ 2346;
	i ^= 42678;
	i ^= i ^ 2345;
	l ^= 893;
	l ^= l ^ -1234;
	a[2] ^= a[4] ^ -21366;
	p[2] ^= p[-1] ^ 262;
	C ^= -157;
	C ^= C ^ -2135;
	S ^= 67;
	S ^= S ^ 4234;
	I ^= -9342;
	I ^= I ^ 74443;
	L ^= -454;
	L ^= L ^ 12356;
	A[1] ^= A[0] ^ 2839;
	P[-1] ^= P[0] ^ 346;
	printf("%d %d %d %d %d %d\n%d %d %d %d %d %d\n",c,s,i,l,a[3],
	       *p,C,S,I,L,A[2],*P);
}
