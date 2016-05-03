
fee() { return 1; }
fie() { return 2; }
foo() { return 3; }
fum() { return 4; }

int i,j,k;

main() 
{
for (j = 0;  j < 2; j++) {
    i = foo() + (j ? j + fee() + fie() : k) + fum();
    printf("%d ", i);
    }
printf("\n");
}


