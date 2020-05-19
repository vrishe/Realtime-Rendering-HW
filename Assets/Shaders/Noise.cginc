#ifndef NOISE_INCLUDED
#define NOISE_INCLUDED

#include "util.cginc"

float WhiteNoise(float2 st) {
    return lerp(-1, 1, random2(floor(st),
        float4(127.1f, 311.7f, 269.5f, 183.3f)));
}

float CellularNoise(float2 st) {
    float2 i = floor(st);
    float2 f = frac(st);

    float4 seed = float4(127.1f, 311.7f, 269.5f, 183.3f);

    float d = 1.;  // minimun distance
    for (float y = -1; y <= 1; y++) {
        for (float x = -1; x <= 1; x++) {
            // Neighbor place in the grid
            float2 neighbor = float2(x, y);
            float2 p = random2(i + neighbor, seed);

            d = min(d, length(neighbor + p - f));
        }
    }

    return d;
}

float GradientNoise(in float2 p)
{
    float2 i = floor(p);
    float2 f = frac(p);

    float2 u = f*f * (3-2*f);

    return lerp(
        lerp(dot(hash(i + float2(0, 0)), f - float2(0, 0)),
            dot(hash(i + float2(1, 0)), f - float2(1, 0)), u.x),
        lerp(dot(hash(i + float2(0, 1)), f - float2(0, 1)),
            dot(hash(i + float2(1, 1)), f - float2(1, 1)), u.x),
        u.y);
}

//
// Description : GLSL 2D simplex noise function
//      Author : Ian McEwan, Ashima Arts
//  Maintainer : ijm
//     Lastmod : 20110822 (ijm)
//     License :
//  Copyright (C) 2011 Ashima Arts. All rights reserved.
//  Distributed under the MIT License. See LICENSE file.
//  https://github.com/ashima/webgl-noise
//
float SimplexNoise(float2 v) {

    // Precompute values for skewed triangular grid
    const float4 C = float4(
        0.211324865405187,   // (3.0-sqrt(3.0))/6.0
        0.366025403784439,   // 0.5*(sqrt(3.0)-1.0)
       -0.577350269189626,   // -1.0 + 2.0 * C.x
        0.024390243902439    // 1.0 / 41.0
    );

    // First corner (x0)
    float2 i = floor(v + dot(v, C.yy));
    float2 x0 = v - i + dot(i, C.xx);

    // Other two corners (x1, x2)
    float2 i1 = (x0.x > x0.y) ?
        float2(1.0, 0.0) : float2(0.0, 1.0);
    float2 x1 = x0.xy + C.xx - i1;
    float2 x2 = x0.xy + C.zz;

    // Do some permutations to avoid
    // truncation effects in permutation
    i = mod289(i);
    float3 p = permute(
        permute(i.y + float3(0.0, i1.y, 1.0))
        + i.x + float3(0.0, i1.x, 1.0));

    float3 m = max(0.5 - float3(
        dot(x0, x0),
        dot(x1, x1),
        dot(x2, x2)
    ), 0.0);

    m = m * m;
    m = m * m;

    // Gradients:
    //  41 pts uniformly over a line, mapped onto a diamond
    //  The ring size 17*17 = 289 is close to a multiple
    //      of 41 (41*7 = 287)

    float3 x = 2.0 * frac(p * C.www) - 1.0;
    float3 h = abs(x) - 0.5;
    float3 ox = floor(x + 0.5);
    float3 a0 = x - ox;

    // Normalise gradients implicitly by scaling m
    // Approximation of: m *= inversesqrt(a0*a0 + h*h);
    m *= 1.79284291400159 - 0.85373472095314 * (a0*a0 + h * h);

    // Compute final noise value at P
    float3 g = float3(0, 0, 0);
    g.x = a0.x  * x0.x + h.x  * x0.y;
    g.yz = a0.yz * float2(x1.x, x2.x) + h.yz * float2(x1.y, x2.y);
    return 130.0 * dot(m, g);
}

#endif // NOISE_INCLUDED