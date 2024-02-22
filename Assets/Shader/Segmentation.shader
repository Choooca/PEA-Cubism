Shader "Unlit/Segmentation"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
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

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
				float3 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

			#define _TileSize 1.0

			float rand3dTo1d(float3 value, float3 seed = float3(13.233,8.128,11.234))
			{
				value = sin(value);
				float rand = dot(value, seed);
				rand = frac(sin(rand) * 131245);
				return rand;
			}
			
			float3 rand3dTo3d(float3 value)
			{
				return float3
				(
					rand3dTo1d(value, float3(18.234,4.234,8.023)),
					rand3dTo1d(value, float3(7.104,10.192,1.215)),
					rand3dTo1d(value, float3(15.830,1.025,4.987))
				);
			}

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.worldPos = mul(unity_ObjectToWorld, float4(v.vertex)).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float3 col;
				float3 fracWorldPos = frac(i.worldPos * _TileSize);
				col = rand3dTo3d(floor(i.worldPos * _TileSize));
                return float4(float3(col), 1.0);
            }
            ENDCG
        }
    }
}
