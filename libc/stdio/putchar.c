
int putchar(int c){
    char *out = 0x100;
    *out = c;
    return c;
}
