// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "EdgeDetection/EdgeDetectionHelper"
{
	Properties
	{
	}
	SubShader
	{
		

		Pass
		{
			Tags{ "RenderType" = "Opaque" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag			
			#include "UnityCG.cginc"
			

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 color : COLOR;
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 color : COLOR;
			};

			// Vertex program
			v2f vert (appdata v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);



				float3 origin = mul(unity_ObjectToWorld, float4(0.0, 0.0, 0.0, 1.0)).xyz;
				float3 area = float3(100, 100, 100);

				float3 cameraDir = mul((float3x3)UNITY_MATRIX_V, float3(0, 0, 1));
				float3 norm = mul(unity_ObjectToWorld, float4(v.normal, 0.0));

				norm *= v.color.r;

				float light = saturate((dot(norm, cameraDir) + 1.0)*0.5);

				o.color = ((origin + area) * 0.5) / area;

				if(v.color.g > 0)
				{
				o.color.x *= light;
				o.color.y /= light;
				}

				//o.color *= v.color.g;



				o.color = frac(o.color * 100);



					

				//write to depth buffer
				UNITY_TRANSFER_DEPTH(o.depth);

				return o;
			}
			
			// Fragment program
			fixed4 frag(v2f i) : SV_Target
			{
				return float4(i.color,1);
			}
				
			ENDCG
		}
	}
	FallBack "Diffuse"
}
