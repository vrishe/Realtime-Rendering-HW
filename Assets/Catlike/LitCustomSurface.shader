Shader "Lit/CustomSurface"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        [NoScaleOffset] _HeightMap("Heights", 2D) = "gray" {}
        _BumpAmount("Bump Amount", Float) = 0.5
        _Tint("Tint", Color) = (1,1,1,1)
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        [Gamma] _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
        }

        CGINCLUDE
        #pragma target 3.0

        #include "Assets/Shaders/Light.cginc"
        #include "Assets/Shaders/util.cginc"

        struct a2v {

            float3 normal : NORMAL;
            float4 pos    : POSITION;
            float2 uv     : TEXCOORD0;
        };

        struct v2f {

            float3 normal   : NORMAL0;
            float3 worldPos : NORMAL1;

            VERTEXLIGHT_COLOR(0)

            UV_DECL(Main, 1)
        };

        TEX_DECL(Main);

        v2f vert(a2v v,
            out float4 clipPos : SV_POSITION)
        {
            clipPos = UnityObjectToClipPos(v.pos);

            v2f o;
            o.normal = UnityObjectToWorldNormal(v.normal);
            o.worldPos = mul(unity_ObjectToWorld, v.pos);
            o.uvMain = TRANSFORM_TEX(v.uv, _MainTex);

            VERTEXLIGHT_TRANSFER_COLOR(o, o.worldPos, o.normal);

            return o;
        }

        float3 _Tint;
        float _BumpAmount, _Glossiness, _Metallic;

        MAP_DECL(Height);

        fixed4 frag(v2f f) : SV_Target
        {
            float3 bumpNormal = ApplyBumpHeightMap(_HeightMap, _HeightMap_TexelSize.xy,
                f.uvMain, _HeightMap_TexelSize.xy);

            f.normal = lerp(normalize(f.normal), normalize(bumpNormal), _BumpAmount);

            LightParams lp;
            {
                lp.gloss = _Glossiness;
                lp.metal = _Metallic;
                lp.normal = normalize(f.normal);
                lp.eyeDir = normalize(_WorldSpaceCameraPos - f.worldPos);
            }

            UnityGI gi;
            {
                gi.indirect.specular = .0;
                gi.indirect.diffuse = VERTEXLIGHT_EXTRACT_COLOR(f);
            }

            CalculateGI(f.worldPos, lp.normal, gi);
            
            float3 albedo = _Tint * tex2D(_MainTex, f.uvMain).rgb;
            return ApplyFragmentLight(lp, gi, albedo);
        }
        ENDCG

        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }

            CGPROGRAM
            #pragma multi_compile _ VERTEXLIGHT_ON

            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }

        Pass
        {
            Tags
            {
                "LightMode" = "ForwardAdd"
            }

            Blend One One
            ZWrite Off

            CGPROGRAM
            #pragma multi_compile_fwdadd

            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
}
