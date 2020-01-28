int atoi(char *str){
    int sign = 0;
    int n = 0;
    if(*str == '-') { sign=1; str++; }
    while(*str && *str>='0' && *str <= '9'){
        n *= 10;
        n += (*str++)-'0';
    }
    if(sign) n = -n;
    return n;
}
