Shader "Scene/DiscShader"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _RadiusFade("Radius", Vector) = (1, .001, 0, 0)
    }
    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
        }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
            };

            v2f vert (appdata_base v,
                out float4 pos : SV_POSITION)
            {
                v2f o;
                pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                UNITY_TRANSFER_FOG(o, pos);
                return o;
            }

            float4 _Color;
            float2 _RadiusFade;

            fixed4 frag (v2f i) : SV_Target
            {
                float2 d = 2 * i.uv - 1;
                float r = dot(d, d);

                fixed4 col = _Color;
                col.w *= smoothstep(r - _RadiusFade.y, r + _RadiusFade.y, _RadiusFade.x);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
