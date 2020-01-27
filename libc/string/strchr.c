char *strchr(char *str, char c){
    while(*str){
        if(*str == c) return str;
        str++;
    }
    return 0;
}
