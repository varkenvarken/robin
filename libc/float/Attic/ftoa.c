#include <stdio.h>
#include <string.h>

void strreverse(char *str){
    char *end = str + strlen(str) - 1;
    while(end > str){
        char c = *end;
        *end-- = *str;
        *str++ = c;
    }
}

char *myitoa(int i, char *str){
    char *s = str;
    if(i<=0){
        *str++ = '0';
    }else{
        while(i>0){
            int d = i%10;
            *str++ = d + '0'; // actually unsigned remainder
            i /= 10;
        }
    }
    *str = 0;
    strreverse(s);
    return str;
}

int myatoi(char *str){
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

char *myftoa(float f, char *str){
    char *s = str;
    union { // we do not use bitfields
        float f;
        unsigned int i;
        unsigned char c[4];
    } v;
    v.f = f;
    
    int sign = v.c[3] & 0x80;
    int exp = ((v.c[3] & 0x7f) << 1) + (v.c[2] >= 0x80);
    int man = (((v.c[2] & 0x7f) + 0x80) << 16) + (v.c[1]<<8) + v.c[0];
    int shift = (127 - exp) + 23;
    int intpart = man >> shift;
    int fracpart = man - (intpart << (shift));
    long long fracpartc = (long long)fracpart * 100000;
    fracpartc >>= shift;
    printf("hex: %08x [%02x %02x %02x %02x] sign:%d exp:%d man:%08x int:%08x frac:%08x %llx\n",v.i, v.c[0], v.c[1], v.c[2], v.c[3], sign, exp, man, intpart, fracpart, fracpartc);
    
    
    if(sign != 0) *s++ = '-';
    s = myitoa(intpart,s);
    *s++ = '.';
    s = myitoa(fracpartc,s);
    *s = 0;
    return str;
}

char *mystrchr(char *str, char c){
    while(*str){
        if(*str == c) return str;
        str++;
    }
    return 0;
}

float myatof(char *str){
    union { // we do not use bitfields
        float f;
        unsigned int i;
        unsigned char c[4];
    } v;
    int intpart = myatoi(str);
    int sign = intpart < 0;
    if(sign) intpart = -intpart;
    char *point = mystrchr(str,'.');
    int shift = 0;
    if(point){
        point++;
        int fracpart = 0;
        int fraction = 5;
        while(intpart<1000000000 && shift < 20 && *point){
            fracpart *= 10;
            fracpart += (*point++) - '0';
            intpart <<= 1;
            shift++;
            if(fracpart >= fraction){
                fracpart -= fraction;
                intpart++;
            }
            fraction *= 5;
        }
    }
    int shiftup = 0;
    if(intpart != 0){
        while(! (intpart & 0x00800000)){
            intpart <<= 1;
            shiftup++;
        }
        v.c[3] = sign ? 0x80 : 0;  // little endian!
        v.c[2] = (intpart & 0x007f0000) >> 16;
        v.c[1] = (intpart & 0x0000ff00) >> 8;
        v.c[0] = intpart & 0x000000ff;
        int exp = 127 + (23-shiftup) - shift;
        v.c[3] |= exp >> 1;
        if(exp &1) v.c[2] |= 0x80;
    }else{
        v.c[0] = 0; v.c[1] = 0; v.c[2] = 0; v.c[3] = 0;
    }
    printf("%02x %02x %02x %02x  shiftup:%d intpart:%d\n",v.c[0],v.c[1],v.c[2],v.c[3],shiftup,intpart);
    return v.f;
}

double atof(const char *);

int main(int argc, char**argv){
    char str[100];
    float v = atof(argv[1]);
    printf("in : %f\n", v);
    printf("out: %s\n",myftoa(v, str));
    printf("in : %s\n",str);
    printf("myf: %f\n",myatof(str));
}
