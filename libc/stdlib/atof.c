int atoi(char *);
char * strchr(char *, char);

float atof(char *str){
    int intpart = atoi(str);
    int sign = intpart < 0;
    if(sign) intpart = -intpart;
    char *point = strchr(str,'.');
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
    // str      = r10
    // intpart  = r9
    // sign     = r8
    // point    = r7
    // shift    = r6
    // fracpart = r5
    // fraction = frame - 4
    
    int shiftup = 0;
    if(intpart != 0){
        while(! (intpart & 0x00800000)){
            intpart <<= 1;
            shiftup++;
        }
        int f  = 0;
        f |= (intpart & 0x007fffff);
        int exp = 127 + (23-shiftup) - shift;
        f |= exp << 23;
        f |= sign ? 0x80000000 : 0;
        return f;
    }
    return 0;
}
