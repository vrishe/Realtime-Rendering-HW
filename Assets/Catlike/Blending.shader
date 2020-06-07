Shader "Unlit/Blending"
{
    Properties
    {
        _MainTex ("Splat Map", 2D) = "black" {}
        _RTex("Tex. R", 2D) = "white" {}
        _GTex("Tex. G", 2D) = "white" {}
        _BTex("Tex. B", 2D) = "white" {}
        _KTex("Tex. K", 2D) = "white" {}
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

            #include "Assets/Shaders/util.cginc"

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                UV_DECL(Main, 0)
                UV_DECL(R, 1)
                UV_DECL(G, 2)
                UV_DECL(B, 3)
                UV_DECL(K, 4)

                UNITY_FOG_COORDS(5)
            };

            TEX_DECL(Main);
            TEX_DECL(R);
            TEX_DECL(G);
            TEX_DECL(B);
            TEX_DECL(K);

            v2f vert (appdata v,
                out float4 vertex : SV_POSITION)
            {
                vertex = UnityObjectToClipPos(v.vertex);

                v2f o;
                o.uvMain = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvR = TRANSFORM_TEX(v.uv, _RTex);
                o.uvG = TRANSFORM_TEX(v.uv, _GTex);
                o.uvB = TRANSFORM_TEX(v.uv, _BTex);
                o.uvK = TRANSFORM_TEX(v.uv, _KTex);

                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 splat = tex2D(_MainTex, i.uvMain);
                fixed4 col
                    = tex2D(_RTex, i.uvR) * splat.r
                    + tex2D(_GTex, i.uvG) * splat.g
                    + tex2D(_BTex, i.uvB) * splat.b
                    + tex2D(_KTex, i.uvK) * (1 - splat.r - splat.g - splat.b);

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
