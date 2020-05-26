Shader "Unlit/TextureWithDetail"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _DetailTex("Detail", 2D) = "white" {}
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
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
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvDetail = TRANSFORM_TEX(v.uv, _DetailTex);

                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv)
                    * tex2D(_DetailTex, i.uvDetail)
                    * unity_ColorSpaceDouble;

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
