Shader "Unlit/uv-test"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Scale("Scale", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "Assets/Shaders/Noise.cginc"
            #include "Assets/Shaders/Space.cginc"

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            static const float2 HexGridCoeff = float2(.3333333333, 1.7320508078);

            float _Scale;

            fixed4 frag (v2f i) : SV_Target
            {
                float2 st = i.uv;//2. * i.uv - 1;
                st.y /= 1.1547344111;
                st *= _Scale;

                float2 g = HexGrid(st);
                float x = xor(mod(floor(HexGridCoeff * g), 2.));

                //g.y = fmod(g.y, 5.) - floor(g.x / 5.);
                return fixed4(g / _Scale, .0, 1.);

                float n = .5f * (1 + WhiteNoise(g));

                st.x *= .5;
                st.y *= .433;
                st.y += .75;

                fixed4 col = lerp(tex2D(_MainTex, st),
                    lerp(fixed4(1, 1, 1, 1), fixed4(0, 0, 0, 1), floor(256. * n) / 256.),
                    1);

                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
