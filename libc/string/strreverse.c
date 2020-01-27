extern int strlen(char *);

void strreverse(char *str){
    char *end = str + strlen(str) - 1;
    while(end > str){
        char c = *end;
        *end-- = *str;
        *str++ = c;
    }
}
