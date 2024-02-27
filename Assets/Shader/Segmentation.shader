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
				float4 worldPos : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

			#define _TileSize 0.9
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

				o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture

				float3 value = i.worldPos / _TileSize;
				float3 cell = floor(value);

				float3 closestCell;
				float3 toClosestCell;
				float distToClosestCell = 1000.0;
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
								toClosestCell = toNeighbourCell;
							}

						}
					}
				}

				float minEdgeDistance = 100.0;
				[unroll]
				for(int x1 = -1; x1 < 2; x1++)
				{
					[unroll]
					for(int y1 = -1; y1 < 2; y1++)
					{
						[unroll]
						for(int z1 = -1; z1 < 2; z1++)
						{
							float3 neighbourCell = cell + float3(x1,y1,z1);
							float3 neighbourCellPos = neighbourCell + rand3dTo3d(neighbourCell);
							float3 toNeighbourCell = neighbourCellPos - value;

							float3 distToCurrentCell = abs(closestCell - neighbourCell);
							bool isClosestCell = distToCurrentCell.x + distToCurrentCell.y + distToCurrentCell.z < 0.1;
							if(!isClosestCell)
							{
								float3 toCenter = (toClosestCell + toNeighbourCell) * 0.5;
								float3 cellDif = normalize( toNeighbourCell - toClosestCell);
								float distToEdge = dot(toCenter, cellDif );
								minEdgeDistance = min(minEdgeDistance, distToEdge);
							}
						}
					}
				}

				float3 color = rand3dTo3d(closestCell);
				float isBorder = step(minEdgeDistance, 0.02);
				float3 finalColor = lerp(color, float3(0,0,0), isBorder);

                return float4(finalColor, 1.0);
            }
            ENDCG
        }
    }
}
