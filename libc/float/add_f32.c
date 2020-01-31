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
    if(n==16) n+= lz8(a>>8);
    if(n==24) n+= lz8(a);
    return n;
}

extern void print(char *);
extern void ftoa(float f, char *str);
extern float itoa(int n, char *str);

char buffer[64];

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

    int shift;

    ftoa(a,buffer);
    print(buffer);
    print("    ");
    ftoa(b,buffer);
    print(buffer);
    print("\n");

    // TODO zero handling
    mana = mana | 0x00800000;
    manb = manb | 0x00800000;

    if(!signc){ // equal signs
        signc = signa;
        if(expa > expb){
            manb >>= expc;
            expc = expa;
        }else if(expa < expb){
            mana >>= -expc;
            expc = expb;
        }else{
            expc = expa;
        }
        manc = mana + manb;
        shift = 8 - leadingzeros(manc);

        if(shift) manc >>= shift; // work around bug in cpu: cannot right shift by 0
        expc += shift;
    }else{
        if(expa > expb){
            manb >>= expc;
            manc = mana - manb;
            expc = expa;
            signc = signa;
        }else if(expa < expb){
            itoa(mana,buffer);
            print(buffer);
            print("  ");
            
            mana >>= -expc;
            manc = manb - mana;
            expc = expb;
            signc = signb;
            
            itoa(mana,buffer);
            print(buffer);
            print("  ");
            itoa(manb,buffer);
            print(buffer);
            print("  ");
            itoa(manc,buffer);
            print(buffer);
            print("\n");
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
                shift = leadingzeros(manc) - 8;
                manc <<= shift;
                expc -= shift;
            }
        }
    }
    int result = signc | (expc << 23) | (manc & 0x007fffff);

    ftoa(result,buffer);
    print(buffer);
    print("\n");

    return result;
}
