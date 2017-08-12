// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/EdgeDetectionShader"
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
			#pragma multi_compile _ SHOW_SOURCE
			#pragma multi_compile _ SHOW_DEPTHTEXTURE


			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;
			float2 _MainTex_TexelSize;
			sampler2D_float _CameraDepthTexture;

			sampler2D _SourceTex;

			float _ColorThreeshold;
			float _DepthThreeshold;
			fixed4 _BgColor;
			fixed4 _Color;



			fixed4 frag (v2f i) : SV_TARGET
			{
				

				float4 disp = float4(_MainTex_TexelSize.xy, -_MainTex_TexelSize.x, 0);

				float _DepthTreeshold = 10;

				// four sample points for the roberts cross operator
				float2 uv0 = i.uv;           // TL
				float2 uv1 = i.uv + disp.xy; // BR
				float2 uv2 = i.uv + disp.xw; // TR
				float2 uv3 = i.uv + disp.wy; // BL

				float edge = 0;

				

				// sample normal vector values from the main texture
				float3 n0 = tex2D(_MainTex, uv0);
				float3 n1 = tex2D(_MainTex, uv1);
				float3 n2 = tex2D(_MainTex, uv2);
				float3 n3 = tex2D(_MainTex, uv3);

				#if UNITY_UV_STARTS_AT_TOP
								if (_MainTex_TexelSize.y < 0)
									i.uv.y = 1 - i.uv.y;
				#endif

				float zs0 = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
				float zs1 = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv + disp.xy);
				float zs2 = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv + disp.xw);
				float zs3 = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv + disp.wy);

				float zMoy = (zs0 + zs1 + zs2 + zs3) / 4;
				

				// roberts cross operator
				float3 ng1 = n1 - n0;
				float3 ng2 = n3 - n2;
				float ng = sqrt(dot(ng1, ng1) + dot(ng2, ng2));

				edge = max(edge, ng);

				if (edge > _ColorThreeshold && Linear01Depth(zMoy) < _DepthThreeshold)
					edge = 1;
				else
					edge = 0;

				half4 cs = tex2D(_SourceTex, i.uv);
				half3 c0 = lerp(cs.rgb, _BgColor.rgb, _BgColor.a);
				half3 co = lerp(c0, _Color.rgb, edge * _Color.a); 

				return half4(co, 0);			
			}
			ENDCG
		}
	}
}
