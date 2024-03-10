Shader "Unlit/PostProcessVoronoi"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_FirstRenderTexture ("First Render Texture", 2D) = "white" {}
		_SecondRenderTexture ("Second Render Texture", 2D) = "white" {}
		_ThirdRenderTexture ("Third Render Texture", 2D) = "white" {}
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

			float rand3dTo1d(float3 value, float3 seed = float3(13.233,8.128, 5.934))
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
					rand3dTo1d(value, float3(18.234,4.234, 0.923)),
					rand3dTo1d(value, float3(7.104,10.192, 18.304)),
					rand3dTo1d(value, float3(1.063,9.872, 10.325))
				);
			}

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
			sampler2D _FirstRenderTexture;
			sampler2D _SecondRenderTexture;
			sampler2D _ThirdRenderTexture;
            float4 _MainTex_ST;

			#define _TileSize 1
			#define _BorderSize 0.49

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {

				// sample the texture

				float3 value = float3(i.uv.x * 16, i.uv.y * 9, _Time.y * .1);
				value = value / _TileSize;
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

				float color = rand3dTo1d(closestCell);

                // sample the texture
                fixed4 col = step(.66f, color) * tex2D(_FirstRenderTexture, i.uv) + step(color, .33f) * tex2D(_SecondRenderTexture, i.uv) + step(.33, color) * step(color, .66) * tex2D(_ThirdRenderTexture, i.uv) ;
                return col ;
            }
            ENDCG
        }
    }
}
