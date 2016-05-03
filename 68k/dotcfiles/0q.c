int     up[15];
int     down[15];
int     rows[8];
int     x[8];

queens(c) {
    int     r=0;
    rows[r] = down[r + c] = up[r - c + 7] =  3;
    }

main()
{
	queens(1);
	printf("%d %d\n",rows[0],down[0]);
}
