extern int putchar(int c);

void wait(int n){
    while(n>0) n--;
}

void print(char *s){
    while(*s){
        putchar(*s++);
        wait(1000);
    }
}
