#ifndef BILLBOARD_INCLUDED
#define BILLBOARD_INCLUDED

#include "UnityCG.cginc"

float4 UnityObjectToBillboardPos(float4 vertex) {
    float3 pivot = UnityObjectToViewPos(float3(.0, .0, .0));
    float3 pos = float3(unity_ObjectToWorld[0][0] * vertex.x, unity_ObjectToWorld[1][1] * vertex.y, .0);
    return mul(UNITY_MATRIX_P, float4(pivot + pos, 1));
}

#endif // BILLBOARD_INCLUDED