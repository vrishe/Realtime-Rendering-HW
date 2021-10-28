Shader "CameraEffect/HeatHaze"
{
    Properties
    {
        _AF("Amplitude and frequency", Vector) = (.2, .33, 55, 55)
        _FadeTex("Fade Texture", 2D) = "white" {}
        _NoiseTex("Noise Texture", 2D) = "black" {}
    }
    SubShader
    {
        Tags { "RenderType"="Overlay" "Queue" = "Overlay" }
        LOD 100

        GrabPass { "_GrabTex" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "Assets/Shaders/Billboard.cginc"
            #include "Assets/Shaders/Noise.cginc"
            #include "Assets/Shaders/util.cginc"

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex   : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex  : SV_POSITION;
                float4 grabPos : TEXCOORD0;
                float4 uvNoise : COLOR1;
                float2 uvFade  : COLOR0;

                UNITY_FOG_COORDS(1)
            };

            TEX_DECL(Fade);
            TEX_DECL(Noise);

            sampler2D _GrabTex;

            v2f vert (appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToBillboardPos(v.vertex);
                UNITY_TRANSFER_FOG(o, o.vertex);

                o.grabPos = ComputeGrabScreenPos(o.vertex);
                o.uvFade = TRANSFORM_TEX(v.texcoord, _FadeTex);
                o.uvNoise = float4(o.grabPos.xy * _NoiseTex_ST.xy + o.grabPos.z * _NoiseTex_ST.zw, o.grabPos.z, o.grabPos.w);

                return o;
            }

            float4 _AF;

            fixed4 frag(v2f i) : SV_Target
            {
                float2 n = i.grabPos.z * tex2D(_FadeTex, i.uvFade).r
                    * (tex2Dproj(_NoiseTex, i.uvNoise + float4(i.uvNoise.z * _AF.zw * _Time.yy, 0, 0)).r - .5) * _AF.xy;

                fixed4 col = tex2Dproj(_GrabTex, i.grabPos + float4(n, 0, 0));

                UNITY_APPLY_FOG(i.fogCoord, col);

                return col;
            }
            ENDCG
        }
    }
}
