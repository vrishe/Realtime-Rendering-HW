Shader "Bee/Dissolve"
{
    Properties
    {
        _MainTex("Main Texture", 2D) = "white" {}

        _Scale("Scale", Float) = 1
        _Decay("Decay", Float) = 0.1

        [PerRendererData]
        _Threshold("Threshold", Float) = 0
    }

    CGINCLUDE

    #include "Assets/Shaders/Noise.cginc"
    #include "Assets/Shaders/Space.cginc"

    #include "UnityCG.cginc"

    struct v2f
    {
        float2 uv : TEXCOORD0;

        UNITY_FOG_COORDS(2)
    };

    sampler2D _MainTex;
    float4 _MainTex_ST;

    float _Scale;
    float _Threshold;
    float _Decay;

    v2f vert(appdata_base v,
        out float4 pos : SV_POSITION)
    {
        pos = UnityObjectToClipPos(v.vertex);

        v2f o;
        o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

        UNITY_TRANSFER_FOG(o, pos);
        return o;
    }

    fixed4 frag_i(v2f i, float intensity)
    {
        fixed4 col = tex2D(_MainTex, i.uv) * intensity;

        float n = .5f * (1 + WhiteNoise(HexGrid(_Scale * i.uv)));
        float t = lerp(-_Decay, 1 + _Decay, _Threshold);

        col.w = smoothstep(t - _Decay, t + _Decay, n);

        UNITY_APPLY_FOG(i.fogCoord, col);
        return col;
    }

    ENDCG

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
        }

        Blend SrcAlpha OneMinusSrcAlpha

        LOD 200

        Pass
        {
            Cull Front

            CGPROGRAM
            #pragma vertex   vert
            #pragma fragment frag

            #pragma multi_compile_fog

            fixed4 frag(v2f i) : SV_Target
            {
                return frag_i(i, 0.125);
            }
            ENDCG
        }

        Pass
        {
            Cull Back

            CGPROGRAM
            #pragma vertex   vert
            #pragma fragment frag

            #pragma multi_compile_fog

            fixed4 frag (v2f i) : SV_Target
            {
                return frag_i(i, 1);
            }
            ENDCG
        }
    }
}
