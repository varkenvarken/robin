extern void strreverse(char *);

char *itoa(int i, char *s){
    if(i<0){
        *s++ = '-';
        i = -i;
    }
    char *start = s;
    if(i==0){
        *s++ = '0';
    }else{
        while(i>0){
            int d = i%10;
            *s++ = d + '0'; // actually unsigned remainder
            i /= 10;
        }
    }
    *s = 0;
    strreverse(start);
    return s;
}
