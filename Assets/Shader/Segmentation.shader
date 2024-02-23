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
				
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

			#define _TileSize 5.0
			#define _BorderSize 0.49

			float rand3dTo1d(float3 value, float3 seed = float3(13.233,8.128, 1.343))
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
					rand3dTo1d(value, float3(18.234,4.234, 12.326)),
					rand3dTo1d(value, float3(7.104,10.192,18.847)),
					rand3dTo1d(value, float3(15.830,1.025, 7.203))
				);
			}

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);

				float3 value = worldPos / _TileSize;
				float3 cell = floor(value);

				float3 closestCell;
				float distToClosestCell = 1000;
				[unroll]
				for(int x = -1; x < 2; x++)
				{
					[unroll]
					for(int y = -1; y < 2; y++)
					{
						[unroll]
						for(int z = -1; z < 2; z++)
						{
							float3 neighbourCell = cell + float3(x,y,z);
							float3 neighbourCellPos = neighbourCell + rand3dTo3d(neighbourCell);
							float3 toNeighbourCell = neighbourCellPos - value;
							float neighbourCellDist = length(toNeighbourCell);
							if(neighbourCellDist < distToClosestCell)
							{
								closestCell = neighbourCell;
								distToClosestCell = neighbourCellDist;
							}

						}
					}
				}

                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed4 col = tex2D(_MainTex, i.uv);
                // sample the texture
                return col;
            }
            ENDCG
        }
    }
}
