#include <stdio.h>
#include <stdlib.h>

float inverse(float a){
    // initial guess https://bits.stephan-brumme.com/inverse.html
    float x = a;
    unsigned int *i = (unsigned int*)&x;
    *i = 0x7EEEEEEE - *i;
    
    // 2 or 3 rounds of newton raphson https://en.wikipedia.org/wiki/Division_algorithm#Newton%E2%80%93Raphson_division
    // 3 are needed to keep the accuracy ok for the interval [0.5-1.5]
    x = x * ( 2.0f - a * x); // iteration 1
    x = x * ( 2.0f - a * x); // iteration 2
    x = x * ( 2.0f - a * x); // iteration 3
    return x;
}

int main(int argc, char **argv){
    float number = atof(argv[1]);
    printf("1/%g = %g (ref %g)\n", number, inverse(number), 1.0f/number);
}

