extern void _mulu32_64_shift(int, int, int, int *);
extern char *itoa(int i, char *s);

char *ftoa(float f, char *str){
    char *s = str;

    // technically we would need a union for now the compiler allows bitwise operations on floats
    int sign = f & 0x80000000;
    int exp = (f & 0x7f800000) >> 23;
    int man = (f & 0x007fffff)|0x00800000;
    int shift = (127 - exp) + 23;
    int intpart = man >> shift;
    int fracpart = man - (intpart << (shift));
    int fracpartc[2];

    // external 32bitx32bit -> 64 bit and then shift right; stor hi,lo in fracpartc
    _mulu32_64_shift(fracpart,100000,shift,fracpartc);

  
    if(sign != 0) *s++ = '-';
    s = itoa(intpart,s);
    //__halt__();
    *s++ = '.';
    s = itoa(fracpartc[1],s);
    *s = 0;
    return str;
}

