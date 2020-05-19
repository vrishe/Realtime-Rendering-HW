Shader "CameraEffect/RGBSeparation"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Offset("Offset", Vector) = (.5,.5,1.,1.)
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                float4 abb : TEXCOORD1;
            };

            float4 _Offset;

            v2f vert (appdata v,
                out float4 pos : SV_POSITION)
            {
                pos = UnityObjectToClipPos(v.vertex);

                v2f o;
                o.uv = float4(v.uv,
                    .5 * min(_ScreenParams.x, _ScreenParams.y),
                    .5 * max(_ScreenParams.x, _ScreenParams.y));
                o.abb = float4(
                    _Offset.z * (v.uv - _Offset.xy),
                    _Offset.w * (_Offset.xy - v.uv));
                return o;
            }

            sampler2D _MainTex;

            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(
                    tex2D(_MainTex, i.uv + i.abb.xy / i.uv.z).r,
                    tex2D(_MainTex, i.uv).g,
                    tex2D(_MainTex, i.uv + i.abb.zw / i.uv.z).b,
                    1);
            }
            ENDCG
        }
    }
}
