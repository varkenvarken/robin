// newton raphson https://en.wikipedia.org/wiki/Division_algorithm#Newton%E2%80%93Raphson_division
// initial guess https://bits.stephan-brumme.com/inverse.html

extern float _mul_f32_(float, float);
extern float _sub_f32_(float, float);

float newton_raphson_inverse(float a, float x){
    return _mul_f32_(x, _sub_f32_(2.0f, _mul_f32_(a,x)));
}

float inverse(float a){
    union { float x; int i; } value;
    value.x = a;
    
    // if zero, return +- Inf
    if((value.i & 0x7f800000) == 0){
        return (value.i & 0x80000000) | 0x7f800000;
    }
    
    // initial guess is a close approximation (<4%)
    value.i = 0x7EEEEEEE - value.i;
    float x = value.x;

    // 4 rounds of newton raphson
    x = newton_raphson_inverse(a, x);
    x = newton_raphson_inverse(a, x);
    x = newton_raphson_inverse(a, x);
    x = newton_raphson_inverse(a, x);

    return x;
}
