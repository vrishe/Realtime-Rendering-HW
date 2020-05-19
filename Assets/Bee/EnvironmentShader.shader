Shader "Scene/EnvironmentShader"
{
    Properties
    {
        _ColorA("Color A", Color) = (0,0,0,0)
        _ColorB("Color B", Color) = (1,1,1,1)
        _Scale("Scale", Float) = 1
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Background"
            "RenderType" = "Background"
            "PreviewType" = "Skybox"
        }

        Cull Off
        ZWrite Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Assets/Shaders/Noise.cginc"
            #include "Assets/Shaders/Space.cginc"

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 uvw : TEXCOORD0;
            };

            struct v2f
            {
                float3 uvw : TEXCOORD0;
                fixed3 col : COLOR0;
            };

            v2f vert (appdata v,
                out float4 pos : SV_POSITION)
            {
                v2f o;
                pos = UnityObjectToClipPos(v.vertex);
                o.uvw = v.uvw;
                o.col = v.vertex;
                return o;
            }

            float4 _ColorA, _ColorB;
            float _Scale;

#define M_PI      3.1415926536
#define M_2_PI    6.2831853072
#define M_PI_2    1.5707963268
#define M_PI_4    0.7853981634
#define M_SQR_2   1.4142135624
#define M_SQR_2_2 0.7071067812
#define M_SQR_3_2 0.8660254038

            fixed4 frag(v2f i) : SV_Target
            {
                float2 st = _Scale * float2(
                        atan2(i.uvw.z, i.uvw.x),
                        i.uvw.y / length(i.uvw.zx))
                     / M_PI;

                float2 g = HexGrid(st);

                float gx = g.x + 1.;
                float2 g0 = float2(cos(gx), sin(gx));
                float n = .5f * (1. + WhiteNoise(g.y * WhiteNoise(g0)));

                return lerp(_ColorA, _ColorB, n);
            }
            ENDCG
        }
    }
}
