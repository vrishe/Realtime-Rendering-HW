#ifndef UTIL_INCLUDED
#define UTIL_INCLUDED

#define TEX_DECL(name)             \
    sampler2D _##name##Tex;        \
    float4 _##name##Tex_ST

#define MAP_DECL(name)             \
    sampler2D _##name##Map;        \
    float3 _##name##Map_TexelSize

#define UV_DECL(name, n)           \
    float2 uv##name : TEXCOORD##n;

float2 hash(float2 x) { // replace this with something better
    const float2 k = float2(0.3183099, 0.3678794);

    x = (x + 1) * k;
    return 2 * frac(16 * k*frac(x.x*x.y * (x.x + x.y))) - 1;
}

float2 mod(float2 a, float b) {
    return a - b * floor(a / b);
}

float3 mod289(float3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
float2 mod289(float2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }

float3 permute(float3 x) { return mod289(((x*34.0) + 1.0)*x); }

#define RANDOM_SEED 43758.5453123f

float random(float2 st, float2 v) { 
    return frac(sin(dot(st.xy, v)) * RANDOM_SEED);
}

float2 random2(float2 st, float4 v) {
    return frac(sin(float2(
        dot(st, v.xy), dot(st, v.zw)))
        * RANDOM_SEED);
}

float thresh(float a, float x) {
    return x * (x >= a);
}

float2 thresh(float a, float2 x) {
    return x * (x >= a);
}

float3 thresh(float a, float3 x) {
    return x * (x >= a);
}

float xor(float2 v) {
    return v.x + v.y - 2.0*v.x*v.y;
}

float xor(float x, float y) {
    return x + y - 2.0*x*y;
}

#endif // UTIL_INCLUDED