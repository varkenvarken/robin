// inspired by: https://github.com/ucb-bar/berkeley-softfloat-3/blob/master/source/f32_mul.c

extern void _mulu32_64_shift(int, int, int, int *);

float _mul_f32_(float a, float b){
    // technically we would need a union for now the compiler allows bitwise operations on floats
    int signa = a & 0x80000000;
    int expa  = (a & 0x7f800000) >> 23;
    int mana  = (a & 0x007fffff);
    
    int signb = b & 0x80000000;
    int expb  = (b & 0x7f800000) >> 23;
    int manb  = (b & 0x007fffff);
    
    int signc = signa ^ signb;
    int expc = 0;
    int fracpartc[2];

    if(!expa){
        if(! mana) return 0;
    }
    if(!expb){
        if(! manb) return 0;
    }
    expc = expa + expb - 0x7f;
    mana = mana | 0x00800000;
    manb = manb | 0x00800000;
    // external 32bitx32bit -> 64 bit and then shift right; stor hi,lo in fracpartc
    _mulu32_64_shift(mana,manb,23,fracpartc);
    int manc = fracpartc[1];
    
    //__halt__();

    if(manc >= 0x01000000){
        expc += 1;
        manc >>= 1;
    }
    return signc | expc << 23 | (manc & 0x007fffff);
}
