Shader "Hidden/GreWernessDitherInitialPassShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _ SHOW_NOISE
			
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

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			sampler2D _Noise; 


			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 cur = tex2D(_MainTex, i.uv);
				fixed4 noi = tex2D(_Noise, i.uv);
				#ifdef SHOW_NOISE
					return float4(noi.x,noi.y,noi.z,1.0);
				#else
					return float4(cur.x,noi.y,noi.z,1.0);
				#endif
			}
			ENDCG
		}
	}
}
