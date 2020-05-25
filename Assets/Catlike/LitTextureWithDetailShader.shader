Shader "Lit/TextureWithDetail"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DetailTex("Detail", 2D) = "white" {}

        _AmbientColor("Ambient Color", Color) = (0, 0, 0, 1)
        _DiffuseColor("Diffuse Color", Color) = (1, 1, 1, 1)
        _SpecularColor("Specular Color", Color) = (.5, .5, .5, 1)
        _Glossiness("Glossiness", Float) = 1
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        Pass
        {
            Tags
            {
                "LightMode" = "ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

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
                float2 uv : TEXCOORD0;
                float2 uvDetail : TEXCOORD1;

                UNITY_FOG_COORDS(1)
            };

            sampler2D _MainTex, _DetailTex;
            float4 _MainTex_ST, _DetailTex_ST;

            v2f vert (appdata v,
                out float4 vertex : SV_POSITION)
            {
                vertex = UnityObjectToClipPos(v.vertex);

                v2f o;
                o.normal = normalize(mul(v.normal, (float3x3)unity_WorldToObject)); // UnityObjectToWorldNormal
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvDetail = TRANSFORM_TEX(v.uv, _DetailTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            float _Glossiness;
            float3 _AmbientColor, _DiffuseColor, _SpecularColor;

            fixed4 frag(v2f i) : SV_Target
            {
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float diffusion = saturate(dot(i.normal, lightDir));

                float3 eyeDir = normalize(_WorldSpaceCameraPos - i.worldPos);
                float3 lightBounce = normalize(eyeDir + lightDir);
                float specularity = pow(saturate(dot(i.normal, lightBounce)), _Glossiness);

                float3 albedo = _DiffuseColor
                    * unity_ColorSpaceDouble
                    * tex2D(_MainTex, i.uv)
                    * tex2D(_DetailTex, i.uvDetail);

                float reflectivity = max(_SpecularColor.r,
                    max(_SpecularColor.g, _SpecularColor.b));

                fixed4 col = fixed4(_AmbientColor
                    + (albedo * diffusion * (1. - reflectivity)
                        + _SpecularColor * specularity)
                    * _LightColor0.rgb,
                    1.);

                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
