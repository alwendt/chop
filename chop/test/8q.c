int     up[15];
int     down[15];
int     rows[8];
int     x[8];

queens(c) {
    int     r;

    for (r = 0; r < 8; r++)
	if (rows[r] && up[r - c + 7] && down[r + c]) {
	    rows[r] = up[r - c + 7] = down[r + c] = 0;
	    x[c] = r;
	    if (c == 7) print();
	    else queens(c + 1);
	    rows[r] = up[r - c + 7] = down[r + c] = 1;
	    }
    }

main() {
    int     i;

    for (i = 0; i < 15; i++)
	up[i] = down[i] = 1;
    for (i = 0; i < 8; i = i + 1)
	rows[i] = 1;
    queens(0);
    }

print() {
    int k;

    for (k = 0; k < 8; k++) {
	putchar(32);
	putchar(49 + x[k]);
	}
    putchar(10);
    }
