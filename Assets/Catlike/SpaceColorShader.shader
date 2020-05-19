// Upgrade NOTE: upgraded instancing buffer 'SpaceColorProps' to new syntax.

// Upgrade NOTE: upgraded instancing buffer 'MyProperties' to new syntax.

Shader "Catlike/Grid/SpaceColorShader"
{
    Properties
    {
        _Color ("Color", Color) = (0, 1, 0, 1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                UNITY_FOG_COORDS(1)

                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            UNITY_INSTANCING_BUFFER_START(SpaceColorProps)
                UNITY_DEFINE_INSTANCED_PROP(float4, _Color)
#define _Color_arr SpaceColorProps
            UNITY_INSTANCING_BUFFER_END(SpaceColorProps)

            v2f vert (appdata v,
                out float4 pos : SV_POSITION)
            {
                v2f o;

                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_TRANSFER_INSTANCE_ID(v, o);

                pos = UnityObjectToClipPos(v.vertex);
                UNITY_TRANSFER_FOG(o,pos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                UNITY_SETUP_INSTANCE_ID(i);

                fixed4 col = UNITY_ACCESS_INSTANCED_PROP(_Color_arr, _Color);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
