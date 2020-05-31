Shader "Custom/LitTextureMultiLights"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
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

        #include "AutoLight.cginc"
        #include "UnityPBSLighting.cginc"

        struct appdata
        {
            float3 normal : NORMAL;
            float2 uv : TEXCOORD0;
            float4 vertex : POSITION;
        };

        struct v2f
        {
            float3 normal : NORMAL0;
            float3 worldPos : NORMAL1;
            float2 uvMain : TEXCOORD0;

#if defined(VERTEXLIGHT_ON)
            float3 vertexLightColor : TEXCOORD3;
#endif
        };

        void FillLight(v2f i, out UnityLight light)
        {
            UNITY_LIGHT_ATTENUATION(attenuation, 0, i.worldPos);

            float3 lightVec = _WorldSpaceLightPos0.xyz - _WorldSpaceLightPos0.w * i.worldPos;

            light.dir = normalize(lightVec);
            light.color = _LightColor0.rgb * attenuation;
            light.ndotl = DotClamped(i.normal, light.dir);
        }

        void FillIndirectLight(v2f i, out UnityIndirect indirectLight) {
#if defined(VERTEXLIGHT_ON)
            indirectLight.diffuse = i.vertexLightColor;
#else
            indirectLight.diffuse = 0;
#endif

#if defined(UNITY_PASS_FORWARDBASE)
            indirectLight.diffuse += max(ShadeSH9(float4(i.normal, 1)), .0);
#endif

            indirectLight.specular = 0;
        }

        sampler2D _MainTex;
        float4 _MainTex_ST;

        v2f vert(appdata v,
            out float4 vertex : SV_POSITION)
        {
            vertex = UnityObjectToClipPos(v.vertex);

            v2f o;
            o.normal = UnityObjectToWorldNormal(v.normal);
            o.worldPos = mul(unity_ObjectToWorld, v.vertex);
            o.uvMain = TRANSFORM_TEX(v.uv, _MainTex);

#if defined(VERTEXLIGHT_ON)
            o.vertexLightColor = Shade4PointLights(
                unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
                unity_LightColor[0].rgb, unity_LightColor[1].rgb,
                unity_LightColor[2].rgb, unity_LightColor[3].rgb,
                unity_4LightAtten0, o.worldPos, o.normal
            );
#endif

            return o;
        }

        float3 _Color;
        float _Glossiness, _Metallic;

        fixed4 frag(v2f i) : SV_Target
        {
            i.normal = normalize(i.normal);

            UnityLight light;
            FillLight(i, light);

            UnityIndirect indirectLight;
            FillIndirectLight(i, indirectLight);

            float3 specularTint;
            float oneMinusReflectivity;
            float3 albedo = DiffuseAndSpecularFromMetallic(_Color * tex2D(_MainTex, i.uvMain),
                _Metallic, specularTint, oneMinusReflectivity);

            float3 eyeDir = normalize(_WorldSpaceCameraPos - i.worldPos);
            return UNITY_BRDF_PBS(albedo,
                specularTint, oneMinusReflectivity,
                _Glossiness, i.normal, eyeDir,
                light, indirectLight);
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
