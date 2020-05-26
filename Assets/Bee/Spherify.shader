Shader "Bee/Spherify"
{
    Properties
    {
        _Color("Color", Color) = (.5, .5, .5, 1.)

        [PerRendererData]
        _Amount("Amount", Float) = 0
        [PerRendererData]
        _Radius("Radius", Float) = 1
    }

    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
        }

        LOD 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha

            Cull Back
            ZWrite On

            CGPROGRAM
            #include "Assets/Shaders/Noise.cginc"

            #include "UnityCG.cginc"

            #pragma vertex   vert
            #pragma fragment frag

            #pragma multi_compile_fog

            struct v2f
            {
                float4 pos : SV_POSITION;

                UNITY_FOG_COORDS(2)
            };

            float _Amount;
            float _Radius;

            v2f vert(appdata_base v)
            {
                float3 d = v.vertex;
                float3 n = d / length(d);
                v.normal = lerp(v.normal, n, log(_Amount));
                v.vertex = float4(
                    lerp(v.vertex, _Radius * n, _Amount),
                    v.vertex.w);

                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                UNITY_TRANSFER_FOG(o, pos);
                return o;
            }

            float4 _Color;

            fixed4 frag(v2f i) : SV_Target
            {
                fixed4 col = _Color;
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
