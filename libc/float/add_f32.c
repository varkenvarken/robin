//  add_f32.c
//  part of a soft-float library/regression test for the robin cpu
//  (c) 2019 Michel Anders
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//  
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//  
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
//  MA 02110-1301, USA.

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

    if(!expa) return b;
    if(!expb) return a;

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
            mana >>= -expc;
            manc = manb - mana;
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
                shift = leadingzeros(manc) - 8;
                manc <<= shift;
                expc -= shift;
            }
        }
    }

    int result = signc | (expc << 23) | (manc & 0x007fffff);

    return result;
}

float _sub_f32_(float a, float b){
    if(b == 0) return a;
    return _add_f32_(a, b^0x80000000); // flip the sign. note that the compiler allows this for floats for now (it treats b as an int, so -b would be something completely different!)
}

