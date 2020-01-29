extern void fie(int *);

void test(){
    int a[2];
    a[0] = a[1];
    fie(a[1]);
}
