struct fun {
	int i;
	int j;
} a[6];
main()
{
	int i,j=0,k=3;

	i = j ? a[k].j : -a[k].j;
	j = a[k].j;
}
