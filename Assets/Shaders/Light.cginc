#ifndef LIGHT_INCLUDED
#define LIGHT_INCLUDED

#include "AutoLight.cginc"
#include "UnityCG.cginc"
#include "UnityPBSLighting.cginc"

#if defined(VERTEXLIGHT_ON)

#define VXL_FieldName_ vLightColor_
#define VERTEXLIGHT_COLOR(idx) float3 VXL_FieldName_ : TEXCOORD##idx;
#define VERTEXLIGHT_EXTRACT_COLOR(i) (i.VXL_FieldName_)
#define VERTEXLIGHT_TRANSFER_COLOR(dst, wp, n)               \
dst.VXL_FieldName_ = Shade4PointLights(                      \
    unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0, \
    unity_LightColor[0].rgb, unity_LightColor[1].rgb,        \
    unity_LightColor[2].rgb, unity_LightColor[3].rgb,        \
    unity_4LightAtten0, wp, n)

#else

#define VXL_FieldName_
#define VERTEXLIGHT_COLOR(idx)
#define VERTEXLIGHT_EXTRACT_COLOR(i) (.0)
#define VERTEXLIGHT_TRANSFER_COLOR(dst, wp, n)

#endif // defined(VERTEXLIGHT_ON)

void CalculateGI(float3 worldPos, float3 normal, inout UnityGI gi) {
    UNITY_LIGHT_ATTENUATION(attenuation, 0, worldPos);

    float3 lightDir = normalize(_WorldSpaceLightPos0.xyz
        - _WorldSpaceLightPos0.w * worldPos);

    gi.light.dir = lightDir;
    gi.light.color = _LightColor0.rgb * attenuation;
    gi.light.ndotl = DotClamped(normal, lightDir);

#if defined(UNITY_PASS_FORWARDBASE)
    gi.indirect.diffuse += max(ShadeSH9(float4(normal, 1)), .0);
#endif
}

struct LightParams {
    float gloss, metal;

    float3 normal, eyeDir;
};

half4 ApplyFragmentLight(LightParams params, UnityGI gi, float3 albedo, half alpha = 1.) {
    float3 specularTint;
    float oneMinusReflectivity;
    albedo = DiffuseAndSpecularFromMetallic(albedo,
        params.metal, specularTint, oneMinusReflectivity);

    albedo = PreMultiplyAlpha(albedo, alpha, oneMinusReflectivity, alpha);

    half4 col = UNITY_BRDF_PBS(albedo,
        specularTint, oneMinusReflectivity,
        params.gloss, params.normal, params.eyeDir,
        gi.light, gi.indirect);

    col.a = alpha;

    return col;
}

float3 ApplyBumpHeightMap(sampler2D heightMap, float2 texelSize, float2 uv, float2 scale = float2(1., 1.)) {
    float3 d = float3(.5 * texelSize.x, .5 * texelSize.y, .0);

    float u1 = tex2D(heightMap, uv - d.xz);
    float v1 = tex2D(heightMap, uv - d.zy);
    float u2 = tex2D(heightMap, uv + d.xz);
    float v2 = tex2D(heightMap, uv + d.zy);

    return float3(scale.x*(u1-u2), scale.x*scale.y, scale.y*(v1-v2));
}

#endif // LIGHT_INCLUDED