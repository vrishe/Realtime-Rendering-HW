#ifndef SPACE_INCLUDED
#define SPACE_INCLUDED

#include "util.cginc"

float2 HexGrid(float2 st) {
    st.y *= 0.5773502691;

    float2 a = floor(st);
    float x = xor(mod(a, 2.0));

    float2 l = float2(0.33333, (1.0 - 2.0*x));
    float w = float(dot(l, frac(st) - .5) > 0.0);

    st = a + float2(w, xor(x, w));
    st.y *= 1.7320508078;

    return st;
}

//float2 hex_b(float2 st) {
//    st.x *= 0.5773502691;
//
//    float2 a = floor(st);
//    float x = xor(mod(a, 2.0));
//
//    float2 l = float2((1.0 - 2.0*x), 0.33333);
//    float w = float(dot(l, frac(st) - .5) > 0.0);
//
//    st = a + float2(xor(float2(x, w)), w);
//    st.x /= 0.5773502691;
//
//    return st;
//}

#endif // SPACE_INCLUDED