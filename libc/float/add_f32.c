char n[16] = { 4,3,2,2,1,1,1,1,0,0,0,0,0,0,0,0 };

int lz8(int a){
    a &= 0xff;
    int c = n[a>>4]; // upper nibble
    if(c == 4) c += n[a&0x0f]; // lower nibble
    return c;
}

int leadingzeros(int a){
    int n       = lz8(a>>24);
    if(n==8 ) n+= lz8(a>>16);
    if(n==16) n+= lz8(a<<8);
    if(n==24) n+= lz8(a);
    return n;
}

float _add_f32_(float a, float b){
    // technically we would need a union for now the compiler allows bitwise operations on floats
    int signa = a & 0x80000000;
    int expa  = (a & 0x7f800000) >> 23;
    int mana  = (a & 0x007fffff);
    
    int signb = b & 0x80000000;
    int expb  = (b & 0x7f800000) >> 23;
    int manb  = (b & 0x007fffff);
    
    int signc = signa ^ signb;
    int expc = expa - expb;
    int manc;

    // TODO zero handling
    mana = mana | 0x00800000;
    manb = manb | 0x00800000;

    if(!signc){ // equal signs
        signc = signa;
        if(expa > expb){
            manb >>= expc;
            manc = mana + manb;
            expc = expa;
        }else if(expa < expb){
            mana >>= -expc;
            manc = mana + manb;
            expc = expb;
        }else{
            manc = mana + manb;
            expc = expa;
        }
        manc >>= 1;
    }else{
        if(expa > expb){
            manb <<= expc;
            manc = mana - manb;
            expc = expa;
            signc = signa;
        }else if(expa < expb){
            mana <<= -expc;
            manc = mana - manb;
            expc = expb;
            signc = signb;
        }else{
            manc = mana - manb;
            expc = expa;
            signc = mana > manb ? signa : signb ;
        }
        if(!manc){
            signc = 0;
            expc = 0;
        }else{
            if(!(manc & 0x00800000)){
                int shift = leadingzeros(manc) - 8;
                manc <<= shift;
                expc -= shift;
            }
        }
    }
    return signc | expc << 23 | (manc & 0x007fffff);
}
